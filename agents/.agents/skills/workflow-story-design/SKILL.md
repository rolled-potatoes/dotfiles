---
name: workflow-story-design
description: 승인된 epic을 독립 계약의 story·작업, 인수조건, 상세 계획과 하위 태스크 초안으로 분해한다.
---

# Story·작업 설계

승인된 epic과 방향 기술 설계서를 독립적으로 수행 가능한 story 또는 작업으로 나누고, 사람이 검토할 상세 계획과 실행 하위 태스크 초안을 만든다.

원천 epic과 최신 프로젝트 근거를 다시 확인한다. 같은 완료조건을 공유하는 server·client 작업을 형식적으로 분리하지 않는다. 각 story는 책임·변경 범위·의존성·완료조건이 분명한 계약이어야 한다.

각 story 또는 작업에는 인수조건과 다음 상세 설계를 포함한다.

- API의 parameter·response·error, 필요한 ENUM·schema·migration
- 별도 배포 시스템의 wire compatibility와 프로젝트별 책임 경계
- 각 인수조건과 단위·통합·E2E 등 검증 근거의 명확한 연결
- 위험, 호환성, 미결정 사항과 사람 검토가 필요한 선택

상세 계획과 인수조건을 사람이 검토해 최종화하기 전에는 실행 태스크나 외부 티켓을 만들지 않는다. 최종화 뒤에는 구현 단위의 하위 태스크 초안을 만들고, 하위 태스크 완료와 상위 작업 완료의 차이를 공통 규칙대로 표시한다.

공통 권한·기록·완료 규칙은 [development-workflow.md](../../references/development-workflow.md)를 읽고 따른다.
