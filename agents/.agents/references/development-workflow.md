# 개발 업무 workflow 공통 규칙

이 문서는 업무 설계, story·작업 설계, 구현, 검증, 정리 skill이 함께 쓰는 운영 규칙이다. 업무툴의 승인된 티켓과 연결된 문서가 요구사항의 원천이며, 세션 대화나 로컬 기록은 이를 대체하지 않는다.

## 권한과 기록

현재는 workflow 가설을 검토하는 단계다. 메인은 요구사항, 권한, 단계 전환, 최종 통합을 결정한다. `explorer`는 읽기 조사, `worker`는 승인된 범위의 로컬 구현과 일반 테스트, `verifier`는 독립 검증을 맡는다.

승인된 Git·`gh` 명령은 메인이 직접 실행한다. 승인에는 구체 행동·대상·범위가 있어야 한다. 이 좁은 예외의 대상은 다음과 같다.

- commit과 승인된 `gh stack init`·`add`
- push, `gh stack submit`, PR 생성·변경
- 병합·close와 worktree 삭제

메인의 repository 탐색·구현·파일 수정은 계속 역할 agent에 위임한다.

티켓·공유 문서 작성 또는 상태 전환, 커밋, push, PR 생성·변경, 병합·close, worktree 삭제는 외부 또는 파괴적 변경이다. 실행 전에 대상, 초안 또는 diff, 근거, 예상 영향과 실행 범위를 준비해 승인을 받는다. 승인 뒤에는 같은 범위에서 다시 묻지 않고 실행 결과를 readback한다. 현재 허용되지 않은 자동화 권한을 만들거나 추정하지 않는다.

재개할 때는 업무툴의 source key·링크·최종 수정 시각(또는 revision), 승인 범위, 현재 Git/stack 상태를 비교한다. 정보가 달라졌거나 확인할 수 없으면 최신 티켓을 다시 읽고 차이를 드러낸다.

공유해야 할 결정은 업무툴에 올릴 초안을 먼저 만들고 승인 뒤 기록한다. 로컬 재개 기록은 대화 전체를 복제하지 않는다. 저장소 규칙이 없으면 각 worktree의 `.agents/work/<ticket>/handoff.md`를 기본 위치로 사용한다. 기록에는 source revision, 승인 범위, 새 결정, branch·worktree·stack 대응, 테스트 근거, 다음 행동만 남기며 비밀값을 쓰지 않는다. 이 기본 위치를 쓰기 전에 저장소의 ignore·문서 관례를 확인한다.

## 완료와 상태

하위 태스크는 구현과 검증이 끝나면 완료 후보가 된다. 상위 story 또는 작업은 관련 변경이 실제 병합된 뒤에만 완료 후보가 된다. 업무툴의 `Done` 같은 상태명, 전이, required field를 가정하지 말고 실제 시스템에서 조회한다. 상태 변경도 승인 전에는 초안으로 남기고, 변경 뒤 결과를 다시 읽는다.

## 검증의 신뢰도

요구사항·인수조건마다 어떤 검증이 근거가 되는지 연결한다. 단위·통합·E2E는 인수조건과 위험에 필요한 범위만 작성한다. 테스트 우선 작업에서 RED는 의도한 실패가 대상 동작을 검증할 때만 의미가 있으며 환경·의존성 실패는 RED가 아니다. 실행하지 못한 검증, CI 또는 실제 업무툴·원격 상태는 별도로 표시한다.

원격 반영 전에는 reviewable commit과 PR 설명 초안을 만들 수 있다. 승인된 commit과 PR 생성은 기존 `$commit`, `$create-pr` 지침을 따른다. stack의 base chain과 CI는 실제로 확인하며, 실패 또는 미확인 상태에서 완료를 주장하지 않는다.

## worktree와 stack

프로젝트별 지침 또는 사용자가 다른 경로를 지정하지 않으면 다음을 기본으로 한다.

- story/task 티켓 branch: `feature/<TICKET>`
- worktree: `/Users/goorm/Documents/worktree/<repo>-<TICKET>`
- 하나의 story에는 하나의 worktree, 하위 태스크에는 그 위의 stack branch

release base는 저장소 지침이나 티켓에서 확인할 수 없으면 사람에게 확인한다.

`gh stack`은 설치 여부와 현재 버전을 확인한 뒤에만 사용한다. 현재 CLI 도움말 기준으로 `gh stack init [branches...] --base <trunk>`은 로컬 stack을 초기화하고, `gh stack add [branch]`는 현재 stack 위에 branch를 추가한다. 두 명령도 승인된 계획에 포함될 때만 메인이 실행한다.

`--all` 또는 `--update`와 `--message`는 변경을 stage·commit할 수 있으므로 명시 승인 범위가 필요하다. `gh stack submit --draft`도 원격 GitHub PR을 만들므로 승인 전에는 실행하지 않는다. branch 이름·base·commit 여부가 불명확하면 명령을 실행하지 않는다.

## 정리

병합·close는 사람의 명시 지시가 있을 때만 실행한다. 승인된 병합 뒤에는 원격의 실제 병합 상태를 확인하고, 상위 티켓 상태 변경과 epic 요약은 초안을 검토받아 반영한 뒤 readback한다.

worktree를 지우기 전에는 정확한 경로와 branch, dirty·untracked 파일, 미병합 local commit, 다른 세션의 사용 여부를 확인한다. 안전한 제거만 제안하고 `--force`는 사용하지 않는다. stack 변경 뒤 restack이 필요하면 영향과 안전성을 검토하고 필요한 승인 범위 안에서만 실행한다.
