# DDD 산출물 계약

## 목차

1. 권장 문서 집합
2. 문서 언어와 가독성
3. 공통 메타데이터
4. ID와 지식 상태
5. 도메인 모델 계약
6. 도메인 정책 계약
7. 비즈니스 규칙 계약
8. 보조 산출물 계약
9. 완료 품질 기준

## 1. 권장 문서 집합

기존 저장소의 문서 구조가 있으면 그 구조를 유지한다. 구조가 없으면 다음을 사용한다.

```text
docs/domain/
├── index.md
├── decisions.md
└── <bounded-context>/
    ├── domain-model.md
    ├── domain-policies.md
    └── business-rules.md
```

핵심 산출물은 context별 세 문서다.

- `domain-model.md`: 언어, 경계, aggregate, command, state, event, invariant
- `domain-policies.md`: 조건에 따른 domain decision과 예외·우선순위
- `business-rules.md`: 검증 가능한 규칙 catalog와 test trace

지속 가능성을 위한 최소 보조 정보는 다음과 같다.

- `index.md`: 최신성, context map, 문서 상태, 근거 revision, 미결 질문
- `decisions.md`: 모델 선택의 이유, 대안, 대체 관계
- traceability: source → rule/policy → model → code/test

저장소가 파일 수를 제한하거나 기존 단일 문서를 사용하면 보조 정보를 핵심 문서의 절로 포함한다. 의미 구조는 생략하지 않는다.

## 2. 문서 언어와 가독성

### 언어 선택

- 설명문, 요약, 질문, 결정 근거, 표 머리글과 다이어그램 해설은 한국어로 작성한다.
- 저장소 glossary와 확정된 ubiquitous language를 먼저 따른다.
- 공식 domain term, policy 이름, 코드 식별자, API, event, type 이름은 정확한 영어 원문을 유지한다.
- 정식 표현이 불명확한 영어 용어는 첫 사용 시 `한국어 설명 (EnglishTerm)`으로 소개한다.
- 한 개념에 한국어와 영어를 함께 사용하면 glossary에 대표 용어, alias, 사용하지 않을 표현을 기록한다.
- 번역으로 의미 또는 코드 추적성이 약해지면 영어 원문을 유지하고 한국어 설명을 덧붙인다.

YAML key, canonical ID, 코드·API 계약은 기계 추적을 위해 영어로 유지한다. 사람이 읽는 제목, 표 머리글, 설명용 record field는 한국어를 사용한다.

### 문서 안내

각 핵심 문서는 제목 다음의 첫 번째 2단계 절에 다음 안내를 둔다.

```markdown
## 문서 안내

- 목적: 이 문서가 답하는 질문을 한국어로 설명한다.
- 적용 범위: 포함하는 기능·context와 제외 범위를 설명한다.
- 핵심 변경: 직전 확정본과 비교한 추가·변경·폐기 사항을 요약한다.
- 권장 읽기 순서: 작업자가 먼저 볼 절과 필요할 때 볼 상세 절을 안내한다.
```

### 레이아웃

- 결론, 핵심 변경, 미결 결정, 구현 영향을 상세 model record보다 먼저 둔다.
- 비교, 목록, 상태 전이는 표로 표현하고 결정 이유와 예외는 문장으로 설명한다.
- 긴 표는 주제별로 분리하고 한 행에 하나의 규칙만 둔다.
- 제목 계층을 건너뛰지 않고 같은 수준의 정보에는 같은 제목 깊이를 사용한다.
- 약어와 전문 용어는 첫 사용 또는 glossary에서 정의한다.
- Mermaid에는 본문에서 사용하는 ID를 표시하고 바로 아래에 한국어 설명 또는 범례를 둔다.
- 링크 이름만 읽어도 대상 문서와 목적을 알 수 있게 작성한다.

작업자가 2분 안에 문서 목적, 핵심 규칙, 변경점, 미결 결정, 구현·테스트 영향을 찾지 못하면 레이아웃을 다시 구성한다.

## 3. 공통 메타데이터

각 핵심 문서 맨 앞에 YAML frontmatter를 둔다.

```yaml
---
document_type: domain-model
document_language: ko-KR
bounded_context: Ordering
status: draft
version: 1.0.0
last_reviewed_at: 2026-07-24
evidence_revision: <git-commit-or-worktree-description>
knowledge_owner: <role-or-unknown>
supersedes: []
---
```

### 필드

| 필드 | 규칙 |
|---|---|
| `document_type` | `domain-model`, `domain-policies`, `business-rules` 중 하나 |
| `document_language` | 한국어 설명을 사용하는 `ko-KR`; canonical 영어 용어 사용 여부와 무관 |
| `bounded_context` | 공식 ubiquitous language로 작성 |
| `status` | `draft`, `confirmed`, `superseded` 중 하나 |
| `version` | 의미 변경은 minor 이상, 구조만 수정하면 patch |
| `last_reviewed_at` | 내용을 근거와 비교한 날짜; 파일 수정일을 복사하지 않음 |
| `evidence_revision` | 검토한 commit 또는 명시적 worktree 상태 |
| `knowledge_owner` | 의미를 확정할 역할; 모르면 `unknown` |
| `supersedes` | 대체한 문서 버전 또는 경로 |

`status: confirmed`는 필요한 사람 결정이 완료되고 품질 검사 error가 없을 때만 사용한다.

## 4. ID와 지식 상태

### ID

다음 전역 ID를 사용한다.

| 접두사 | 대상 |
|---|---|
| `BC-###` | bounded context |
| `AGG-###` | aggregate |
| `ENT-###` | entity |
| `VO-###` | value object |
| `CMD-###` | command |
| `EVT-###` | domain event |
| `STATE-###` | state |
| `INV-###` | invariant |
| `POL-###` | domain policy |
| `BR-###` | business rule |
| `DS-###` | domain service |
| `DEC-###` | decision |
| `Q-###` | open question |
| `ASM-###` | assumption |

- 한 ID는 하나의 의미만 가진다.
- 이름이 바뀌어도 의미가 같으면 ID를 유지한다.
- 의미가 바뀌면 새 ID를 만들고 이전 ID를 `superseded` 처리한다.
- 삭제한 ID를 재사용하지 않는다.
- canonical definition의 제목은 `### AGG-001 Order`처럼 ID로 시작한다. 검증기는 이 제목을 정의로 취급한다.
- 다른 문서에서는 ID를 그대로 참조한다.

### 지식 상태

| 상태 | 의미 |
|---|---|
| `confirmed` | 권한 있는 사람이 비즈니스 의미를 확정함 |
| `implemented` | 현재 코드·테스트에서 동작을 확인함; 의도 확정은 아님 |
| `inferred` | 여러 근거로 추론했으나 직접 확인하지 못함 |
| `proposed` | 향후 모델로 제안함 |
| `unknown` | 근거가 부족함 |
| `superseded` | 다른 ID 또는 결정으로 대체됨 |

모델 요소마다 최소한 `지식 상태`, `근거`, `관련 ID`를 기록한다.

## 5. 도메인 모델 계약

### 필수 절

1. 문서 안내
2. 목적과 범위
3. ubiquitous language
4. bounded context와 context map
5. aggregate와 root
6. entity와 value object
7. command
8. state와 transition
9. domain event
10. invariant
11. cross-context 계약
12. 구현·테스트 추적
13. 미결 질문과 가정

### Bounded context 기록

```markdown
### BC-001 Ordering

- 지식 상태:
- 책임:
- 비즈니스 역량:
- 포함 범위:
- 제외 범위:
- ubiquitous language:
- upstream:
- downstream:
- 통합 계약:
- 근거:
- 관련 ID:
```

### Aggregate 기록

```markdown
### AGG-001 Order

- 지식 상태:
- 루트 entity: ENT-001
- 식별자:
- 생명주기:
- 보호하는 invariant: [INV-001]
- 수락하는 command: [CMD-001]
- 발행하는 event: [EVT-001]
- 하위 entity:
- value object:
- 외부 ID 참조:
- 일관성 경계 근거:
- 동시성 전략:
- 근거:
- 관련 ID:
```

Aggregate를 API payload 또는 persistence document와 동일시하지 않는다. `일관성 경계 근거`에 어떤 invariant 때문에 한 transaction이 필요한지 적지 못하면 aggregate 후보를 재검토한다.

### Entity 기록

```markdown
### ENT-001 Order

- 지식 상태:
- 소속 aggregate: AGG-001
- 식별자:
- 생명주기:
- 책임:
- 변경 진입점:
- 근거:
- 관련 ID:
```

### Value object 기록

```markdown
### VO-001 Money

- 지식 상태:
- 값:
- 동등성:
- 유효성 규칙:
- 정규화:
- 불변성:
- 근거:
- 관련 ID:
```

### Command 기록

```markdown
### CMD-001 PlaceOrder

- 지식 상태:
- 행위자:
- 의도:
- 대상 aggregate: AGG-001
- 입력 value object:
- 선행 조건:
- guard:
- 상태 전이:
- 결과 event: [EVT-001]
- 거부 결과:
- 멱등성:
- 근거:
- 관련 ID:
```

### State transition 기록

```markdown
### STATE-001 Draft

- 지식 상태:
- 의미:
- 진입 조건:
- 허용 전이:
  - trigger: CMD-001
    guard: INV-001
    도착 상태: STATE-002
    결과: EVT-001
- 금지 전이:
- 근거:
- 관련 ID:
```

### Domain event 기록

```markdown
### EVT-001 OrderPlaced

- 지식 상태:
- 의미:
- 발행자: AGG-001
- 발생 조건:
- payload 의미:
- consumer:
- 전달 보장:
- 호환성:
- 근거:
- 관련 ID:
```

### Invariant 기록

```markdown
### INV-001 OrderRequiresLine

- 지식 상태:
- 규칙:
- 보호 aggregate: AGG-001
- 검사 command: [CMD-001]
- 집행 위치:
- 위반 결과:
- 근거:
- 관련 ID: [BR-001]
```

## 6. 도메인 정책 계약

Policy는 “항상 참”인 구조 제약이 아니라 입력 사실로 결정을 내리는 domain knowledge를 표현한다.

### 필수 절

1. 문서 안내
2. 정책 catalog
3. 정책 상세
4. 우선순위와 충돌
5. 예외와 만료
6. 집행 위치
7. 다른 context 영향
8. 테스트 추적
9. 미결 질문과 가정

### Policy 기록

```markdown
### POL-001 CancellationEligibility

- 지식 상태:
- 목적:
- trigger:
- 입력 사실:
- decision:
- 결과:
- 우선순위:
- 충돌 policy:
- 예외:
- 적용 기간:
- 권위 출처:
- 집행 위치:
- 실패 결과:
- 정상 예:
- 반례:
- 근거:
- 관련 ID: [BR-002, CMD-002, STATE-002]
```

정책 우선순위가 없고 두 policy가 같은 입력에서 다른 결과를 낼 수 있으면 확정본으로 만들지 않는다.

## 7. 비즈니스 규칙 계약

Business rule은 가능한 한 조건 하나와 결론 하나로 작성한다. 서로 독립적으로 바뀔 수 있는 조건은 별도 ID로 분리한다.

### 필수 절

1. 문서 안내
2. rule catalog
3. rule 상세
4. decision table 또는 경계값
5. 충돌과 우선순위
6. 구현·테스트 추적
7. 미결 질문과 가정

### Business rule 기록

```markdown
### BR-001 OrderMustContainLine

- 지식 상태:
- 종류: invariant
- 규칙: 주문을 확정하려면 주문 항목이 하나 이상이어야 한다.
- 조건:
- 결론:
- 근거 이유:
- 우선순위:
- 예외:
- 권위 출처:
- 적용 기간:
- 정상 예:
- 반례:
- 경계값:
- 구현 모델: [INV-001]
- 테스트:
- 근거:
- 관련 ID: [AGG-001, CMD-001]
```

`종류`는 `invariant`, `eligibility`, `calculation`, `permission`, `temporal`, `limit`, `derivation`, `obligation` 중 하나를 우선 사용한다.

각 rule에는 최소 하나의 정상 예와 하나의 반례를 둔다. 값 경계가 있으면 경계 바로 아래·경계·바로 위를 테스트에 연결한다.

## 8. 보조 산출물 계약

### 최신성 인덱스

`index.md`에 다음을 둔다.

- 전체 문서 상태와 버전
- evidence revision과 마지막 검토일
- bounded context 목록과 책임
- context map
- ID별 canonical 문서 위치
- 충돌·미결 질문·가정 요약
- 마지막 checkpoint

### 결정 기록

```markdown
### DEC-001 Split Payment Context

- 상태: proposed
- 결정일:
- 결정자:
- 질문:
- context:
- 선택지:
- 결정:
- 결정 근거:
- 결과와 영향:
- 제외한 선택지:
- 대체 결정:
- 관련 ID:
- 근거:
```

결정하지 않은 항목의 `결정`을 권장안으로 채우지 않는다. `상태: proposed`와 `AI 권장안`을 별도로 기록한다.

### 추적성

다음 방향을 최소로 연결한다.

```text
source/requirement
  → BR/POL/INV
  → BC/AGG/CMD/STATE/EVT
  → code
  → test
```

코드가 아직 없으면 `planned`로, 찾지 못했으면 `unknown`으로 표시한다. 빈 칸을 `N/A`로 바꾸려면 이유를 적는다.

## 9. 완료 품질 기준

### Error

- 중복된 canonical ID
- 미정의 ID 참조
- 근거 없는 `confirmed`
- root를 우회하는 aggregate mutation
- 책임 aggregate가 없는 invariant
- trigger 또는 결과가 없는 state transition
- 같은 입력에 상충하는 policy 결과와 미정 우선순위
- 핵심 문서의 필수 메타데이터 누락
- `document_language`가 `ko-KR`이 아님
- 첫 번째 2단계 절에 `문서 안내`가 없거나 필수 안내 항목이 누락됨
- `문서 안내`의 설명이 한국어로 작성되지 않음

### Warning

- 코드 또는 테스트 추적이 없는 active rule
- counterexample이 없는 rule
- 만료 조건이 없는 임시 exception
- object reference로 직접 연결된 aggregate
- owner가 `unknown`인 confirmed policy
- 오래된 evidence revision
- 답변이 model boundary를 바꿀 수 있는 open question
- 공식 근거 없이 한국어와 영어 용어가 혼용됨
- 첫 사용 또는 glossary에서 정의하지 않은 약어·전문 용어
- 작업자가 한눈에 비교하기 어려운 긴 표
- 건너뛴 제목 계층 또는 목적을 알 수 없는 제목
- 한국어 설명이나 범례가 없는 Mermaid
- 목적, 핵심 규칙, 변경점, 미결 결정, 구현 영향을 2분 안에 찾기 어려운 레이아웃

Error가 없고 필요한 사람 결정, 한국어 설명, canonical 용어 보존, 문서 안내, 가독성 검사가 끝나야 `최신 확정본`이다. Error가 없지만 미결 결정이나 가정이 있으면 `최신 초안`이다.
