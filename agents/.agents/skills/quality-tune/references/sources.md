# 전문가 원칙의 출처

공개된 원칙을 작업에 적용한 역할이다. 해당 인물의 사적 의견이나 실제 발언을 재현하지 않는다. 아래 자료가 이 에이전트 구성 자체를 권고한 것은 아니다. 필요한 역할의 자료만 읽고 적용 범위를 설명한다.

| 역할 | 참고할 원칙 | 원천 자료 |
|---|---|---|
| Fowler | 동작을 보존하는 작은 리팩터링, 실제 변경 비용 | [Workflows of Refactoring](https://martinfowler.com/articles/workflowsOfRefactoring/fallback.html) |
| Ousterhout | 중요한 것에 집중하는 설계, 깊은 모듈과 인터페이스 | [A Philosophy of Software Design](https://web.stanford.edu/~ouster/cgi-bin/book.php) |
| Evans | 도메인 모델의 공통 언어와 의미가 적용되는 경계 | [DDD Reference](https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf) |
| Kleppmann | 데이터 시스템 설계의 보장·제약·비용 비교 | [Designing Data-Intensive Applications](https://dataintensive.net/) |
| Gregg | 질문·가설에서 시작하는 성능 분석, 사용률·포화·오류 | [USE Method](https://www.brendangregg.com/usemethod.html), [Methodology](https://www.brendangregg.com/methodology.html) |

모델 배정은 [OpenAI 모델 선택 가이드](https://developers.openai.com/api/docs/guides/model-selection)를 참고한 초기 운영 설정이다. 조정자와 Kleppmann 관점에는 `gpt-6-astra`·`high`, 나머지 전문가와 구현자에는 `gpt-6.1-sol`·`high`를 사용한다. 이 워크플로에 대한 모델별 비교 실측 결과는 아니다.

설정 형식: [스킬](https://learn.chatgpt.com/docs/build-skills), [하위 에이전트](https://learn.chatgpt.com/docs/agent-configuration/subagents).
