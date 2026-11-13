# dotfiles

Apple Silicon macOS에서 개발 환경과 개인 설정을 안전하게 복원하는 저장소다. 새 Mac과 이미 사용 중인 Mac 모두 같은 진입점을 사용하며, 설치·셸 초기화·런타임·링크·검증을 단계적으로 처리한다.

지원 대상은 Apple Silicon(`arm64`) macOS뿐이다. Intel Mac, Linux는 의도적으로 실패한다.

## 빠른 시작

Xcode Command Line Tools 설치가 끝난 뒤 저장소를 복제하고 실행한다.

```bash
git clone git@github.com:rolled-potatoes/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh`는 호환용 이름이며 실제 단일 진입점은 `./bin/bootstrap`이다. 먼저 바뀔 항목만 보려면 다음을 사용한다.

```bash
./bin/bootstrap --dry-run
```

기존 환경에서도 같은 명령을 다시 실행한다. 설치된 Homebrew 패키지, 올바른 링크, 같은 mise 버전, 기존 관리 블록은 변경하지 않는다.

## 실행 흐름

1. **사전 점검** — Apple Silicon macOS, Xcode Command Line Tools, 네트워크를 확인한다. CLT가 없으면 Apple 설치 UI를 열고 중단한다. 완료 후 같은 명령을 재실행한다.
2. **Homebrew 부트스트랩** — `/opt/homebrew/bin/brew`가 없을 때만 [공식 설치 명령](https://brew.sh/)을 사용한다. 현재 프로세스에서 `brew shellenv`를 적용하고, 새 zsh 세션을 위한 관리 블록도 추가한다.
3. **Homebrew 패키지** — [Brewfile](/Users/rolled-potatoes/dotfiles/Brewfile)의 CLI/cask를 `brew bundle install --no-upgrade`로 설치한다. Node.js/Python은 Brewfile에 넣지 않는다.
4. **mise** — `mise latest`로 당시의 안정 버전을 확인해 전역 `node`와 `python`을 명시 버전으로 고정한다. 프로젝트의 `mise.toml`, `.tool-versions`, 기타 런타임 설정은 변경하지 않으며 해당 프로젝트 설정이 우선한다.
5. **zsh 및 oh-my-zsh** — `.zprofile`과 `.zshrc`의 작은 marker 블록으로 Homebrew와 mise를 활성화한다. oh-my-zsh는 Homebrew가 아닌 공식 설치기를 `--unattended --keep-zshrc`로 실행하므로 기존 `.zshrc`를 교체하지 않고, 기본 로그인 셸도 변경하지 않는다.
6. **dotfile 연결** — GNU Stow로 OpenCode, agent 설정, Codex 전역 지침, Ghostty, Neovim, Karabiner 설정을 연결한다.
7. **Neovim 복원** — lazy.nvim 잠금 파일의 플러그인 revision을 복원하고, Mason 도구와 Treesitter parser 설치가 완료될 때까지 기다린다.
8. **검증** — 현재 셸과 새 login zsh, Neovim parser와 Mason 포매터를 점검한다.

## Homebrew 관리 항목

다음은 Homebrew로 관리한다.

- CLI: `ripgrep`, `neovim`, `tree-sitter-cli`, `zsh`, `opencode`, `lazygit`, `mise`, `stow`, `git`
- 앱/cask: `ghostty`, `codex`, `karabiner-elements`, `font-cascadia-code`, `font-d2coding`

Codex는 Homebrew formula가 아니라 cask다. Ghostty와 Karabiner는 GUI 앱이므로 설치 뒤 최초 실행·권한 부여는 사용자가 해야 한다. Codex/OpenCode의 로그인, OAuth, API key와 MCP 인증도 자동화하지 않는다.

## 기존 파일과 충돌

스크립트는 수정 전 대상과 영향을 출력한다.

- `.zprofile`, `.zshrc`, mise 전역 설정은 처음 관리 블록/버전을 추가하기 전에 타임스탬프 백업을 만든다. 이후에는 marker 블록만 재작성한다.
- 올바른 Stow 링크는 그대로 둔다.
- `~/.agents` 안에서 이 저장소의 동일한 원본을 가리키는 절대경로 링크는 Stow가 처리할 수 있는 상대경로 링크로 정리한다. `references/development`와 `references/planning`도 연결하며, 다른 원본을 가리키는 링크는 보존하고 충돌로 처리한다.
- 일반 파일 또는 다른 위치를 향한 심볼릭 링크는 덮어쓰지 않고 중단한다. 파일 충돌을 검토한 뒤 `--backup`으로 실행하면 백업한 다음 교체할 수 있다.
- 기존 `~/.oh-my-zsh`는 재설치하지 않는다. 기존 `.zshrc`는 공식 installer의 `--keep-zshrc`로 보존한다.
- 과거 Codex 보조 명령 링크는 이 저장소의 과거 구현을 가리킬 때만 제거한다. 다른 명령을 가리키면 경고만 내고 보존한다.
- Codex 공통 파일은 `~/.codex/AGENTS.md`와 `~/.codex/agents/`에만 연결한다. `~/.codex/config.toml`과 기존 역할 파일은 덮어쓰지 않으며, 충돌하면 변경 없이 중단한다.

충돌을 직접 해결한 뒤에는 같은 명령을 재실행한다.

```bash
./bin/bootstrap
```

## 검증과 문제 해결

설치 뒤 또는 진단만 필요할 때 실행한다.

```bash
./bin/verify
```

성공 시 `brew`, `mise`, `node`, `python`, `zsh`, `rg`, `nvim`, `lazygit`, `codex`, `opencode`, 새 login zsh, Treesitter parser와 Mason 포매터를 확인한다. Ghostty는 CLI 대신 `/Applications/Ghostty.app` bundle 존재를 확인한다.

- 네트워크 오류: VPN/프록시/TLS를 확인한 뒤 `./bin/bootstrap`을 재실행한다.
- Homebrew 오류: `/opt/homebrew/bin/brew doctor`를 실행한 뒤 다시 시도한다.
- mise 버전 조회/다운로드 오류: 네트워크를 확인한 뒤 `mise latest node`, `mise latest python`으로 원인을 보고 재실행한다.
- 기본 로그인 셸을 Homebrew zsh로 바꾸려면 `/etc/shells` 등록과 `chsh`가 필요하다. 스크립트는 인증을 요구하는 이 동작을 자동 실행하지 않으며, 완료 메시지의 명령을 검토한 후 직접 실행한다.
- OpenCode plugin 설치를 나중에 하려면 `./bin/bootstrap --skip-plugins` 없이 다시 실행한다. Node는 mise가 제공한다.

## 저장소에서 관리하지 않는 항목

- `~/.codex/config.toml`의 기본 모델, 추론 수준, 서비스 tier, 계획 모드와 하위 agent 기본값
- Codex/OpenCode 로그인, OAuth, API key, MCP 인증과 기기별 비밀값
- Codex의 프로젝트 신뢰 설정, 로컬 경로, 캐시·세션·로그와 기기별 role override
- `opencode.json`의 개인 provider/model 선택과 OpenCode runtime 생성 파일
- 프로젝트별 언어 runtime 버전
- oh-my-zsh theme/plugin 선택, 기본 로그인 셸 변경
- Karabiner의 `automatic_backups`

이전 Codex 보조 명령과 저장소 구현은 더 이상 관리하지 않는다.

## Codex 공통 설정과 개인 설정

이 저장소는 공통 작업 방식과 검토 역할을 제공한다. `.codex/AGENTS.md`는 공통 지침을, `.codex/agents/*.toml`은 역할별 지침과 모델을 정의한다. 기존 사용자 정의 `explorer`, `worker`, `verifier` 설정을 제거하고 아래 검토 역할로 대체한다.

| 검토 역할 | 모델 | reasoning effort | 호출 기준 |
|---|---|---|---|
| `policy_reviewer` | `gpt-6.1-sol` | `high` | 정책·요구사항 적합성 |
| `test_reviewer` | `gpt-6.1-sol` | `high` | 테스트의 검증력과 누락 |
| `code_reviewer` | `gpt-6.1-sol` | `high` | 구조·컨벤션·유지보수성 |
| `reliability_reviewer` | `gpt-6-astra` | `high` | 동시성·데이터 변경·외부 연동 등 위험이 있는 작업 |

모델 선택은 [공식 모델 선택 가이드](https://developers.openai.com/api/docs/guides/model-selection)와 [하위 에이전트 설정 문서](https://learn.chatgpt.com/docs/agent-configuration/subagents)를 바탕으로 한 초기 운영 설정이다. 이 네 역할에 대한 직접 비교 실측 결과는 아니다. 검토자 파일에 `model`과 `model_reasoning_effort`를 함께 명시하여 부모 모델에 의존하지 않는다.

메인 에이전트가 조사·구현·검사 실행과 수정을 담당한다. 검토자는 같은 스냅샷과 승인된 요구사항을 독립적으로 검토하고 제품 코드를 수정하지 않는다. 공유 작업 트리에서 상태를 변경하는 검사는 순서를 조율한다. 메인은 중복 지적과 근거를 확인하고 수정한 뒤 해당 검토자를 재호출한다. 필수 수정 해결, 필요한 검사 통과, 요구사항 확인과 미검증 사항 공개 후 완료 후보를 보고한다. 두 차례 수정 후에도 남는 쟁점은 근거와 선택지를 사용자에게 보고하며 자동 통과시키지 않는다.

호출 예: “승인된 티켓과 연결 문서, 현재 diff를 기준으로 policy_reviewer, test_reviewer, code_reviewer를 호출하여 독립 검토해주세요. 데이터 정합성 위험이 있으므로 reliability_reviewer도 호출해주세요. 결과를 모두 수집하여 근거를 확인하고, 승인 범위의 문제를 수정한 뒤 해당 검토자에게 재검증을 요청해주세요.”

설치 후 설정 위치는 `~/.codex/agents/<역할명>.toml`이다. 파일별 링크는 해당 링크가 있는 `~/.codex/agents/`를 기준으로 저장소의 `.codex/agents/`를 가리킨다. 현재 세션에 새 역할이 보이지 않으면 새 세션에서 로딩과 선택 모델을 확인한다.

메인 에이전트의 기본 model·effort는 각 머신의 `~/.codex/config.toml`에서 선택한다. 위 검토 역할은 각 파일의 명시적 설정을 사용한다. 계획 모드를 사용하지 않는 경우에는 plan mode 설정을 관리하거나 동기화할 필요가 없다.

새 공통 role 파일이 기존 `~/.codex/agents/*.toml`과 충돌하면 bootstrap은 중단한다. 기존 role의 model·effort와 개인 지침을 보존한 뒤, 공통 역할 지침을 병합하거나 백업한 다음 다시 실행한다. `agents` 디렉터리는 파일별로 연결해 개인 role 파일을 추가해도 저장소에 유입되지 않는다. `~/.codex` 전체를 심볼릭 링크하지 않는다.

