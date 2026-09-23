---
name: workflow-verification
description: 구현을 테스트·빌드·린트·독립 검토로 확인하고 reviewable commit·PR 초안을 준비한다.
---

# 작업 검증

`worker`가 관련 테스트·빌드·린트를 실행하고, 필요하면 `verifier`가 독립적으로 diff, 인수조건, 저장소 규칙, 미사용 코드를 검토한다. 검증은 저장소가 정의한 명령을 우선하며, 범위를 넓힐 때는 인수조건 또는 위험 근거를 기록한다.

검증 결과는 인수조건별 근거, 실행 명령과 결과, 미실행 항목, 환경 차단 요인, CI·원격 확인 필요 사항을 나눠 보인다. formatter나 코드 생성 같은 구현 변경을 검증으로 가장하지 않는다. 실패 또는 미확인 상태에서는 하위 태스크 완료 후보를 주장하지 않는다.

검증을 통과하면 reviewable commit과 stacked PR 제목·설명 초안을 준비한다. commit, push, `gh stack submit --draft`, PR 생성·수정은 승인 뒤에만 실행하며 `$commit`, `$create-pr`의 지침을 함께 따른다. 실제 생성 뒤에는 stack base chain, CI, PR 상태를 확인한다.

하위 태스크는 구현과 검증이 끝난 뒤에만 상태 전환 초안을 만들 수 있다. 상위 story/task의 완료는 실제 병합을 확인할 때까지 제안하지 않는다.

공통 권한·기록·완료 규칙은 [development-workflow.md](../../references/development-workflow.md)를 읽고 따른다.
