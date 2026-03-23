---
description: Execute the implementation plan by processing all tasks defined in tasks.md, tracking progress with TodoWrite, and marking tasks complete as they finish.
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
3. Search `specs/` in the current working directory for the most recently modified `tasks.md` and use its parent directory.
4. If none found, stop and instruct the user to run `/spec.tasks` first.

Set:
- `TASKS_FILE` = `FEATURE_DIR/tasks.md`

## Outline

### Step 1 — Load Implementation Context

Read the following files from `FEATURE_DIR`:
- **REQUIRED**: `tasks.md` — complete task list and execution plan
- **REQUIRED**: `plan.md` — tech stack, architecture, file structure
- **IF EXISTS**: `data-model.md` — entities and relationships
- **IF EXISTS**: `contracts/` — interface specifications
- **IF EXISTS**: `research.md` — technical decisions and constraints

If `tasks.md` or `plan.md` are missing, stop and instruct the user to run `/spec.tasks` first.

### Step 2 — Checklist Status Check

If `FEATURE_DIR/checklists/` exists, scan all checklist files:
- Count total items (`- [ ]` and `- [x]`), completed (`- [x]`), and incomplete (`- [ ]`)
- Display a status table:

  | Checklist | Total | Completed | Incomplete | Status |
  |-----------|-------|-----------|------------|--------|
  | requirements.md | 12 | 12 | 0 | PASS |

- **If any checklist is incomplete**: Display the table and ask "Some checklists are incomplete. Proceed with implementation anyway? (yes/no)". Wait for user response. Stop if "no".
- **If all pass**: Display the table and proceed automatically.

### Step 3 — Parse tasks.md and Register Todos

Parse `TASKS_FILE` and extract all incomplete tasks (`- [ ]`).

**Register all incomplete tasks with TodoWrite** before starting any work:
- Each task becomes a todo item with its Task ID and description as the content
- Set all as `pending` initially
- This gives the user full visibility into the implementation queue

### Step 4 — Execute Tasks Phase by Phase

**Phase-by-phase execution**: Complete each phase entirely before moving to the next.

For each task:

1. **Mark the todo as `in_progress`** (only one task in_progress at a time)
2. **Implement the task** according to the description and file path
3. **Mark the task complete** in `TASKS_FILE`: replace `- [ ]` with `- [x]`
4. **Mark the todo as `completed`** immediately after finishing

**Execution rules**:
- Respect dependencies: run sequential tasks in order
- Parallel tasks `[P]` with no shared file dependencies may be executed together
- If a non-parallel task fails: halt and report the error with context
- For parallel tasks `[P]`: continue with successful tasks, report failed ones separately

**Implementation order within each story phase**:
1. Models / data structures
2. Services / business logic
3. Interfaces / endpoints / UI
4. Integration wiring

### Step 5 — Project Setup Verification (before first code task)

Before writing any code, verify or create necessary ignore files based on detected project type:

- Check for git repo (`git rev-parse --git-dir 2>/dev/null`) → verify/create `.gitignore`
- Check for `Dockerfile*` → verify/create `.dockerignore`
- Check for `package.json` or `.npmrc` → verify/create `.npmignore` (if publishing)
- Check for `.eslintrc*` or `eslint.config.*` → verify/create `.eslintignore`
- Check for `.prettierrc*` → verify/create `.prettierignore`
- Check for `*.tf` files → verify/create `.terraformignore`

**Common patterns by stack** (from `plan.md`):
- **Node.js/TypeScript**: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
- **Python**: `__pycache__/`, `*.pyc`, `.venv/`, `dist/`, `*.egg-info/`
- **Java**: `target/`, `*.class`, `.gradle/`, `build/`
- **Go**: `*.exe`, `*.test`, `vendor/`, `*.out`
- **Rust**: `target/`, `debug/`, `release/`, `*.rs.bk`
- **Universal**: `.DS_Store`, `Thumbs.db`, `*.tmp`, `*.swp`, `.vscode/`, `.idea/`

If an ignore file already exists, only append missing critical patterns.

### Step 6 — Progress Reporting

After each completed phase:
- Report which tasks were completed
- Report any failures with error context and suggested fixes
- Show overall progress: "Phase X complete — Y/Z total tasks done"

### Step 7 — Completion Validation

After all tasks are complete:

1. Verify all `tasks.md` checkboxes are marked `[x]`
2. Verify all TodoWrite todos are marked `completed`
3. Check that implemented features match the original `spec.md` user stories
4. Validate that tests pass (if test tasks were included)
5. Confirm the implementation follows `plan.md`

Report final status:
- Summary of all completed work
- Any outstanding items or known gaps
- Suggested follow-up actions (e.g., running tests, deploying, creating a PR)

## Key Rules

- **Always mark todos `in_progress` before starting** and `completed` immediately after finishing — never batch completions
- **Always update `tasks.md` checkboxes** in sync with todo status
- Never skip a sequential task without halting and reporting
- If implementation cannot proceed (missing context, ambiguous task), report clearly and suggest running the appropriate preceding command
- Keep each task's scope tightly bounded to its description and file path — do not expand scope silently
