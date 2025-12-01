# MOCK-DESIGN

## Purpose

This document is a conceptual mock design for the repository based on:

- [PROBLEM.md](/d:/Home/Projects/Labs/bazel-jsonnet-explorations-for-configs/PROBLEM.md)
- [TECHNICAL.md](/d:/Home/Projects/Labs/bazel-jsonnet-explorations-for-configs/TECHNICAL.md)
- [VISION.md](/d:/Home/Projects/Labs/bazel-jsonnet-explorations-for-configs/VISION.md)

It is intended to answer whether the proposed system is fundamentally workable, what major architecture it implies, and which unresolved decisions still matter before deeper implementation begins.

This is not an implementation spec. It intentionally avoids locking the project into final schemas, concrete file formats, or low-level repository mechanics except where those decisions are necessary to assess feasibility.

## Executive Summary

The proposed system is conceptually viable.

The combination of Bazel and Jsonnet is a credible foundation for large-scale configuration synthesis if the system is treated as a deterministic build pipeline from versioned inputs to generated artifacts.

The design direction makes sense when the problem is:

- many related configuration outputs
- repeated conventions across environments or workloads
- a need to derive low-level values from higher-level intent
- a need for deterministic, incremental regeneration

The main risk is not whether Bazel and Jsonnet can generate files together. They can.

The main risk is whether the repository can introduce semantic authoring without creating a second, harder-to-understand configuration language that becomes opaque to authors, reviewers, and operators.

This means the project is viable, but only if it is designed around a few strict principles:

- Inputs must be deterministic and versioned.
- The semantic layer must stay bounded and understandable.
- The synthesis process must be explainable.
- Ownership of conventions and reference data must be clear.
- Escape hatches for exceptions must exist, but be controlled.

If those principles are ignored, the system can easily become more complex than the static YAML/JSON sprawl it is meant to replace.

## Problem Framing

The source documents describe a shift from literal configuration authoring toward convention-driven synthesis.

At a high level, the intended move is:

1. Authors describe intent and structured inputs rather than repeating concrete values everywhere.
2. Shared datasets and conventions provide defaults, ranges, mappings, and policy context.
3. Jsonnet translates those higher-level declarations into concrete YAML or JSON artifacts.
4. Bazel orchestrates generation, validation, aggregation, and incremental rebuilds.
5. Downstream GitOps or deployment systems continue consuming normal configuration artifacts.

This is a coherent direction. It addresses real pain points:

- duplication
- weak reuse
- poor expression of operational meaning
- hardcoded values scattered across many files
- brittle large-scale maintenance

## Core Assumptions

The design appears to assume all of the following:

- The generated outputs are still file-oriented artifacts such as YAML or JSON.
- Most inputs can be represented as versioned data in the repository, or at least as deterministic snapshots.
- Configuration generation can be treated as a pure function of inputs, templates, and conventions.
- The same conventions should apply repeatedly across many outputs.
- Teams are willing to author higher-level declarations rather than only hand-edit final artifacts.
- Build-time generation is acceptable in the current operational model.

These assumptions are reasonable, but they should be made explicit because the architecture depends on them.

## Conceptual Architecture

The system should be organized around six conceptual layers.

### 1. Intent Authoring Layer

This is the primary human-authored layer.

Its job is to express:

- workload intent
- environment intent
- classification and policy choices
- references to shared datasets
- explicit exceptions where conventions should not fully decide the result

This layer should describe meaning, not duplicate final low-level output structure.

### 2. Reference Data Layer

This layer holds structured supporting datasets that behave like lightweight reference databases.

Examples:

- environment metadata
- regional mappings
- workload classes
- policy ranges
- infrastructure reference data
- business classification data

This layer should provide stable, reviewable inputs into generation.

It should not behave like a live operational API. If data is pulled from external systems, it should enter the repository or build process as a versioned snapshot with a clear refresh model.

### 3. Convention and Policy Layer

This layer defines how intent is interpreted.

Examples:

- what "high-throughput" means in practice
- which defaults apply to a given operational class
- how ranges or policy bands map to concrete values
- what environment-specific adjustments are allowed

This is the most sensitive layer in the design because it converts semantic labels into concrete operational behavior.

It should remain small, explicit, and governable. If this layer becomes too open-ended, the system stops being a configuration platform and becomes a general-purpose policy engine with unclear boundaries.

### 4. Synthesis Layer

Jsonnet fits naturally here.

Its responsibility is to:

- combine intent, reference data, and conventions
- construct final configuration structures
- expand one declaration into many outputs where appropriate
- apply shared abstractions consistently
- render concrete YAML or JSON artifacts

The synthesis layer should be pure and deterministic. It should not depend on runtime side effects or hidden mutable state.

### 5. Validation and Explanation Layer

This layer is essential to making the system trustworthy.

It should answer:

- Is the input declaration valid?
- Did required reference data exist?
- Did the generated output satisfy expected contracts?
- Why did a particular value get produced?
- Which convention or dataset influenced the result?

Schema support is most valuable at system boundaries:

- validating authored input shapes
- validating reference data shapes
- validating generated outputs against downstream contracts

Just as important, the system needs explainability, not only validation. Without an explanation mechanism, operators will see generated values but not understand their origin.

### 6. Build and Delivery Layer

Bazel fits here.

Its responsibility is to:

- represent generation and validation as a dependency graph
- rebuild only affected outputs
- aggregate outputs into predictable structures
- support deterministic builds and caching
- enable selective builds for subtrees, environments, or domains

This layer should treat the synthesis system as a file-producing build graph rather than as an ad hoc scripting workflow.

## Why The Architecture Is Viable

This architecture is viable because the responsibilities of Bazel and Jsonnet are complementary rather than overlapping.

Jsonnet is well-suited to structural composition, value derivation, and repeated expansion of related configuration.

Bazel is well-suited to:

- dependency management
- incremental rebuilds
- reproducibility
- large-scale artifact organization
- enforcing that outputs are produced from declared inputs

The pieces fit together if the handoff is clean:

- Jsonnet owns value synthesis and structural generation.
- Bazel owns orchestration, dependency tracking, and output materialization.

That separation is the strongest part of the proposal.

## Where The Architecture Can Fail

The design is viable in principle, but there are several failure modes that need to be actively prevented.

### Semantic Drift

Terms like "high-throughput" or "latency-sensitive" are attractive because they encode intent, but they can also hide too much.

If those labels are vague, overloaded, or changed casually over time, authors lose confidence in what the system will generate. The semantic vocabulary needs stable meanings and ownership.

### Opaque Generation

If users cannot trace why a generated value exists, the platform will be difficult to operate.

This is especially important in GitOps workflows where review and audit matter. Generated output must be traceable back to its inputs, conventions, and responsible policies.

### Meta-Configuration Explosion

A system meant to reduce YAML sprawl can become a more complicated sprawl made of:

- intent files
- reference tables
- policy mappings
- layering rules
- overrides
- generated outputs

The architecture must therefore keep boundaries simple and constrain how many indirection layers are allowed.

### Exception Handling

Not every workload will fit common conventions.

If there is no safe override model, teams will bypass the system.

If overrides are too powerful or too easy, conventions lose value and output behavior becomes unpredictable.

This needs a deliberate middle ground.

### Determinism Risk From External Data

The documents describe dataset-driven generation. That is workable only if those datasets are deterministic inputs to the build.

If generation depends directly on mutable external systems, Bazel's value decreases sharply because reproducibility and caching become less meaningful.

### Tooling Adoption Cost

Bazel and Jsonnet are powerful, but they are not the easiest authoring stack for every team.

This does not make the design wrong, but it does mean the user experience needs to be intentionally designed. A good architecture here needs to consider not only build correctness, but authoring ergonomics and review ergonomics.

## Proposed System Boundaries

To keep the design coherent, the system should define a few firm boundaries.

### What The Platform Should Own

- higher-level configuration intent
- reusable conventions and policy logic
- reference data used during synthesis
- deterministic generation of concrete artifacts
- validation of input and output contracts
- explainability for generated results

### What The Platform Should Not Pretend To Own

- live operational state
- runtime drift correction by itself
- every possible exception as a first-class abstraction
- dynamic decision-making based on mutable external APIs at build time
- downstream deployment behavior beyond artifact production and handoff

These limits matter because they protect the platform from growing into an under-specified control plane.

## High-Level Repository Shape

One plausible repository shape would separate responsibilities into areas such as:

- `docs/` for problem framing, architecture, and author guidance
- `inputs/` for human-authored intent declarations
- `reference-data/` for versioned supporting datasets
- `schemas/` for boundary validation contracts
- `lib/` for Jsonnet conventions, composition logic, and render helpers
- `build/` or top-level Bazel files for orchestration entry points
- `out/` or generated artifact targets for rendered YAML/JSON outputs
- `tools/` for developer workflows such as validation, explanation, or diff helpers

This should be treated as conceptual separation, not a fixed final layout.

The important design point is that authored intent, shared data, generation logic, validation logic, and generated outputs should not be mixed together loosely.

## High-Level Workflow

The expected end-to-end workflow is:

1. An author describes a workload, environment, or domain-specific intent.
2. That intent references shared classifications, policies, or datasets.
3. Jsonnet resolves those inputs through reusable conventions.
4. Generation expands the declaration into one or more concrete output artifacts.
5. Validation checks the input shape, reference data shape, and output contract.
6. Bazel materializes only the required outputs and places them into predictable structures.
7. Reviewers and operators inspect both the concrete diff and the explanation of how it was derived.
8. Downstream systems consume the generated YAML/JSON artifacts through the existing delivery path.

This workflow is realistic and coherent.

The critical addition is step 7. Without it, the system may generate valid files but still fail organizationally because people cannot understand or trust the result.

## Major Unresolved Decisions

The current documents describe direction clearly, but they leave several important design decisions unresolved.

### 1. What Is The Canonical Source Of Truth?

It is not yet fully clear whether the authoritative source should be:

- high-level intent only
- high-level intent plus some manual low-level overlays
- generated outputs committed back into the repository
- generated outputs produced only as build artifacts

This is a major architectural decision because it affects review workflows, GitOps compatibility, and operational trust.

### 2. How Strong Should The Semantic Layer Be?

There is a spectrum between:

- a light abstraction layer that mostly reduces duplication
- a rich semantic platform that derives many low-level values from policy and classification

Both are viable, but they imply very different governance, debugging, and authoring requirements.

### 3. How Will Explainability Work?

The source documents rightly emphasize understanding why values exist, but they do not yet define how that understanding will be surfaced.

This does not require a final mechanism yet, but the architecture should explicitly reserve space for:

- provenance
- derivation summaries
- input-to-output traceability
- policy attribution

If explanation is not treated as a first-class concern early, it will be difficult to add later.

### 4. What Is The Override Model?

The system needs a disciplined answer to:

- when conventions may be overridden
- who is allowed to override them
- whether overrides are local, scoped, or global
- how overrides remain reviewable

This is one of the biggest practical adoption decisions.

### 5. How Static Are The Reference Datasets?

The design mentions dataset-driven generation, but not whether these datasets are:

- entirely curated in-repo
- imported from external systems
- partially generated
- refreshed on a schedule

That affects reproducibility, ownership, and Bazel integration.

### 6. What Scale Must The First Version Actually Support?

The documents aim at large scale, but the initial design needs a realistic scale target such as:

- number of authored declarations
- number of generated outputs
- number of environments or domains
- acceptable regeneration latency

Without this, it is easy to over-engineer for hypothetical scale.

## Clarifying Questions

These questions are important, but they do not block creation of a conceptual design. They do block hardening it into a more specific architecture.

1. Should generated artifacts be committed to the repository for downstream GitOps consumption, or should they remain build outputs produced by CI or release workflows?
2. Are the semantic labels meant to be a small, curated vocabulary, or is the long-term goal a broad domain-specific authoring model?
3. Will reference datasets live primarily in the repository, or do they need a reliable path from external systems of record?
4. What level of provenance is expected for operators: simple input references, or a deeper explanation of which conventions and policies selected each important value?
5. How much freedom should teams have to make one-off exceptions when the shared conventions do not fit a workload?
6. What is the first real downstream configuration domain this system is supposed to generate for? The right architecture can stay general, but the first validation target should be concrete.

## Recommended Design Principles

To maximize the chances of success, the implementation direction should follow these principles:

- Prefer a small semantic vocabulary before attempting a rich ontology.
- Keep all build inputs deterministic and versioned.
- Treat explainability as a feature, not a follow-up.
- Validate at boundaries rather than trying to schema-everything internally.
- Make shared conventions centrally governed and intentionally limited.
- Support explicit exceptions, but make them visible and reviewable.
- Optimize for diff clarity and reviewer trust, not only generation power.
- Start with one concrete domain and prove the workflow before generalizing.

## Suggested Validation Path

Before investing heavily in a generalized platform, the repository should prove the model with a narrow but real slice:

1. Pick one concrete configuration domain with obvious duplication and repeated policy logic.
2. Define a small set of semantic declarations that are easy to explain.
3. Add a small reference dataset with clear ownership.
4. Generate a meaningful set of YAML or JSON outputs from that input.
5. Validate that Bazel rebuilds only affected artifacts.
6. Validate that reviewers can understand both the generated diff and the reason for the diff.
7. Observe where the first exceptions appear, and use that to refine the override model.

If that slice works, the broader architecture becomes much more credible.

## Overall Assessment

The proposed system is fundamentally implementable.

The architecture is coherent, and the tool choices are aligned with the problem:

- Jsonnet is a strong fit for compositional configuration synthesis.
- Bazel is a strong fit for deterministic large-scale orchestration.
- Schema support is useful at boundaries.
- Versioned datasets can provide the reference context needed for meaningful generation.

The main architectural concern is not low-level feasibility. It is governance and operability:

- Can semantic intent remain understandable?
- Can outputs remain explainable?
- Can overrides remain controlled?
- Can reference data remain deterministic and trustworthy?

If those questions are handled deliberately, this project has a solid conceptual foundation.
