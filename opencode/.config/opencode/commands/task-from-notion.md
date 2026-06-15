---
description: Execute a Notion task through a gated git-flow workflow using the task ID as the feature branch name.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. `$ARGUMENTS` must contain exactly one Notion task URL.

## Role

You execute a development task described in a Notion database page.

The Notion task is the source of truth. Read it, clarify it with the user, create the correct git-flow feature branch, plan the implementation, ask for approval, then implement only the approved work.

## Core Rules

- Do not edit files before Approval Gate 2.
- Do not create or switch branches before Approval Gate 1.
- Do not update the Notion task before the relevant approval gate.
- Do not guess missing requirements. Ask concise questions instead.
- When clarification is needed, present the questions under a section named `Clarifying Questions`.
- Always use Korean when presenting results, questions, approvals, plans, progress, and final reports to the user.
- Respect explicit exclusions in the Notion task and user follow-up messages.
- If investigation finds no valid change target, report that clearly and do not force edits.
- Never use destructive git commands.
- Use the Notion `userDefined:ID` property as the git-flow feature name.
- Branch format is `feature/<ID>`, created with `git flow feature start <ID>`.
- If git-flow is unavailable or not initialized, stop and ask the user how to proceed.
- Treat the Notion task page as the external work log. Keep it updated after approvals and after each completed checklist item.
- Before creating or updating Notion page content, fetch `notion://docs/enhanced-markdown-spec` and use the supported Notion Markdown syntax.
- Preserve the user's existing Notion content. Append or update only the AI-managed sections listed in this command.

## Step 1 - Fetch Notion Task

1. Fetch the Notion task page from `$ARGUMENTS`.
2. Extract these values when present:
   - `userDefined:ID`
   - `이름`
   - `상태`
   - `담당자`
   - `Tags`
   - `담당 unit`
   - `우선순위`
   - `마감일`
   - task body
3. Extract the working directory from the body. Prefer a line like `작업 디렉토리: /absolute/path`.

If the URL is missing or the page cannot be fetched, stop and ask for a valid Notion task URL.

If `userDefined:ID` is missing, stop and explain that the task cannot create a git-flow feature branch without the Notion ID.

If the working directory is missing, ask the user for the project directory before continuing.

## Step 2 - Interpret The Spec

Summarize the task using this structure:

```markdown
**Task Summary**
- Notion task: <title>
- ID: <ID>
- Working directory: <absolute path>
- Proposed branch: feature/<ID>
- Current status: <status>

**Spec**
- Problem:
- Expected result:
- Completion criteria:
- References:
- Exclusions:

**Clarifying Questions**
- ...
```

Use the Notion body as the primary source. Use database properties only as metadata.

If any of these are missing or unclear, ask questions and stop:

- Problem to solve
- Expected result
- Completion criteria
- Exclusions or non-goals
- Working directory

Ask clarification questions in this format:

```markdown
**Clarifying Questions**
- ...
```

The section title must stay in English as `Clarifying Questions`; write the questions themselves in Korean.

## Approval Gate 1 - Confirm Spec And Branch

Ask the user to approve:

```text
Approve Gate 1?
- Spec interpretation
- Working directory
- Branch creation with: git flow feature start <ID>
```

Do not continue until the user explicitly approves.

## Step 3 - Record Gate 1 In Notion

After Gate 1 approval and before creating the branch, update the Notion task page.

Create or update an AI-managed section named `AI 작업 기록` with:

- Approved spec interpretation
- Working directory
- Branch to create: `feature/<ID>`
- Approval timestamp
- Remaining open questions, if any

Rules:

- Do not overwrite user-authored task content.
- If `AI 작업 기록` already exists, append a new dated entry instead of replacing unrelated history.
- If the Notion update fails, report the failure and ask whether to continue without Notion tracking or retry.

## Step 4 - Create Feature Branch

After Gate 1 approval:

1. Verify the working directory exists.
2. Verify it is a git repository.
3. Check current git status and current branch.
4. Run `git flow feature start <ID>`.
5. Verify the current branch is `feature/<ID>`.

If `git flow feature start <ID>` fails:

- Do not fall back silently.
- Report the failure.
- Ask whether to initialize git-flow, create `feature/<ID>` manually, or stop.

After the branch is created successfully, append the branch creation result to `AI 작업 기록`.

## Step 5 - Investigate Codebase

Read and search the codebase to build an implementation plan.

Identify:

- Relevant files
- Existing patterns
- Candidate changes
- Explicitly excluded files or code paths
- Verification commands from package scripts or project docs
- Risks and unknowns

Do not edit files during this step.

## Approval Gate 2 - Confirm Development Plan

Present a concrete implementation plan:

```markdown
**Development Plan**
- Change target:
- Proposed changes:
- Excluded from change:
- Verification:
- Risks:

Approve Gate 2 to start implementation?
```

Do not edit files until the user explicitly approves.

If investigation shows no valid change target:

- Report `No code changes needed`.
- Explain why each candidate is excluded or already compliant.
- Ask whether to record the task as no-op in Notion, adjust scope, or expand investigation.

## Step 6 - Record Gate 2 In Notion

After Gate 2 approval and before editing files, update the Notion task page.

Create or update an AI-managed section named `AI 개발 계획` with:

- Approved change targets
- Proposed changes
- Explicit exclusions
- Verification commands
- Risks and assumptions
- Approval timestamp

Create or update an AI-managed section named `AI 작업 체크리스트`.

Checklist rules:

- The checklist must reflect the actual approved development plan.
- Each checklist item must be concrete and verifiable.
- Include branch creation confirmation if the branch was created.
- Include implementation steps only for approved change targets.
- Include verification steps.
- Include final Notion result update.

Example:

```markdown
## AI 작업 체크리스트

- [x] feature/<ID> 브랜치 생성 확인
- [ ] 변경 대상 파일 수정
- [ ] 관련 검색으로 잔여 대상 확인
- [ ] 검증 명령 실행
- [ ] AI 작업 결과 기록
```

If the investigation found no valid change target and the user approves no-op handling, create a no-op checklist instead:

```markdown
## AI 작업 체크리스트

- [x] feature/<ID> 브랜치 생성 확인
- [x] 변경 후보 조사
- [x] 제외 범위 확인
- [ ] AI 작업 결과 기록
```

After writing the checklist, register the same checklist items with TodoWrite when the task has more than one item.

If the Notion update fails, report the failure and ask whether to continue without Notion tracking or retry.

## Step 7 - Implement

After Gate 2 approval:

1. Make the smallest correct changes.
2. Stay within the approved scope.
3. If new ambiguity appears, stop and ask.
4. Do not modify unrelated files.
5. Do not revert user changes.
6. After each checklist item is completed, immediately update both TodoWrite and the Notion `AI 작업 체크리스트` item from unchecked to checked.
7. If Notion checklist updates fail, continue only after telling the user and recording the failure for the final report.

## Step 8 - Verify

Run the most relevant verification commands.

Prefer narrow verification first, then broader checks if needed:

- package-level lint/test
- changed package build
- repository lint/test if reasonable

If verification cannot run, explain why.

After verification completes, update the relevant verification checklist item in Notion.

## Step 9 - Record Final Result In Notion

Before the final response, update the Notion task page.

Create or update an AI-managed section named `AI 작업 결과` with:

- Branch name
- Files changed
- What changed
- No-op result, if no code changes were needed
- Verification commands and results
- Remaining risks
- Suggested next action
- Completion timestamp

Then mark the `AI 작업 결과 기록` checklist item as complete.

If the final Notion update fails, include the failure in the final response.

## Step 10 - Report

Final response must include:

- Branch name
- Files changed
- What changed
- Verification result
- Notion tracking update result
- Remaining risks or follow-up
