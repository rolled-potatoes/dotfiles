# 하네스 계약

프로젝트의 실제 스택에 맞춰 구현하되, 아래 논리적 명령과 의미는 유지한다. Node의 package script, Python CLI, Make target, Gradle task 등 프로젝트가 이미 사용하는 진입점을 우선한다. 지원 런타임이 없는 명령을 강제하지 말고, 문서에서 실제 실행 구문을 명시한다.

## 논리적 명령

| 명령 | 책임 |
| --- | --- |
| `harness:setup` | 작업 위치·Git 격리 가능 여부를 점검하고, 허용된 경우에만 안전한 worktree 흐름을 안내 또는 준비 |
| `harness:goal:init` | 전체 목표와 검증 가능한 완료 조건의 초안 생성 |
| `harness:plan:init` | As-Is, To-Be, 위험, 검증, 승인 기록 필드를 가진 전체 계획 초안 생성 |
| `harness:loop:plan:init` | 다음 루프를 시작할 수 있는지 검사하고 이번 가설·범위·중단 조건 기록 |
| `harness:loop:implement:init` | 실제 변경과 판단 근거를 적는 루프 기록 초안 생성 |
| `harness:loop:validate` | 프로젝트 검증을 실행하고 결과·명령·스냅샷·사람 검증 요구를 기록 |
| `harness:loop:report` | `success`, `replan`, `blocked` 중 하나를 근거와 `failure_key`로 기록 |
| `harness:validate` | 전체 변경의 최종 검증과 현재 변경 스냅샷 기록 |
| `harness:report` | 완료 조건 판정, 남은 위험, 문서 영향, 커밋 준비 정보를 작성 |
| `harness:commit:check` | 커밋 준비 상태만 검사; Git mutation은 금지 |

`harness:setup`은 worktree가 적합한 Git 프로젝트에서 기본 checkout 외 격리를 권장한다. remote, 기본 브랜치, branch 이름, fetch/pull, worktree 생성은 관찰 결과와 별도 권한 없이는 수행하지 않는다. 적용할 수 없으면 현재 checkout 대안과 혼합 작업 위험을 기록하고 나머지 하네스는 계속 구축한다.

## 승인과 상태 전이

전체 계획은 실제 사용자 승인 전에는 구현·문서·설정 변경을 허용하지 않는다. 스크립트는 채팅을 인증할 수 없으므로 `plan.md`의 승인 기록 필드를 검사하고, 프로젝트 `AGENTS.md`는 실제 승인을 요구한다.

```text
goal → plan(승인) → loop plan → implement → validate → report
                                                ├─ success → final validate → final report → commit check
                                                ├─ replan → 다음 loop plan
                                                └─ blocked → 사용자 개입
```

검증 실패 뒤 자동 재계획은 승인된 목표·범위·완료 조건·위험 경계 안에서만 가능하다. 공개 API, 서버 계약, 데이터 모델, 도메인 정책, 보안·개인정보·데이터 손실, 배포·외부 시스템, 범위 밖 대규모 리팩터링 또는 성공 조건 변경이 필요하면 `blocked` 또는 승인 대기로 기록하고 사용자에게 다시 승인받는다.

## 스크립트 강제 규칙

프로젝트 하네스는 다음을 실행 가능한 검사로 강제한다.

- 최대 5개 루프만 생성한다.
- 동일한 정규화된 `failure_key` 또는 동일 근본 원인은 최대 3회까지만 `replan`으로 기록한다.
- 루프 `plan.md` 생성 시각부터 `report.md` 완료 시각까지 2시간을 넘으면 `blocked`다.
- 직전 루프 report가 없으면 다음 루프를 만들 수 없다. `success` 또는 `blocked` 뒤에는 새 루프를 만들 수 없다.
- 성공은 모든 완료 조건, 요구된 자동 검증, 요구된 사람 검증 증거가 있을 때만 가능하다.
- 검증 뒤 코드 또는 staged 변경이 달라지면 그 검증은 무효다. Git 프로젝트는 대상 변경을 제외 규칙과 함께 해시하고, 비-Git 프로젝트는 프로젝트에 맞는 파일 목록·해시 방식을 문서화한다.
- 실패한 검증은 삭제하지 않고 validate/report 증거에 남긴다.

`failure_key`는 전체 오류 문자열이 아니라 원인을 안정적으로 묶는 짧은 kebab-case 키다. 예: `type-error-user-contract`, `ci-network-unavailable`. 사용자가 판단해야 하는 원인에는 키와 필요한 결정 내용을 함께 기록한다.

`scripts/validate_harness_state.py`는 이 계약을 점검하는 독립 참조 검사다. 프로젝트가 Python을 사용하지 않으면 동일한 검사와 테스트를 기존 런타임으로 구현한다. 단순히 문서에 규칙을 적는 것으로는 충분하지 않다.
