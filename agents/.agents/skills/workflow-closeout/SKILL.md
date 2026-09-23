---
name: workflow-closeout
description: 승인된 병합 뒤 업무 상태·epic 요약·worktree 정리를 안전하게 준비하고 확인한다.
---

# 정리

PR 병합과 close는 사람이 명시적으로 지시한 경우에만 실행한다. 승인된 병합 뒤에는 원격의 실제 병합 상태와 포함된 변경을 확인한다. 상위 story/task 상태 변경과 epic의 짧은 작업 요약은 승인용 초안을 먼저 만들고, 승인 뒤 반영한 다음 readback한다.

worktree 정리도 별도 승인 대상이다. 삭제 전 정확한 경로·branch, dirty·untracked 파일, 미병합 local commit, 다른 세션의 사용 여부를 확인한다. 안전한 제거만 실행하며 `--force`는 사용하지 않는다. stack의 restack·삭제가 필요하면 선후행 branch와 원격 영향도 승인용 범위에 포함한다.

원격 병합 확인 전에는 상위 story/task 완료를 제안하지 않는다. 하위 태스크는 이미 구현·검증 시점의 완료 후보와 상태 변경 결과를 구분해 보고한다.

공통 권한·기록·완료 규칙은 [development-workflow.md](../../references/development-workflow.md)를 읽고 따른다.
