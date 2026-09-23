---
name: workflow-implementation
description: 승인된 story·하위 태스크를 worktree, 테스트 우선 구현, stack 계획과 재개 기록으로 수행한다.
---

# 실제 작업

승인된 Jira 등 업무툴의 story·작업·하위 태스크를 원천으로 삼아 로컬 구현을 수행한다. 시작과 재개 시 다음을 비교한다.

- source key·링크·수정 시각과 승인 범위
- 현재 Git 상태와 stack 상태

업무툴이나 공유 문서에 기록할 변경은 승인용 초안으로만 준비한다.

티켓이 기준이면 기본 branch는 `feature/<TICKET>`이고 기본 worktree는 `/Users/goorm/Documents/worktree/<repo>-<TICKET>`이다. 하나의 story는 하나의 worktree에서 수행하고, 하위 태스크는 stack branch로 쌓는다. base branch, 경로, branch 이름이 프로젝트 근거와 다르면 그 근거를 우선한다. release base를 확인하지 못하면 구현 전에 결정한다.

각 인수조건에 필요한 의미 있는 테스트를 먼저 작성한다. RED가 대상 동작의 의도된 실패인지 확인한 뒤 구현하고, unit·integration·E2E를 기계적으로 모두 강제하지 않는다. 관련 없는 사용자 변경은 보존한다.

재개 기록은 저장소 관례를 우선하며, 없으면 `.agents/work/<ticket>/handoff.md`에 제한된 항목만 기록한다. `gh stack init`, `gh stack add`, commit·push·submit은 공통 규칙의 승인 경계를 지킨다. 로컬 branch/stack 계획과 commit·PR 초안은 만들 수 있지만 원격 또는 Git 이력 변경은 승인 전에 실행하지 않는다.

공통 권한·기록·완료 규칙은 [development-workflow.md](../../references/development-workflow.md)를 읽고 따른다.
