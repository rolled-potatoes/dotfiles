---
name: bootstrap-project-harness
description: Explicitly inspect a project and, after approval, build or safely update its project-specific engineering harness and evidence loop. Use only when invoked as $bootstrap-project-harness.
---

# Bootstrap Project Harness

Use this skill only by explicit invocation. It is a project-local bootstrapper: it must investigate the current project and must not carry a framework, product, or repository convention into another project.

## Start safely

1. Run `git status --short` before any write. Preserve unrelated user changes.
2. Identify the Git/project root.
3. Infer the target path, `.agents/work/<task-id>/` evidence location, and kebab-case task ID from the request when they are unambiguous. Ask only for an unresolved choice. Do not create files in this step.
4. Read [the discovery guide](references/discovery.md), gather only non-secret evidence, and classify the result as a new harness, partial extension, existing-harness update, or decision required.
5. Before changing code, documentation, configuration, links, or scripts, present only the As-Is, To-Be, files, material compatibility risks, verification, and expected application flow needed to review the change. Wait for explicit approval unless the user has already approved that concrete scope.

## Build or update after approval

Read [the harness contract](references/harness-contract.md) and [the project artifact contract](references/project-artifacts.md).

Adapt the implementation language, command entry points, documentation locations, and verification commands to the project evidence. Keep the logical command names and safety guarantees intact.

Existing harnesses are update candidates, never replacement candidates by default. Before changing an existing `AGENTS.md`, `CLAUDE.md`, project Skill, harness, CI workflow, hook, or document, explain the exact compatible change.

Never replace a regular `CLAUDE.md` or a link with a different target.

## Completion boundary

Run the relevant project checks, the Skill validator, and isolated fixtures for new and update paths. The project’s generated state checker must enforce the contract, or an equivalent native checker must do so.

`harness:commit:check` may report readiness only. Neither it nor this Skill may commit, push, open or edit a PR, deploy, fetch, pull, create a branch, create a worktree, or modify an external system without separately authorized user action.

Use `scripts/validate_harness_state.py` as a portable contract-audit reference when Python is available. If the project cannot use it, implement equivalent checked behavior with the project’s supported runtime and test both success and failure paths.
