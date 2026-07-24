# 원자 작업과 책임 경계

## 목차

1. 원자 작업 기준
2. 책임 원칙
3. 원자 작업 목록
4. 사람 확인 게이트
5. 중단과 재개

## 1. 원자 작업 기준

하나의 작업은 다음 조건을 모두 만족할 때 더 쪼개지 않는다.

- 동사가 하나다.
- 주 입력과 주 출력이 하나다.
- 기본 책임자가 한 명이다.
- 완료 여부를 예/아니오로 검증할 수 있다.
- 실패해도 다음 실행에서 해당 작업만 다시 수행할 수 있다.
- 한 작업 안에서 조사, 결정, 문서 수정을 섞지 않는다.

작업 계획에는 아래 ID와 `A` 또는 `H` 책임자를 표시한다.

- `A`: Agent가 자율 수행
- `H`: Human이 의미 또는 권한을 확정

`H` 작업 앞에서 Agent는 반드시 근거, 대안, 영향, 권장안을 준비한다.

## 2. 책임 원칙

### Agent가 수행

- 저장소 지침과 파일 탐색
- 문서·코드·테스트 근거 수집
- 현재 구현 흐름과 규칙 추출
- 후보 모델, 대안, 영향, 질문 초안 작성
- 승인된 결정의 문서 반영
- ID·링크·정합성·추적성 검사
- 문서 언어·용어 관례 판정
- 작업자 관점의 문서 안내와 가독성 검사

### Human이 수행

- 비즈니스 목적과 성공 기준 확정
- 용어의 공식 의미와 context 소유권 확정
- 상충하는 정책의 우선순위와 예외 확정
- transaction으로 보호할 business invariant 확정
- 법적·계약적·조직적 제약과 위험 허용치 확정
- 여러 타당한 대안 중 제품 의미를 바꾸는 선택

Human에게 파일 찾기, 코드 흐름 요약, 문서 포맷팅, 후보 나열을 맡기지 않는다. Agent가 근거로 확정할 수 있는 사실을 질문하지 않는다.

## 3. 원자 작업 목록

### A. 시작과 범위

| ID | 원자 작업 | 주 출력 | 책임자 | 완료 조건 |
|---|---|---|---|---|
| S-01 | 저장소 지침을 읽는다 | 적용 규칙 목록 | A | 대상 경로의 규칙을 기록함 |
| S-02 | 작업 트리 상태를 확인한다 | 변경 파일 목록 | A | 사용자 변경과 작업 범위를 구분함 |
| S-03 | 문서 관례를 찾는다 | 문서 루트·명명 규칙 | A | 사용할 기존 관례를 지정함 |
| S-04 | 요청의 대상 행위를 추출한다 | 대상 행위 한 문장 | A | actor와 outcome을 포함함 |
| S-05 | 제외 범위를 추출한다 | non-goal 목록 | A | 명시·암묵 범위를 구분함 |
| S-06 | 변경 모드를 분류한다 | 변경 모드 하나 | A | 기존/추가/신규/규칙/진단 중 선택함 |
| S-07 | 완료 조건을 제안한다 | 검증 가능한 완료 조건 | A | 문서·결정·검증 범위를 포함함 |
| S-08 | 범위를 확정한다 | 승인된 scope | H | 제품 의미를 바꾸는 범위가 결정됨 |
| S-09 | 문서 독자를 지정한다 | 독자 정의 | A | 작업자의 목적과 필요한 선행 지식을 기록함 |
| S-10 | 문서 언어 관례를 판정한다 | 언어·용어 기준 | A | 한국어 설명과 유지할 canonical English term을 구분함 |

`S-08`은 저장소와 대화에서 범위가 명확하면 생략한다.

### B. 근거 수집

| ID | 원자 작업 | 주 출력 | 책임자 | 완료 조건 |
|---|---|---|---|---|
| E-01 | domain 문서를 열거한다 | 문서 inventory | A | 관련 후보 파일을 모두 기록함 |
| E-02 | 문서 상태를 판정한다 | 문서별 freshness 상태 | A | status·review date·revision을 확인함 |
| E-03 | 핵심 용어를 검색한다 | 검색 hit 목록 | A | 동의어와 코드명을 포함함 |
| E-04 | 진입점을 식별한다 | entrypoint 목록 | A | API·job·consumer 등 시작점을 지정함 |
| E-05 | 호출 흐름 하나를 추적한다 | 경로와 줄 근거 | A | entrypoint에서 persistence/event까지 연결함 |
| E-06 | 도메인 타입을 수집한다 | type inventory | A | entity·VO·enum 후보를 기록함 |
| E-07 | validation을 수집한다 | validation inventory | A | 조건과 실패 결과를 기록함 |
| E-08 | state transition을 수집한다 | transition inventory | A | from·trigger·guard·to를 기록함 |
| E-09 | 권한 검사를 수집한다 | permission inventory | A | actor·resource·decision을 기록함 |
| E-10 | event를 수집한다 | event inventory | A | producer·payload·consumer를 기록함 |
| E-11 | persistence 근거를 수집한다 | schema·mapping 목록 | A | identity·reference·constraint를 기록함 |
| E-12 | 테스트 근거를 수집한다 | scenario 목록 | A | 정상·실패·경계 사례를 기록함 |
| E-13 | 주장 하나를 ledger에 등록한다 | evidence record 하나 | A | 상태·출처·위치를 포함함 |
| E-14 | 문서와 구현을 비교한다 | 차이 하나 | A | missing·conflict·rename·dead 중 분류함 |

`E-05`, `E-13`, `E-14`는 경로 또는 주장마다 반복한다. 여러 주장을 한 record에 합치지 않는다.

### C. 지식 추출과 모호성 분리

| ID | 원자 작업 | 주 출력 | 책임자 | 완료 조건 |
|---|---|---|---|---|
| K-01 | actor 하나를 정의한다 | actor 후보 | A | 목표와 권한 범위를 포함함 |
| K-02 | capability 하나를 정의한다 | capability 후보 | A | business outcome을 포함함 |
| K-03 | 용어 하나를 정의한다 | glossary 후보 | A | 정의·동의어·금지어를 포함함 |
| K-04 | command 하나를 정의한다 | command 후보 | A | actor·intent·target을 포함함 |
| K-05 | event 하나를 정의한다 | event 후보 | A | 발생 사실과 producer를 포함함 |
| K-06 | state 하나를 정의한다 | state 후보 | A | 진입·종료 의미를 포함함 |
| K-07 | rule 하나를 정의한다 | rule 후보 | A | 조건과 결론이 각각 하나임 |
| K-08 | invariant 하나를 분리한다 | invariant 후보 | A | 항상성 범위와 위반 결과를 포함함 |
| K-09 | policy 하나를 분리한다 | policy 후보 | A | 입력 사실과 decision을 포함함 |
| K-10 | 예외 하나를 기록한다 | exception 후보 | A | 적용 조건과 기본 규칙을 연결함 |
| K-11 | 용어 충돌 하나를 기록한다 | ambiguity record | A | 각 의미와 사용 근거를 포함함 |
| K-12 | 규칙 충돌 하나를 기록한다 | conflict record | A | 충돌 조건과 영향을 포함함 |
| K-13 | 누락 지식 하나를 질문으로 바꾼다 | question record | A | 답변이 바꿀 모델 요소를 포함함 |

### D. 사람 결정

| ID | 원자 작업 | 주 출력 | 책임자 | 완료 조건 |
|---|---|---|---|---|
| H-01 | 공식 용어를 선택한다 | 용어 결정 | H | 선택·제외 용어와 이유를 기록함 |
| H-02 | capability 책임자를 선택한다 | ownership 결정 | H | 단일 책임 또는 공유 계약을 기록함 |
| H-03 | bounded context 경계를 선택한다 | boundary 결정 | H | 포함·제외 책임을 기록함 |
| H-04 | business invariant를 승인한다 | invariant 결정 | H | 허용할 수 없는 상태를 기록함 |
| H-05 | rule 우선순위를 선택한다 | precedence 결정 | H | 충돌 시 승자와 이유를 기록함 |
| H-06 | policy 예외를 승인한다 | exception 결정 | H | 적용 주체·기간·감사 조건을 기록함 |
| H-07 | 위험 가정을 승인한다 | assumption 결정 | H | 영향과 만료 조건을 기록함 |
| H-08 | 비가역 변경을 승인한다 | change decision | H | 마이그레이션·호환성 영향을 수용함 |

### E. 모델 구성

| ID | 원자 작업 | 주 출력 | 책임자 | 완료 조건 |
|---|---|---|---|---|
| M-01 | bounded context 후보 하나를 만든다 | BC 후보 | A | 책임·언어·포함·제외를 포함함 |
| M-02 | 경계 응집도를 검사한다 | boundary check | A | 언어·규칙·lifecycle·ownership을 평가함 |
| M-03 | context 관계 하나를 정의한다 | context-map edge | A | 방향·계약·통합 패턴을 포함함 |
| M-04 | command invariant를 연결한다 | CMD→INV 관계 | A | command가 보호할 규칙을 지정함 |
| M-05 | aggregate 후보 하나를 만든다 | AGG 후보 | A | transaction invariant를 포함함 |
| M-06 | aggregate root를 지정한다 | root 결정안 | A | identity와 mutation entry를 포함함 |
| M-07 | entity 하나를 배치한다 | ENT 소속 | A | identity·lifecycle·aggregate를 포함함 |
| M-08 | value object 하나를 배치한다 | VO 소속 | A | equality·validation·immutability를 포함함 |
| M-09 | transition 하나를 모델링한다 | 상태 전이 | A | from·trigger·guard·to·effect를 포함함 |
| M-10 | command 결과를 모델링한다 | 결과 관계 | A | event 또는 명시적 무변경을 포함함 |
| M-11 | policy 실행 위치를 제안한다 | enforcement 후보 | A | domain/application/외부 책임을 구분함 |
| M-12 | cross-aggregate 흐름을 모델링한다 | event/policy flow | A | 일관성·재시도·보상을 포함함 |
| M-13 | 실패 하나를 모델링한다 | failure contract | A | 원인·표현·복구 가능성을 포함함 |
| M-14 | 동시성 위험 하나를 모델링한다 | concurrency rule | A | 충돌 탐지와 처리 방식을 포함함 |

### F. 영향과 문서

| ID | 원자 작업 | 주 출력 | 책임자 | 완료 조건 |
|---|---|---|---|---|
| I-01 | context 영향을 평가한다 | 영향 record | A | 계약·용어·소유권을 확인함 |
| I-02 | API 영향을 평가한다 | 영향 record | A | request·response·error 호환성을 확인함 |
| I-03 | event 영향을 평가한다 | 영향 record | A | schema·consumer·delivery를 확인함 |
| I-04 | data 영향을 평가한다 | 영향 record | A | schema·historical data·migration을 확인함 |
| I-05 | security 영향을 평가한다 | 영향 record | A | 권한·개인정보·감사를 확인함 |
| I-06 | test 영향을 평가한다 | test map | A | rule별 test level을 연결함 |
| W-01 | 새 ID 하나를 예약한다 | 고유 ID | A | 중복이 없고 index에 등록됨 |
| W-02 | domain model 항목 하나를 갱신한다 | 문서 patch | A | ID·상태·근거를 포함함 |
| W-03 | policy 항목 하나를 갱신한다 | 문서 patch | A | rule·우선순위·예외를 포함함 |
| W-04 | business rule 하나를 갱신한다 | 문서 patch | A | 예·반례·test를 포함함 |
| W-05 | decision 하나를 갱신한다 | decision record | A | 선택·대안·이유를 포함함 |
| W-06 | trace link 하나를 갱신한다 | 추적 관계 | A | source→model→code/test를 연결함 |
| W-07 | freshness metadata를 갱신한다 | metadata patch | A | 검토일·revision·상태를 포함함 |
| W-08 | 문서 안내를 작성한다 | 독자 안내 | A | 목적·적용 범위·핵심 변경·읽기 순서를 포함함 |
| W-09 | 설명문을 한국어로 작성한다 | 한국어 설명 | A | 공식 영어 용어 외 설명과 해설이 한국어임 |
| W-10 | canonical 영어 용어를 적용한다 | 용어 patch | A | glossary·코드 계약과 같은 표기를 사용함 |
| W-11 | 정보 계층을 정리한다 | reader-first layout | A | 결론·변경점·미결 사항이 상세 모델보다 먼저 보임 |

### G. 검증과 전달

| ID | 원자 작업 | 주 출력 | 책임자 | 완료 조건 |
|---|---|---|---|---|
| Q-01 | ID 고유성을 검사한다 | pass/error | A | 중복 정의가 없음 |
| Q-02 | 참조 무결성을 검사한다 | pass/error | A | 미정의 참조가 없음 |
| Q-03 | command 완전성을 검사한다 | pass/error | A | target·guard·result·failure가 있음 |
| Q-04 | state 완전성을 검사한다 | pass/error | A | 고아 state와 무trigger 전이가 없음 |
| Q-05 | invariant 책임을 검사한다 | pass/error | A | 보호 aggregate와 enforcement가 있음 |
| Q-06 | policy 결정성을 검사한다 | pass/error | A | 입력별 결과·우선순위·예외가 명확함 |
| Q-07 | rule 테스트성을 검사한다 | pass/error | A | example·counterexample·test가 있음 |
| Q-08 | 지식 상태를 검사한다 | pass/error | A | 제안이 확정 사실처럼 쓰이지 않음 |
| Q-09 | 미결 결정을 요약한다 | 사용자 action 목록 | A | 질문마다 영향과 권장안이 있음 |
| Q-10 | 문서 상태를 판정한다 | 최신 초안/확정본 | A | error와 승인 상태를 반영함 |
| Q-11 | 문서 언어를 검사한다 | pass/error | A | 설명은 한국어이고 canonical 영어 용어는 보존됨 |
| Q-12 | 용어 일관성을 검사한다 | pass/warning | A | 혼용어·미정의 약어·alias 누락이 없음 |
| Q-13 | 레이아웃 가독성을 검사한다 | pass/warning | A | 제목 계층과 표 크기가 작업자 탐색을 방해하지 않음 |
| Q-14 | 다이어그램 가독성을 검사한다 | pass/warning | A | Mermaid에 한국어 설명 또는 범례가 있음 |

## 4. 사람 확인 게이트

### Gate 1: 범위

- 진입 조건: 요청과 저장소 근거가 서로 다른 기능 범위를 가리킨다.
- Human 입력: 목적, 포함 범위, 제외 범위.
- 통과 조건: 하나의 scope로 evidence를 수집할 수 있다.

### Gate 2: 언어와 경계

- 진입 조건: 용어 의미 또는 capability 소유권에 둘 이상의 타당한 해석이 있다.
- Human 입력: 공식 용어와 책임 경계.
- 통과 조건: context마다 한 용어가 한 의미를 가진다.

### Gate 3: invariant와 정책

- 진입 조건: 허용할 수 없는 상태, rule 우선순위, 예외를 artifact로 확정할 수 없다.
- Human 입력: invariant, precedence, exception.
- 통과 조건: command와 state transition의 허용 여부를 판정할 수 있다.

### Gate 4: 최종 확정

- 진입 조건: 품질 검사 error가 없고 미결 질문의 영향, 한국어 설명, canonical 용어, 문서 안내, 가독성 검사가 정리되었다.
- Human 입력: 초안 승인 또는 수정.
- 통과 조건: `proposed`와 `confirmed`를 정확히 구분한 최종 상태가 결정된다.

## 5. 중단과 재개

각 실행 끝에 다음 checkpoint를 남긴다.

- 마지막 완료 작업 ID
- 사용한 evidence revision
- 생성·변경한 model ID
- 대기 중인 Human 작업 ID
- 다음에 수행할 Agent 작업 ID

Human 답변이 없어도 안전한 분석과 문서 초안은 계속한다. 답변이 모델의 경계나 규칙을 바꾸면 영향을 받는 작업만 다시 수행한다.
