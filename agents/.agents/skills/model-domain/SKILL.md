---
name: model-domain
description: 저장소의 최신 문서와 코드를 근거로 도메인 주도 설계 모델을 작성·갱신하고 bounded context, aggregate, root, entity, value object, command, state, domain event, invariant, domain policy, business rule 및 다른 도메인에 대한 영향을 작업자가 이해하기 쉬운 한국어 문서로 정리한다. Use when the user asks for DDD 또는 도메인 모델링, 신규 도메인·bounded context·aggregate 설계, 도메인 정책이나 비즈니스 규칙 정리, 기존 모델과 코드의 불일치 분석, 또는 구현 전 도메인 문서 최신화.
---

# Model Domain

저장소에서 확인할 수 있는 구현 사실과 사람이 확정해야 하는 비즈니스 의미를 분리하여, 개발과 테스트로 추적 가능한 DDD 문서 집합을 유지한다.

## 시작 시 읽을 자료

작업 계획을 세우기 전에 다음을 모두 읽는다.

- 원자 작업과 사람 확인 게이트: [references/atomic-workflow.md](references/atomic-workflow.md)
- 산출물 구조, ID, 품질 기준: [references/artifact-contracts.md](references/artifact-contracts.md)

## 핵심 원칙

- 기존 `docs` 문서와 저장소 규칙을 먼저 따른다. 기존 구조가 없을 때만 기본 구조를 사용한다.
- 문서의 최근 수정 시각만으로 “최신”을 판정하지 않는다. 상태, 근거 revision, 코드·테스트와의 일치, 사람의 확정을 함께 기록한다.
- 코드와 테스트는 현재 구현의 근거이지 비즈니스 의도의 최종 권위가 아니다. 문서와 코드가 충돌하면 자동으로 한쪽을 선택하지 말고 충돌을 드러낸다.
- 각 주장에 `confirmed`, `implemented`, `inferred`, `proposed`, `unknown`, `superseded` 중 지식 상태와 근거를 부여한다.
- 비즈니스 용어를 기술 계층, 데이터베이스 테이블명, 프레임워크 타입으로 대체하지 않는다.
- bounded context는 일관된 언어와 모델이 유효한 경계로 설정한다. 화면, API, 테이블, 마이크로서비스 하나를 그대로 경계로 간주하지 않는다.
- aggregate는 한 트랜잭션에서 보호해야 하는 invariant를 기준으로 작게 설정한다. aggregate 간에는 객체 그래프보다 ID와 event를 우선한다.
- root만 aggregate 변경의 진입점으로 사용한다.
- business rule은 검증 가능한 규범, invariant는 aggregate 내부에서 항상 참이어야 하는 규칙, policy는 조건에 따른 결정·계산·조정 방식으로 구분한다.
- 증거가 없는 세부사항을 채우지 않는다. 질문에 답이 없으면 가정을 명시하고 `proposed` 상태를 유지한다.
- 사용자가 코드 구현까지 명시적으로 요청하지 않았다면 문서와 구현 핸드오프까지만 수행한다.

## 문서 언어와 가독성

다음 우선순위로 산출물의 언어를 결정한다.

1. 저장소의 glossary와 확정된 ubiquitous language를 우선한다.
2. 설명문, 요약, 질문, 결정 근거와 다이어그램 해설은 한국어로 작성한다.
3. 공식 domain term, policy 이름, 코드 식별자, API, event, type 이름은 번역하지 않는다.
4. 정식 표현이 불명확한 영어 용어는 첫 사용 시 `한국어 설명 (EnglishTerm)`으로 소개한다.
5. 같은 개념에 한국어와 영어를 함께 사용해야 하면 glossary에 대표 용어와 alias를 기록한다.

작업자가 문서의 목적, 핵심 규칙, 변경점, 미결 사항을 먼저 파악할 수 있도록 결론과 요약을 상세 모델보다 앞에 둔다. 사람이 읽는 제목, 표 머리글, 설명용 record field는 한국어를 사용하고, YAML key·ID·코드 계약은 추적성을 위해 영어를 유지한다.

## 1. 범위와 변경 모드 고정

1. 저장소 지침, 작업 트리 상태, 문서 관례를 확인한다.
2. 사용자의 요청에서 대상 기능, 행위자, 성공 결과, 제외 범위를 추출한다.
3. 작업을 다음 중 하나로 분류한다.
   - 기존 모델 최신화
   - 기존 context에 기능 추가
   - 신규 domain 또는 bounded context 제안
   - 정책·규칙만 변경
   - 문서와 구현의 불일치 진단
4. 대상 산출물과 완료 조건을 고정한다.
5. 문서를 읽을 작업자와 저장소의 한국어·영어 용어 관례를 확인한다.
6. 범위를 저장소와 대화에서 특정할 수 없고 선택에 따라 모델이 달라질 때만 사용자에게 가장 작은 질문을 한다.

## 2. 최신 근거 수집

1. `docs/**`에서 domain, policy, rule, decision, glossary, requirement 문서를 찾는다.
2. 각 문서의 상태, 검토일, 근거 revision, 대체 관계를 확인한다.
3. 대상 용어와 동작을 코드에서 검색한다.
4. API·consumer·job·CLI 같은 진입점에서 application/domain/persistence 흐름을 추적한다.
5. 타입, validation, permission, state transition, error, event, schema, migration, test를 확인한다.
6. 문서 주장과 구현 근거를 하나씩 evidence ledger에 기록한다.
7. 문서와 코드 사이의 누락, 충돌, 이름 차이, 죽은 규칙을 분리한다.

근거가 많아도 핵심 경로와 규칙을 증명하는 파일·줄만 기록한다. 외부 표준이나 라이브러리의 최신 동작이 모델 결정에 영향을 줄 때만 공식 1차 자료를 확인한다.

## 3. 도메인 지식 추출

다음을 각각 독립된 후보 목록으로 만든다.

- 행위자, 목표, capability, 책임
- ubiquitous language와 동의어·충돌어
- identity와 lifecycle을 가진 entity
- 값 자체로 의미가 있고 불변인 value object
- 사용자의 의도를 나타내는 command
- 이미 발생한 비즈니스 사실을 나타내는 domain event
- state와 허용·금지 transition
- invariant, policy, business rule
- 권한, 시간, 수량, 우선순위, 예외, 실패 조건
- 다른 context 또는 외부 시스템과의 관계

각 후보를 `existing`, `add`, `change`, `rename`, `deprecate`, `reject` 중 하나로 분류하고 근거와 영향을 연결한다.

## 4. 사람 확인 게이트 운영

에이전트는 조사, 비교, 후보 생성, 대안 분석, 권장안, 초안, 정합성 검사를 수행한다. 다음 의미 결정만 사람에게 요청한다.

- 같은 용어가 서로 다른 의미를 가질 때의 표준 언어
- business capability의 책임과 bounded context 소유권
- 동시에 반드시 일관되어야 하는 invariant와 transaction 경계
- 상충하는 rule의 우선순위와 예외
- 코드에서 알 수 없는 정책 의도, 법적·계약적 제약, 위험 허용치
- 비가역적이거나 여러 context의 계약을 바꾸는 선택

질문마다 다음만 제시한다.

1. 결정할 한 가지 사항
2. 확인된 근거와 아직 모르는 점
3. 2~3개 선택지와 각각의 모델·코드 영향
4. AI 권장안과 이유
5. 답변 전 사용할 수 있는 가정과 그 위험

서로 독립된 질문은 묶을 수 있지만 한 번에 세 개를 넘기지 않는다. 답변 없이 진행 가능한 항목은 가정을 기록하고 계속한다. 답변이 없으면 `confirmed`로 승격하지 않는다.

## 5. 신규 경계와 aggregate 모델링

신규 domain 또는 경계 변경에만 다음을 수행한다.

### Bounded context

1. business capability와 모델의 책임을 한 문장으로 작성한다.
2. 포함하는 행위와 포함하지 않는 행위를 구분한다.
3. 고유한 언어, 규칙, lifecycle, 변경 주기, 소유권을 점검한다.
4. 기존 context에 합칠 때 생기는 모순과 분리할 때 생기는 통합 비용을 비교한다.
5. upstream/downstream, customer/supplier, conformist, anti-corruption layer 등 실제 관계만 기록한다.
6. 경계가 비즈니스 의미를 바꾸면 사람에게 확정받는다.

### Aggregate

1. command마다 즉시 보호해야 하는 invariant를 찾는다.
2. 그 invariant를 한 transaction에서 지킬 최소 객체 묶음을 제안한다.
3. identity와 lifecycle을 소유하는 root를 지정한다.
4. entity와 value object를 분리한다.
5. 외부 변경 진입점을 root의 command로 제한한다.
6. cross-aggregate 변경은 event, policy, process manager 또는 보상 흐름으로 모델링한다.
7. 동시성, 멱등성, 중복 event, 부분 실패를 점검한다.
8. 넓은 transaction이나 기존 계약 변경이 필요하면 사람에게 확정받는다.

## 6. 행위와 규칙 모델링

- command마다 actor, intent, target, input VO, precondition, state change, emitted event, rejection, idempotency를 기록한다.
- state마다 진입 조건과 종료 조건을 기록하고 모든 transition을 command 또는 event에 연결한다.
- event는 과거형 비즈니스 언어로 명명하고 발생 주체, payload 의미, consumer, 전달 보장을 기록한다.
- invariant는 책임 aggregate와 위반 시 실패를 연결한다.
- policy는 trigger, 입력 사실, decision, 결과, 우선순위, 예외, 권위 출처, 집행 위치를 기록한다.
- business rule은 단일 조건·결론으로 쪼개고 정상 예, 반례, 경계값, 테스트 시나리오를 붙인다.
- entity나 VO에 자연스럽게 속하지 않는 순수 domain behavior만 domain service 후보로 둔다.

## 7. 영향 분석

변경된 각 ID에 대해 다음 영향을 확인한다.

- 다른 bounded context와 용어·계약
- command, API, event schema와 하위 호환성
- persistence, migration, historical data
- 권한, 개인정보, 감사
- 동시성, 멱등성, transaction, 보상
- application service, repository port, adapter
- unit, contract, integration, migration test

영향을 확인하지 못한 항목은 `영향 없음`으로 추정하지 말고 `unknown`으로 남긴다.

## 8. 문서 갱신

[references/artifact-contracts.md](references/artifact-contracts.md)의 계약에 따라 다음 핵심 문서를 최신화한다.

1. domain model
2. domain policies
3. business rules

또한 최신성 인덱스, 결정 기록, 추적성 정보를 갱신한다. 기존 저장소에서 이를 별도 파일로 관리하지 않으면 핵심 문서의 해당 절에 포함한다.

- 각 핵심 문서의 첫 번째 2단계 절에 `문서 안내`를 두고 목적, 적용 범위, 핵심 변경, 권장 읽기 순서를 작성한다.
- 기존 ID를 재사용하고 의미가 바뀌면 새 ID를 만든다.
- 삭제 대신 `superseded` 또는 `deprecated`와 대체 ID를 남긴다.
- 관련 없는 문단을 전면 재작성하지 않는다.
- 사실, 추론, 제안, 미결 질문을 문장 안에서 혼합하지 않는다.
- 비교·목록·상태 전이는 표로 표현하고 결정 이유와 예외는 문장으로 설명한다.
- 긴 표는 주제별로 분리하고 한 행에 하나의 규칙만 둔다.
- 다이어그램은 관계가 셋 이상일 때만 Mermaid로 추가하고 표와 본문의 ID를 사용한다. 다이어그램 아래에는 한국어 설명 또는 범례를 둔다.
- 약어와 전문 용어는 첫 사용 또는 glossary에서 정의한다.

## 9. 품질 검사

1. 모든 model element에 고유 ID, 지식 상태, 근거가 있는지 검사한다.
2. 모든 command가 aggregate root와 결과 event 또는 명시적 무변경 결과에 연결되는지 검사한다.
3. 모든 state transition에 trigger, guard, 결과가 있는지 검사한다.
4. 모든 invariant에 보호 aggregate와 enforcement point가 있는지 검사한다.
5. 모든 policy와 business rule에 우선순위·예외·실패·테스트가 필요한지 점검한다.
6. orphan ID, 모순된 용어, 순환 책임, aggregate 간 강한 객체 참조를 찾는다.
7. 결정과 미결 질문이 문서의 확정 상태와 일치하는지 검사한다.
8. 설명문과 해설이 한국어로 작성되었는지 검사한다.
9. canonical English term과 코드 식별자가 번역되거나 혼용되지 않았는지 검사한다.
10. 문서 안내, 제목 계층, 표 분할, 다이어그램 설명이 작업자 관점에서 읽기 쉬운지 검사한다.
11. 작업자가 2분 안에 목적, 핵심 변경, 미결 결정, 구현 영향을 찾을 수 있는지 점검한다.
12. 가능하면 다음 검증기를 실행한다.

```bash
python3 <skill-dir>/scripts/validate_domain_docs.py <domain-docs-dir>
```

검증기의 warning은 근거를 검토해 처리하고, error가 남으면 완료로 보고하지 않는다.

## 결과 전달

다음을 간결하게 보고한다.

- 생성·갱신한 문서 위치
- 추가·변경·폐기한 주요 model element
- 확정된 결정과 사용한 가정
- 충돌, 다른 context 영향, 구현 위험
- 남은 사람 결정과 다음 개발 작업

문서가 승인 전이면 `최신 초안`으로 표시한다. 근거와 사람 확인이 끝나고 한국어 설명, canonical 용어 보존, 문서 안내, 가독성 검사를 모두 통과했을 때만 `최신 확정본`으로 표시한다.
