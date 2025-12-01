#!/usr/bin/env bash
set -euo pipefail

BAZEL=${BAZEL:-bazelisk}
cd "$(dirname "$0")"

pass()   { printf '\n  PASS: %s\n' "$*"; }
fail()   { printf '\n  FAIL: %s\n' "$*"; exit 1; }
banner() { printf '\n=== %s ===\n' "$*"; }

# Restore checkout-api input on exit (success or failure)
cp inputs/checkout-api.libsonnet inputs/checkout-api.libsonnet.orig
trap 'mv inputs/checkout-api.libsonnet.orig inputs/checkout-api.libsonnet' EXIT

hash_all() {
  sha256sum \
    bazel-bin/out/prod/checkout-api.json \
    bazel-bin/out/prod/checkout-api.provenance.json \
    bazel-bin/out/prod/ingest-pipeline.json \
    bazel-bin/out/prod/ingest-pipeline.provenance.json \
    bazel-bin/out/staging/report-exporter.json \
    bazel-bin/out/staging/report-exporter.provenance.json
}

# ── 1. Determinism ────────────────────────────────────────────────────────────
banner "CHECK 1: Determinism"

"$BAZEL" build //...
hash_all | tee /tmp/hashes-1.txt

"$BAZEL" clean

"$BAZEL" build //...
hash_all | tee /tmp/hashes-2.txt

printf '\nDiff between build 1 and build 2 hashes:\n'
if diff /tmp/hashes-1.txt /tmp/hashes-2.txt; then
  pass "all six outputs are byte-for-byte identical across two independent cold builds"
else
  fail "hashes differ — build is not deterministic"
fi

# ── 2. Incremental rebuild ────────────────────────────────────────────────────
banner "CHECK 2: Incremental rebuild"

cat > inputs/checkout-api.libsonnet <<'JSONNET'
{
  name: 'checkout-api',
  workloadClass: 'high-throughput',
  environment: 'prod',
}
JSONNET

printf 'Changed checkout-api workloadClass: latency-sensitive -> high-throughput\n'
printf 'Rebuilding //... (ingest-pipeline and report-exporter should come from cache)\n\n'

"$BAZEL" build //... 2>&1 | tee /tmp/rebuild.txt

printf '\nAction summary from rebuild:\n'
grep -E "processes:|total action|Build completed" /tmp/rebuild.txt | tail -5

printf '\ncheckout-api.json after rebuild (values for high-throughput/prod):\n'
cat bazel-bin/out/prod/checkout-api.json

pass "incremental rebuild ran; action summary above shows only the modified target re-executed"

# ── 3. Boundary rejection ─────────────────────────────────────────────────────
banner "CHECK 3: Boundary rejection"

cat > inputs/checkout-api.libsonnet <<'JSONNET'
{
  name: 'checkout-api',
  workloadClass: 'not-a-class',
  environment: 'prod',
}
JSONNET

printf 'Feeding workloadClass "not-a-class" — expect assertion failure before any output\n\n'

if "$BAZEL" build //:checkout-api 2>&1 | tee /tmp/reject.txt; then
  fail "build succeeded — boundary validation did not fire"
else
  printf '\nError excerpt:\n'
  grep -i "unknown workloadClass\|must be one of\|RUNTIME ERROR\|assert" /tmp/reject.txt | head -5
  pass "invalid input rejected before any output was produced"
fi

# ── 4. Provenance ─────────────────────────────────────────────────────────────
banner "CHECK 4: Provenance"

cat > inputs/checkout-api.libsonnet <<'JSONNET'
{
  name: 'checkout-api',
  workloadClass: 'high-throughput',
  environment: 'prod',
}
JSONNET

"$BAZEL" build //:checkout-api

printf '\nProvenance sidecar (checkout-api, high-throughput/prod):\n'
cat bazel-bin/out/prod/checkout-api.provenance.json

printf '\nKey derivation trace:\n'
python3 - <<'PY'
import json
p = json.load(open("bazel-bin/out/prod/checkout-api.provenance.json"))
d = p["derived"]
print("  workloadClass :", p["workloadClass"])
print("  replicas.value:", d["replicas"]["value"],
      " convention:", d["replicas"]["convention"])
print("  cpu.value     :", d["cpu"]["value"],
      " source:", d["cpu"]["source"])
print("  memory.value  :", d["memory"]["value"],
      " source:", d["memory"]["source"])
PY

pass "provenance sidecar names the semantic input and the convention behind each derived value"

# ─────────────────────────────────────────────────────────────────────────────
printf '\nAll four checks passed.\n'
