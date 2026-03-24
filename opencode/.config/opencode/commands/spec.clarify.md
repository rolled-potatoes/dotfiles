---
description: Identify underspecified areas in the current feature spec by asking up to 5 targeted clarification questions and encoding answers back into the spec.
handoffs:
  - label: Build Technical Plan
    agent: spec.plan
    prompt: Create a plan for the spec
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Context Resolution

Determine `SPEC_FILE` using this priority order:

1. If `$ARGUMENTS` contains a path, use that.
2. If the current conversation already has a confirmed `SPEC_FILE`, use that.
3. Search `specs/` in the current working directory for the most recently modified `spec.md`.
4. If none found, stop and instruct the user to run `/spec.specify` first.

## Outline

**Goal**: Detect and reduce ambiguity or missing decision points in the active feature specification, and record clarifications directly in the spec file.

**Note**: This workflow is expected to run (and be completed) BEFORE invoking `/spec.plan`. If the user explicitly states they are skipping clarification (e.g., exploratory spike), warn that downstream rework risk increases.

### Step 1 — Load and Scan

Load `SPEC_FILE`. Perform a structured ambiguity & coverage scan using this taxonomy. For each category, mark status: **Clear / Partial / Missing**.

Produce an internal coverage map used for prioritization (do not output raw map unless no questions will be asked).

**Taxonomy**:

- **Functional Scope & Behavior**: Core user goals, success criteria, out-of-scope declarations, user roles/personas
- **Domain & Data Model**: Entities, attributes, relationships, identity rules, lifecycle/state transitions, data volume
- **Interaction & UX Flow**: Critical user journeys, error/empty/loading states, accessibility notes
- **Non-Functional Quality Attributes**: Performance, scalability, reliability, observability, security/privacy, compliance
- **Integration & External Dependencies**: External services/APIs, failure modes, data formats, protocol assumptions
- **Edge Cases & Failure Handling**: Negative scenarios, rate limiting, conflict resolution
- **Constraints & Tradeoffs**: Technical constraints, explicit tradeoffs, rejected alternatives
- **Terminology & Consistency**: Canonical glossary terms, avoided synonyms
- **Completion Signals**: Acceptance criteria testability, measurable Definition of Done indicators
- **Misc / Placeholders**: TODO markers, ambiguous adjectives ("robust", "intuitive") lacking quantification

For each category with Partial or Missing status, add a candidate question opportunity unless:
- Clarification would not materially change implementation or validation strategy
- Information is better deferred to planning phase

### Step 2 — Prioritize Questions

Generate (internally) a prioritized queue of candidate clarification questions (maximum 5). Apply these constraints:

- Maximum 5 total questions across the whole session
- Each question must be answerable with either a short multiple-choice selection (2–5 options) or a short answer (≤5 words)
- Only include questions whose answers materially impact architecture, data modeling, task decomposition, test design, UX behavior, operational readiness, or compliance validation
- Ensure category coverage balance: cover highest-impact unresolved categories first
- Exclude questions already answered, trivial stylistic preferences, or plan-level execution details
- Favor clarifications that reduce downstream rework risk or prevent misaligned acceptance tests
- If more than 5 categories remain unresolved, select the top 5 by (Impact × Uncertainty) heuristic

### Step 3 — Sequential Questioning Loop (interactive)

- Present **exactly one question at a time**
- For **multiple-choice questions**:
  - Analyze all options and determine the most suitable one based on best practices, risk reduction, and alignment with project goals
  - Present your recommendation prominently: `**Recommended:** Option [X] - <reasoning>`
  - Render options as a Markdown table:

    | Option | Description |
    |--------|-------------|
    | A      | <Option A description> |
    | B      | <Option B description> |
    | C      | <Option C description> |
    | Short  | Provide a different short answer (≤5 words) |

  - Add: `You can reply with the option letter (e.g., "A"), accept the recommendation by saying "yes" or "recommended", or provide your own short answer.`

- For **short-answer questions**:
  - Provide your suggested answer: `**Suggested:** <your proposed answer> - <brief reasoning>`
  - Add: `Format: Short answer (≤5 words). You can accept the suggestion by saying "yes" or "suggested", or provide your own answer.`

- After the user answers:
  - If the user replies "yes", "recommended", or "suggested", use your previously stated recommendation as the answer
  - Validate the answer; if ambiguous, ask for disambiguation (same question, does not advance counter)
  - Record the accepted answer in working memory and advance to next question

- Stop asking when:
  - All critical ambiguities are resolved early, OR
  - User signals completion ("done", "good", "no more"), OR
  - You reach 5 asked questions

- Never reveal future queued questions in advance
- If no valid questions exist, immediately report no critical ambiguities

### Step 4 — Incremental Spec Update

After EACH accepted answer:

- Maintain in-memory representation of the spec (loaded once at start)
- For the first integrated answer in this session:
  - Ensure a `## Clarifications` section exists (create it just after the highest-level overview section if missing)
  - Under it, create a `### Session YYYY-MM-DD` subheading for today
- Append a bullet: `- Q: <question> → A: <final answer>`
- Apply the clarification to the most appropriate section(s):
  - Functional ambiguity → Update or add bullet in Functional Requirements
  - User interaction / actor distinction → Update User Stories or Actors subsection
  - Data shape / entities → Update Data Model section
  - Non-functional constraint → Add/modify measurable criteria in Non-Functional section
  - Edge case / negative flow → Add bullet under Edge Cases / Error Handling
  - Terminology conflict → Normalize term across spec; add `(formerly referred to as "X")` once if needed
- If the clarification invalidates an earlier ambiguous statement, replace it — do not duplicate
- **Save `SPEC_FILE` after each integration** (atomic overwrite)
- Preserve formatting: do not reorder unrelated sections; keep heading hierarchy intact
- Keep each inserted clarification minimal and testable

### Step 5 — Validation (after each write + final pass)

- Clarifications session contains exactly one bullet per accepted answer (no duplicates)
- Total asked (accepted) questions ≤ 5
- Updated sections contain no lingering vague placeholders
- No contradictory earlier statement remains
- Markdown structure valid; only allowed new headings: `## Clarifications`, `### Session YYYY-MM-DD`
- Terminology consistency: same canonical term used across all updated sections

### Step 6 — Report Completion

After the questioning loop ends or early termination, report:

- Number of questions asked & answered
- Path to updated spec
- Sections touched (list names)
- Coverage summary table:

  | Category | Status |
  |----------|--------|
  | [category name] | Resolved / Deferred / Clear / Outstanding |

- If any Outstanding or Deferred remain, recommend whether to proceed to `/spec.plan` or run `/spec.clarify` again later
- Suggested next command

## Behavior Rules

- If no meaningful ambiguities found, respond: "No critical ambiguities detected worth formal clarification." and suggest proceeding to `/spec.plan`
- If spec file missing, instruct user to run `/spec.specify` first
- Never exceed 5 total asked questions
- Avoid speculative tech stack questions unless absence blocks functional clarity
- Respect user early termination signals ("stop", "done", "proceed")
- If quota reached with unresolved high-impact categories, explicitly flag them under Deferred with rationale

Context for prioritization: $ARGUMENTS
