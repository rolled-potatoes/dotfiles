---
description: Create a feature specification from a natural language feature description.
handoffs:
  - label: Clarify Spec Requirements
    agent: spec.clarify
    prompt: Clarify specification requirements
    send: true
  - label: Build Technical Plan
    agent: spec.plan
    prompt: Create a plan for the spec
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. If `$ARGUMENTS` is empty, ask the user for a feature description before continuing.

## Context Resolution

Determine the `SPECS_DIR` and next feature number as follows:

1. Look for a `specs/` directory in the current working directory. If it doesn't exist, create it.
2. Scan `specs/` for existing feature directories named `{###-*}` and find the highest number. Next number = highest + 1 (zero-padded to 3 digits). If none exist, start at `001`.
3. Generate a short name (2-4 words, kebab-case) from the feature description using action-noun format (e.g., `user-auth`, `analytics-dashboard`, `fix-payment-timeout`).
4. Set:
   - `FEATURE_DIR` = `specs/{###-short-name}/`
   - `SPEC_FILE` = `specs/{###-short-name}/spec.md`
   - `CHECKLIST_FILE` = `specs/{###-short-name}/checklists/requirements.md`

Create the directories (`FEATURE_DIR` and `FEATURE_DIR/checklists/`) if they don't exist.

## Outline

Given the feature description in `$ARGUMENTS`, execute the following steps:

1. **Parse** the feature description. Extract key concepts: actors, actions, data, constraints.

2. **For unclear aspects**:
   - Make informed guesses based on context and industry standards.
   - Only mark with `[NEEDS CLARIFICATION: specific question]` if:
     - The choice significantly impacts feature scope or user experience
     - Multiple reasonable interpretations exist with different implications
     - No reasonable default exists
   - **LIMIT: Maximum 3 `[NEEDS CLARIFICATION]` markers total**
   - Prioritize: scope > security/privacy > user experience > technical details

3. **Write `SPEC_FILE`** using the spec template structure below. Replace all placeholders with concrete details derived from the feature description.

4. **Specification Quality Validation**: After writing the initial spec, validate it:

   a. **Create `CHECKLIST_FILE`** with this structure:

      ```markdown
      # Specification Quality Checklist: [FEATURE NAME]

      **Purpose**: Validate specification completeness and quality before proceeding to planning
      **Created**: [DATE]
      **Feature**: [Link to spec.md]

      ## Content Quality

      - [ ] No implementation details (languages, frameworks, APIs)
      - [ ] Focused on user value and business needs
      - [ ] Written for non-technical stakeholders
      - [ ] All mandatory sections completed

      ## Requirement Completeness

      - [ ] No [NEEDS CLARIFICATION] markers remain
      - [ ] Requirements are testable and unambiguous
      - [ ] Success criteria are measurable
      - [ ] Success criteria are technology-agnostic (no implementation details)
      - [ ] All acceptance scenarios are defined
      - [ ] Edge cases are identified
      - [ ] Scope is clearly bounded
      - [ ] Dependencies and assumptions identified

      ## Feature Readiness

      - [ ] All functional requirements have clear acceptance criteria
      - [ ] User scenarios cover primary flows
      - [ ] Feature meets measurable outcomes defined in Success Criteria
      - [ ] No implementation details leak into specification

      ## Notes

      - Items marked incomplete require spec updates before `/spec.clarify` or `/spec.plan`
      ```

   b. **Run Validation Check**: Review the spec against each checklist item. For each item, determine pass or fail and document specific issues.

   c. **Handle Validation Results**:

      - **If all items pass**: Mark checklist complete (replace `- [ ]` with `- [x]`) and proceed.

      - **If items fail (excluding `[NEEDS CLARIFICATION]`)**:
        1. List the failing items and specific issues
        2. Update the spec to address each issue
        3. Re-run validation until all items pass (max 3 iterations)
        4. If still failing after 3 iterations, document remaining issues in checklist notes and warn user

      - **If `[NEEDS CLARIFICATION]` markers remain**:
        1. Extract all markers from the spec
        2. **LIMIT CHECK**: If more than 3 markers exist, keep only the 3 most critical and make informed guesses for the rest
        3. For each clarification needed (max 3), present options in this format:

           ```markdown
           ## Question [N]: [Topic]

           **Context**: [Quote relevant spec section]

           **What we need to know**: [Specific question]

           **Suggested Answers**:

           | Option | Answer | Implications |
           |--------|--------|--------------|
           | A      | [First suggested answer] | [What this means for the feature] |
           | B      | [Second suggested answer] | [What this means for the feature] |
           | C      | [Third suggested answer] | [What this means for the feature] |
           | Custom | Provide your own answer  | [How to provide custom input] |

           **Your choice**: _[Wait for user response]_
           ```

        4. Present all questions together, then wait for user responses (e.g., "Q1: A, Q2: Custom - [details], Q3: B")
        5. Update the spec by replacing each `[NEEDS CLARIFICATION]` marker with the user's answer
        6. Re-run validation after all clarifications are resolved

   d. **Update `CHECKLIST_FILE`** after each validation iteration with current pass/fail status

5. **Report completion**: Feature directory path, spec file path, checklist results, and suggested next command (`/spec.clarify` or `/spec.plan`).

## Spec Template

Use this structure when writing `SPEC_FILE`:

```markdown
# Feature Specification: [FEATURE NAME]

**Created**: [DATE]
**Status**: Draft
**Input**: [original feature description]

## User Scenarios & Testing *(mandatory)*

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### Edge Cases

- What happens when [boundary condition]?
- How does system handle [error scenario]?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST [specific capability]
- **FR-002**: System MUST [specific capability]

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g., "Users can complete X in under 2 minutes"]
- **SC-002**: [Measurable metric, e.g., "System handles 1000 concurrent users"]
```

## General Guidelines

- Focus on **WHAT** users need and **WHY** — not HOW to implement.
- Avoid tech stack, APIs, code structure, and framework references.
- Write for business stakeholders, not developers.
- Every requirement must be testable and unambiguous.
- **Make informed guesses**: Use context and industry standards to fill gaps.
- **Document assumptions**: Record reasonable defaults in an Assumptions section if needed.
- **Reasonable defaults** (don't ask about these):
  - Data retention: Industry-standard practices for the domain
  - Performance targets: Standard web/mobile app expectations
  - Error handling: User-friendly messages with appropriate fallbacks
  - Authentication: Standard session-based or OAuth2 for web apps

### Success Criteria Rules

Success criteria must be:
1. **Measurable**: Include specific metrics (time, percentage, count, rate)
2. **Technology-agnostic**: No frameworks, languages, databases, or tools
3. **User-focused**: Outcomes from user/business perspective
4. **Verifiable**: Testable without knowing implementation details

**Good**: "Users can complete checkout in under 3 minutes"
**Bad**: "API response time is under 200ms" (too technical)
