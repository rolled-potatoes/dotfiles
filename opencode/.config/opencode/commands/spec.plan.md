---
description: Execute the implementation planning workflow — generate research, data model, and interface contracts from the feature spec.
handoffs:
  - label: Create Tasks
    agent: spec.tasks
    prompt: Break the plan into tasks
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Context Resolution

Determine `FEATURE_DIR` and `SPEC_FILE` using this priority order:

1. If `$ARGUMENTS` contains a path, use that.
2. If the current conversation already has a confirmed `FEATURE_DIR`, use that.
3. Search `specs/` in the current working directory for the most recently modified `spec.md` and use its parent directory.
4. If none found, stop and instruct the user to run `/spec.specify` first.

Set:
- `SPEC_FILE` = `FEATURE_DIR/spec.md`
- `IMPL_PLAN` = `FEATURE_DIR/plan.md`
- `RESEARCH` = `FEATURE_DIR/research.md`
- `DATA_MODEL` = `FEATURE_DIR/data-model.md`
- `CONTRACTS_DIR` = `FEATURE_DIR/contracts/`

Also check if `specs/constitution.md` exists in the current working directory. If it does, load it as the project constitution for gate validation.

## Outline

### Step 1 — Load Context

1. Read `SPEC_FILE` — extract user stories (with priorities), functional requirements, success criteria, key entities.
2. If `specs/constitution.md` exists, load it and note any architectural constraints, technology decisions, or quality gates.
3. Read the Plan Template (see below) to understand the required structure for `IMPL_PLAN`.

### Step 2 — Build Technical Context

From the spec, identify and document:

- **Tech Stack**: Detect from existing project files (e.g., `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`). If no project files exist, make a reasonable choice based on feature description and mark as assumption.
- **Key Dependencies**: Libraries, frameworks, external services likely needed
- **Project Structure**: Inferred from existing files or determined fresh
- **Integration Points**: External APIs, databases, message queues, file systems
- **Unknowns**: Mark as `NEEDS CLARIFICATION` — these become Phase 0 research tasks

If constitution exists, run a **Constitution Check**: verify Technical Context does not violate any constitutional constraints. ERROR if violations exist and are not justified.

### Step 3 — Phase 0: Research

For each `NEEDS CLARIFICATION` in Technical Context and each key dependency:

1. Generate research tasks:
   - For each unknown → "Research {unknown} for {feature context}"
   - For each dependency → "Find best practices for {tech} in {domain}"
   - For each integration → "Find integration patterns for {service}"

2. Dispatch research agents (use Task tool) to resolve each unknown in parallel where possible.

3. Consolidate findings into `RESEARCH` file:

   ```markdown
   # Research: [FEATURE NAME]

   ## [Topic]

   - **Decision**: [what was chosen]
   - **Rationale**: [why chosen]
   - **Alternatives considered**: [what else was evaluated]
   ```

4. All `NEEDS CLARIFICATION` items must be resolved before proceeding to Phase 1.

### Step 4 — Phase 1: Design & Contracts

**Prerequisites**: `RESEARCH` complete, all unknowns resolved.

#### 4a. Data Model (`DATA_MODEL`)

Extract entities from `SPEC_FILE` and `RESEARCH`:

```markdown
# Data Model: [FEATURE NAME]

## [Entity Name]

- **Fields**: [field name: type, constraints]
- **Relationships**: [related entity: type of relationship]
- **Validation rules**: [rules derived from requirements]
- **State transitions**: [if applicable]
```

Only create this file if the feature involves persistent data or domain entities.

#### 4b. Interface Contracts (`CONTRACTS_DIR`)

Identify what interfaces the project exposes to users or other systems. Document the contract format appropriate for the project type:

- **Web services**: Endpoint definitions, request/response shapes, error codes
- **Libraries**: Public API signatures, expected inputs/outputs
- **CLI tools**: Command schemas, flags, output formats
- **UI applications**: Component contracts, user interaction flows

Skip `CONTRACTS_DIR` entirely if the project is purely internal (build scripts, one-off tools, etc.).

#### 4c. Implementation Plan (`IMPL_PLAN`)

Write `IMPL_PLAN` using this structure:

```markdown
# Implementation Plan: [FEATURE NAME]

**Spec**: [link to spec.md]
**Created**: [DATE]
**Status**: Draft

## Technical Context

- **Tech Stack**: [detected or chosen stack]
- **Key Dependencies**: [libraries and frameworks]
- **Project Structure**: [directory layout]
- **Integration Points**: [external systems]

## Architecture Overview

[High-level description of how the feature will be implemented]

## Phase Breakdown

### Phase 1: Setup
[What needs to be initialized or configured]

### Phase 2: Foundational
[Blocking prerequisites for all user stories]

### Phase 3+: User Stories (in priority order)
[One section per user story from spec.md]

### Final Phase: Polish & Cross-cutting
[Logging, error handling, performance, documentation]

## Technical Decisions

[Key decisions made, with rationale from research.md]

## Risks & Mitigations

[Known risks and how they are addressed]

## Constitution Compliance

[If constitution.md exists: list each constraint and whether it is satisfied]
```

### Step 5 — Report

Output:
- `IMPL_PLAN` path and status
- `RESEARCH` path and list of resolved decisions
- `DATA_MODEL` path (if created)
- `CONTRACTS_DIR` path (if created)
- Suggested next command: `/spec.tasks`

## Key Rules

- Use absolute paths when referencing files
- ERROR on constitution gate failures or unresolved clarifications after Phase 0
- Do not proceed to Phase 1 until all `NEEDS CLARIFICATION` are resolved
- Keep `IMPL_PLAN` technology-aware but architecture-focused — avoid over-specifying implementation details
- Each phase in the plan must map directly to user stories from the spec
