# Vision.md

# Vision

## Concept

The system should turn large-scale configuration management into a convention-driven synthesis process.

Instead of manually maintaining huge directories of literal YAML and JSON files, teams should define structured inputs, reusable templates, and higher-level operational intent.

The platform then generates the concrete configuration artifacts.

## Desired Model

The intended model combines:

- Reference datasets
- Schema definitions
- Jsonnet templates
- Bazel orchestration
- Generated YAML and JSON outputs
- Structured directory hierarchies
- Incremental and deterministic builds

Jsonnet expresses the configuration logic.

Bazel manages the build graph and generated artifacts.

## Configuration Authoring Experience

Authors should not need to manually duplicate low-level values across many files.

Instead, they should be able to describe the system in terms of meaningful domain concepts.

For example:

- This workload is high-throughput.
- This service is latency-sensitive.
- This job is batch-oriented.
- This environment belongs to this operational class.
- This value should come from a defined policy range.

The concrete configuration values should emerge from these declarations through encoded conventions.

## Generated Configuration Experience

The generated configuration should still be usable by existing systems.

The output may remain YAML or JSON, but it should be produced from a more structured and reusable source model.

This allows existing GitOps and deployment workflows to continue consuming generated artifacts while improving the maintainability of the source configuration system.

## Operational Experience

The system should make large-scale configuration easier to reason about.

Operators and reviewers should be able to understand:

- Which inputs produced an output
- Which templates were applied
- Which conventions influenced a value
- Which datasets contributed to the result
- Which generated files changed
- Why a configuration value exists

The system should reduce the need to inspect hundreds or thousands of nearly identical static files.

## Build Experience

Bazel should make configuration generation efficient and predictable.

The build system should support:

- Deterministic outputs
- Incremental rebuilds
- Dependency-aware generation
- Caching
- Large-scale artifact aggregation
- Repeatable output structures

This allows configuration synthesis to scale without becoming operationally slow or fragile.

## Architectural Direction

The architecture should treat configuration as generated infrastructure data rather than purely hand-authored files.

The system should be built around:

- Jsonnet for reusable abstraction and templating
- Bazel for orchestration, dependency handling, and build efficiency
- Structured datasets for reference information
- Schemas for safety and consistency
- Generated outputs for downstream deployment systems

## Desired Outcome

The result should be an evolution of GitOps from static configuration declaration into semantically meaningful configuration synthesis.

The system should preserve the benefits of version-controlled configuration while adding:

- Higher-level intent
- Stronger reuse
- Better composability
- Less duplication
- Programmatic generation
- Scalable build orchestration
- Clearer operational meaning