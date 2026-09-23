---
name: workflow-implementation
description: 승인된 story·하위 태스크를 worktree, 테스트 우선 구현, stack 계획과 재개 기록으로 수행한다.
---

# 실제 작업

승인된 Jira 등 업무툴의 story·작업·하위 태스크를 원천으로 삼아 로컬 구현을 수행한다. story의 기록에서 직접 구현과 위임 계약 경로를 먼저 확인한다. mode는 자연어 기록이면 충분하며 새 Jira custom field나 상태를 강제하지 않는다.

직접 구현 경로에서 코드 변경 전에는 선택한 child가 실제 존재하고 올바른 parent에 연결됐는지, 필수 내용과 최신 spec이 있는지 확인한다. parent의 구현계획 bullet, local TODO, handoff만으로 child가 존재한다고 간주하지 않는다. child가 없거나 parent 연결·내용·readback이 부족하면 `$workflow-story-design`으로 돌아가 필요한 정의, 승인, 생성과 readback을 수행하도록 요청하고 의존 코드 변경은 보류한다.

위임 계약 story를 수임 개발자가 시작하면, 기존 범위·AC·확정 제약을 보존한 채 상세 spec을 작성·검토하고 실행 하위 태스크를 생성·readback한 뒤 코드를 변경한다. 이 경로에서 하위 태스크가 없는 것은 정상 상세화 단계이며 오류나 차단이 아니다. 기존 story의 내용과 승인 범위를 보존하고 같은 티켓에서 상세화·승인한다. 이 skill은 사용자가 두 단계를 별도로 지시한 경우까지 끝에서 끝으로 자동 실행하도록 강요하지 않는다.

조사와 초안 준비는 계속할 수 있다. 사용자에게서 명시적인 ticketless 예외가 있을 때만 그 예외와 근거를 기록한다. Jira 상태 전환 권한이 없다는 사실은 승인된 로컬 구현 자체를 막는 이유가 아니다.

시작과 재개 시 다음을 비교한다.

- source key·링크·수정 시각과 승인 범위
- 현재 Git 상태와 stack 상태
- parent AC와 선택 child의 완료조건·검증 매핑, 선행 child 상태

업무툴이나 공유 문서에 기록할 변경은 승인용 초안으로만 준비한다.

티켓이 기준이면 기본 branch는 `feature/<TICKET>`이고 기본 worktree는 `/Users/goorm/Documents/worktree/<repo>-<TICKET>`이다. 하나의 story는 하나의 worktree에서 수행하고, 하위 태스크는 stack branch로 쌓는다. base branch, 경로, branch 이름이 프로젝트 근거와 다르면 그 근거를 우선한다. release base를 확인하지 못하면 구현 전에 결정한다.

각 인수조건에 필요한 의미 있는 테스트를 먼저 작성한다. RED가 대상 동작의 의도된 실패인지 확인한 뒤 구현하고, unit·integration·E2E를 기계적으로 모두 강제하지 않는다. 관련 없는 사용자 변경은 보존한다.

재개 기록은 저장소 관례를 우선하며, 없으면 `.agents/work/<ticket>/handoff.md`에 제한된 항목만 기록한다. `gh stack init`, `gh stack add`, commit·push·submit은 공통 규칙의 승인 경계를 지킨다. 로컬 branch/stack 계획과 commit·PR 초안은 만들 수 있지만 원격 또는 Git 이력 변경은 승인 전에 실행하지 않는다.

공통 권한·기록·완료 규칙은 [development-workflow.md](../../references/development-workflow.md)를 읽고 따른다.
