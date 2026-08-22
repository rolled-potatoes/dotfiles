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
7. **검증** — 현재 셸과 새 login zsh에서 명령과 mise runtime/PATH를 점검한다.

## Homebrew 관리 항목

다음은 Homebrew로 관리한다.

- CLI: `ripgrep`, `neovim`, `zsh`, `opencode`, `lazygit`, `mise`, `stow`, `git`
- 앱/cask: `ghostty`, `codex`, `karabiner-elements`, `font-cascadia-code`, `font-d2coding`

Codex는 Homebrew formula가 아니라 cask다. Ghostty와 Karabiner는 GUI 앱이므로 설치 뒤 최초 실행·권한 부여는 사용자가 해야 한다. Codex/OpenCode의 로그인, OAuth, API key와 MCP 인증도 자동화하지 않는다.

## 기존 파일과 충돌

스크립트는 수정 전 대상과 영향을 출력한다.

- `.zprofile`, `.zshrc`, mise 전역 설정은 처음 관리 블록/버전을 추가하기 전에 타임스탬프 백업을 만든다. 이후에는 marker 블록만 재작성한다.
- 올바른 Stow 링크는 그대로 둔다.
- 일반 파일 또는 다른 위치를 향한 심볼릭 링크는 덮어쓰지 않고 중단한다. 파일 충돌을 검토한 뒤 `--backup`으로 실행하면 백업한 다음 교체할 수 있다.
- 기존 `~/.oh-my-zsh`는 재설치하지 않는다. 기존 `.zshrc`는 공식 installer의 `--keep-zshrc`로 보존한다.
- 과거 Codex 보조 명령 링크는 이 저장소의 과거 구현을 가리킬 때만 제거한다. 다른 명령을 가리키면 경고만 내고 보존한다.

충돌을 직접 해결한 뒤에는 같은 명령을 재실행한다.

```bash
./bin/bootstrap
```

## 검증과 문제 해결

설치 뒤 또는 진단만 필요할 때 실행한다.

```bash
./bin/verify
```

성공 시 `brew`, `mise`, `node`, `python`, `zsh`, `rg`, `nvim`, `ghostty`, `lazygit`, `codex`, `opencode`와 새 login zsh를 확인한다.

- 네트워크 오류: VPN/프록시/TLS를 확인한 뒤 `./bin/bootstrap`을 재실행한다.
- Homebrew 오류: `/opt/homebrew/bin/brew doctor`를 실행한 뒤 다시 시도한다.
- mise 버전 조회/다운로드 오류: 네트워크를 확인한 뒤 `mise latest node`, `mise latest python`으로 원인을 보고 재실행한다.
- 기본 로그인 셸을 Homebrew zsh로 바꾸려면 `/etc/shells` 등록과 `chsh`가 필요하다. 스크립트는 인증을 요구하는 이 동작을 자동 실행하지 않으며, 완료 메시지의 명령을 검토한 후 직접 실행한다.
- OpenCode plugin 설치를 나중에 하려면 `./bin/bootstrap --skip-plugins` 없이 다시 실행한다. Node는 mise가 제공한다.

## 저장소에서 관리하지 않는 항목

- Codex/OpenCode 로그인, OAuth, API key, MCP 인증과 기기별 비밀값
- `opencode.json`의 개인 provider/model 선택과 OpenCode runtime 생성 파일
- 프로젝트별 언어 runtime 버전
- oh-my-zsh theme/plugin 선택, 기본 로그인 셸 변경
- Karabiner의 `automatic_backups`

이전 Codex 보조 명령과 저장소 구현은 더 이상 관리하지 않는다.
