# Technical.md

# Technical

## Core Technologies

The intended technical foundation is:

- Bazel
- Jsonnet

These technologies should be combined to support large-scale generation and orchestration of configuration artifacts.

## Jsonnet Role

Jsonnet should provide the templating, abstraction, and synthesis layer.

Jsonnet responsibilities include:

- Defining reusable configuration templates
- Encoding business and operational conventions
- Generating arbitrary numbers of output files
- Expanding configuration based on higher-level declarations
- Reducing duplication across generated configuration
- Translating semantic input into concrete YAML or JSON outputs

## Bazel Role

Bazel should provide the build orchestration layer.

Bazel responsibilities include:

- Aggregating generated outputs
- Managing dependencies between inputs and generated artifacts
- Creating structured output directory hierarchies
- Layering generated artifacts according to conventions
- Rebuilding only what changed
- Supporting deterministic builds
- Supporting caching and incremental generation
- Managing large-scale configuration synthesis workflows

## Data Inputs

The system should support supporting datasets that behave like lightweight reference databases.

These datasets may include:

- Environment metadata
- Workload classifications
- Operational classes
- Business rules
- Regional or account mappings
- Infrastructure reference data
- Configuration ranges
- Policy inputs

These datasets should provide structured inputs to the generation process.

## Schema Support

Schema specifications should be used to make templating safer and easier.

Schemas may help define:

- Valid input shapes
- Required fields
- Default behaviours
- Expected output structures
- Configuration contracts
- Validation boundaries

## Dynamic Output Generation

The system should support dynamic generation of configuration outputs.

Examples include:

- A template determines `N = 3`.
- A rule expands into 16 generated outputs.
- A combination of criteria produces multiple configuration files.
- Domain-specific input expands into a structured directory tree.

The generation logic should live in the templating layer rather than being manually represented as static files.

## Configuration Synthesis

The system should allow higher-level declarations to produce concrete configuration values.

For example, instead of manually setting low-level values everywhere, users should be able to declare properties such as:

- High-throughput workload
- Latency-sensitive system
- Batch-processing workflow
- Operational class
- Percentile-based value selection
- Business-domain classification

Jsonnet should then apply the relevant conventions and generate the resulting concrete configuration.

## Build Output Structure

Bazel should organize generated artifacts into predictable output structures.

The output model should support:

- Structured directory hierarchies
- Organizational conventions
- Domain-specific layering
- Environment-specific outputs
- Efficient rebuilds
- Repeatable generation

## Design Goals

The technical design should:

- Reduce hardcoded values
- Avoid static configuration placement where generation is more appropriate
- Programmatically populate values from structured inputs
- Improve reuse through Jsonnet abstractions
- Use Bazel for deterministic and efficient orchestration
- Preserve clear relationships between input data, templates, and generated output