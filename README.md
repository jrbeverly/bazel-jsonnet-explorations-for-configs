# Bazel + Jsonnet Explorations for Configuration Management

> [!WARNING]
> **AI-authored:** This change was autonomously planned and implemented by an AI software factory from a human-authored specification, with possible subsequent human review or modification.

Semantic intent declarations (`workloadClass`, `environment`) fed through Jsonnet convention and reference-data layers to produce JSON config artifacts and provenance sidecars, with Bazel managing the build graph and caching.

```bash
make setup
make e2e
```

## Notes

- interesting use of Bazel with Jsonnet
- concerning behaviour of continuing to roll a custom installer bazelisk (makefile)
- not sold on the overall design
- feels like configuration management needs a different abstraction
- concern with hundreds of generated configuration files becoming the thing that systems need to manage/administer
- configuration at scale probably should not be treated primarily as file generation + file orchestration
- likely needs higher-order system; database-backed configuration/state model
- central system responsible for relationships, tuning, adjustment, propagation
- files potentially become rendered outputs/artifacts rather than source of truth
