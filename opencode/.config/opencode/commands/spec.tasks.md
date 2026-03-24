---
description: Generate an actionable, dependency-ordered tasks.md for the feature based on available design artifacts.
handoffs:
  - label: Implement Project
    agent: spec.implement
    prompt: Start the implementation in phases
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Context Resolution

Determine `FEATURE_DIR` using this priority order:

1. If `$ARGUMENTS` contains a path, use that.
2. If the current conversation already has a confirmed `FEATURE_DIR`, use that.
3. Search `specs/` in the current working directory for the most recently modified `plan.md` and use its parent directory.
4. If none found, stop and instruct the user to run `/spec.plan` first.

Set:
- `TASKS_FILE` = `FEATURE_DIR/tasks.md`

Check which design documents exist in `FEATURE_DIR`:
- **Required**: `plan.md`, `spec.md`
- **Optional**: `data-model.md`, `contracts/`, `research.md`

If `plan.md` or `spec.md` are missing, stop and instruct the user to run `/spec.plan` first.

## Outline

### Step 1 — Load Design Documents

- Read `plan.md`: extract tech stack, libraries, project structure, phase breakdown
- Read `spec.md`: extract user stories with their priorities (P1, P2, P3…)
- If `data-model.md` exists: extract entities and map to user stories
- If `contracts/` exists: map interface contracts to user stories
- If `research.md` exists: extract technical decisions for setup tasks

### Step 2 — Generate Tasks

Organize tasks by user story to enable independent implementation and testing.

**Mapping rules**:
- From user stories (spec.md) → PRIMARY ORGANIZATION: each user story gets its own phase
- From data model: map each entity to the user story(ies) that need it; if entity serves multiple stories, put in earliest story or Setup phase
- From contracts: map each interface contract to the user story it serves
- From setup/infrastructure: shared infrastructure → Setup phase; blocking tasks → Foundational phase

**Phase structure**:
- **Phase 1**: Setup (project initialization, dependencies, configuration)
- **Phase 2**: Foundational (blocking prerequisites — MUST complete before user stories)
- **Phase 3+**: User Stories in priority order (P1, P2, P3…)
  - Within each story: Models → Services → Interfaces/Endpoints → Integration
  - Each phase should be a complete, independently testable increment
- **Final Phase**: Polish & Cross-Cutting Concerns (logging, error handling, performance, docs)

**Tests are OPTIONAL**: Only generate test tasks if explicitly requested in the spec or by the user.

### Step 3 — Write `TASKS_FILE`

Write `FEATURE_DIR/tasks.md` with this structure:

```markdown
# Tasks: [FEATURE NAME]

**Plan**: [link to plan.md]
**Spec**: [link to spec.md]
**Generated**: [DATE]

## Phase 1: Setup

- [ ] T001 [task description with file path]

## Phase 2: Foundational

- [ ] T002 [task description with file path]

## Phase 3: [User Story 1 Title] (P1)

**Story Goal**: [one-sentence goal from spec]
**Independent Test**: [how to verify this story works standalone]

- [ ] T003 [P] [US1] [task description with file path]
- [ ] T004 [US1] [task description with file path]

## Phase 4: [User Story 2 Title] (P2)

**Story Goal**: [one-sentence goal from spec]
**Independent Test**: [how to verify this story works standalone]

- [ ] T010 [P] [US2] [task description with file path]

## Final Phase: Polish & Cross-Cutting

- [ ] T020 [task description]

## Dependencies

[Dependency graph showing story completion order]

## Parallel Execution Opportunities

[Examples of tasks that can run concurrently per story]

## Implementation Strategy

- MVP scope: [typically just User Story 1]
- Incremental delivery: [story-by-story delivery plan]
```

### Step 4 — Task Format Rules (CRITICAL)

Every task MUST strictly follow this format:

```
- [ ] [TaskID] [P?] [Story?] Description with file path
```

**Components**:
1. **Checkbox**: ALWAYS start with `- [ ]`
2. **Task ID**: Sequential number in execution order (T001, T002, T003…)
3. **[P] marker**: Include ONLY if task is parallelizable (different files, no dependency on incomplete tasks)
4. **[Story] label**: REQUIRED for user story phase tasks only
   - Format: `[US1]`, `[US2]`, `[US3]` (maps to user stories from spec.md)
   - Setup, Foundational, and Polish phases: NO story label
5. **Description**: Clear action with exact file path

**Examples**:
- `- [ ] T001 Create project structure per implementation plan` ✅
- `- [ ] T005 [P] Implement authentication middleware in src/middleware/auth.js` ✅
- `- [ ] T012 [P] [US1] Create User model in src/models/user.js` ✅
- `- [ ] T014 [US1] Implement UserService in src/services/user_service.js` ✅
- `- [ ] Create User model` ❌ (missing ID and story label)
- `- [ ] T001 [US1] Create model` ❌ (missing file path)

### Step 5 — Report

Output:
- Path to generated `tasks.md`
- Total task count
- Task count per user story
- Parallel opportunities identified
- Independent test criteria for each story
- Suggested MVP scope (typically User Story 1 only)
- Format validation: confirm ALL tasks follow the checklist format
- Suggested next command: `/spec.implement`
