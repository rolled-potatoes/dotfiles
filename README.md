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

## Neovim 탐색 전용 모드와 코드 메모

`nvimr`는 bootstrap이 `.zshrc`의 dotfiles marker block 안에 설치하는 별칭이다. 기존 `.zshrc` 내용은 보존한다.

```bash
nvimr ./
```

`nvim -R`는 Neovim의 `readonly`만 설정하고 `modifiable`은 유지한다. 설정의 탐색 전용 모드는 `-R` 인자를 감지하면 일반 파일 버퍼에 `readonly=true`, `modifiable=false`를 적용한다. 따라서 help, terminal, prompt, quickfix, Telescope, nvim-tree와 코드 메모 팝업은 입력 가능하지만 일반 파일은 수정할 수 없다.

명령은 다음과 같다.

- `:CodeReviewEnable`, `:CodeReviewDisable`, `:CodeReviewToggle`, `:CodeReviewStatus`
- `:CodeNoteLine`, `:CodeNoteRange`, `:CodeNoteFile`, `:CodeNoteShow`, `:CodeNoteEdit`, `:CodeNoteDelete`
- `:CodeNotes`, `:CodeNotesPath {path}`, `:CodeNotesGrep {text}`, `:CodeNotesBuffer`, `:CodeNotesStatus {active|legacy|orphan}`
- `:CodeNotesCopy`, `:CodeNotesClear` — 전체 삭제는 확인을 요구한다.

기본 키맵은 `<leader>m` 아래에 있다.

- `<leader>mn`: 현재 줄 또는 Visual 범위 메모 만들기
- `<leader>mF`: 파일 메모 만들기
- `<leader>mo`, `<leader>me`, `<leader>md`: 현재 위치 메모 보기 / 수정 / 삭제
- `<leader>ml`, `<leader>mb`: 프로젝트 전체 / 현재 버퍼 목록
- `<leader>mp`, `<leader>mg`, `<leader>ms`: 경로 / 본문 / 상태 검색
- `<leader>mc`, `<leader>mC`: 프로젝트 전체 복사 / 확인 후 전체 삭제
- `<leader>m?`: 코드 메모 키맵 도움말 popup

메모는 기본적으로 프로젝트 밖의 `~/code-notes/<project-key>/notes/<id>.json`에 저장된다. `project-key`는 Git top-level(없으면 Neovim 시작 디렉터리)의 이름과 hash로 구성되며, 실제 project root도 note 데이터에 저장한다. `setup()`으로 다른 외부 경로를 지정할 수 있지만 project root 내부 경로는 거부한다.

```lua
require("code-notes").setup({
  notes_dir = vim.fn.expand("~/code-notes"),
})
```

줄/범위 메모는 저장 당시의 snippet과 hash로 위치를 검증한다. 원래 위치가 일치하면 `active`, 파일 내 유일한 일치 위치가 있으면 새 줄로 재배치한다. 위치가 모호하거나 달라졌으면 자동 삭제하지 않고 `legacy` 파일 메모로 전환한다. 파일이 사라지면 `orphan`으로 보존하며, Telescope에서 선택하면 이동하지 않고 popup으로 표시한다.

복사 형식은 AGENT 전달용으로 다음 세 필드만 포함한다. 저장된 anchor snippet/hash 같은 원본 코드 검증 정보는 포함하지 않는다.

```text
프로젝트 상대 파일 경로
시작라인:끝라인
메모 내용
```

범위는 일반 줄/범위 메모에서 1-based 실제 줄 번호다. 파일·legacy 메모는 `0:0`이고, orphan은 마지막으로 신뢰한 줄 범위를 유지한다(파일 메모에서 시작한 orphan은 `0:0`). Telescope picker는 오른쪽 pane에 선택한 메모의 상태·경로·범위·본문을 미리 보여 준다. Enter로 조회/이동하고, `<C-e>`로 수정, `<C-d>`로 삭제, `<C-y>`로 다중 선택 결과 또는 현재 항목을 복사한다.

조회와 수정은 같은 메모 popup을 사용한다. popup에서 내용을 바로 추가·수정한 뒤 `<C-s>`로 저장 후 닫는다. `:w`는 저장한 채 popup을 유지하고, `:x`는 저장 후 닫는다. `q`는 저장하지 않고 닫는다.

개발 중 headless 검증은 실제 `~/code-notes` 대신 임시 디렉터리를 사용한다.

```bash
bash tests/test_nvim.sh
bash tests/test_bootstrap_static.sh
./bin/verify
```

## 저장소에서 관리하지 않는 항목

- Codex/OpenCode 로그인, OAuth, API key, MCP 인증과 기기별 비밀값
- `opencode.json`의 개인 provider/model 선택과 OpenCode runtime 생성 파일
- 프로젝트별 언어 runtime 버전
- oh-my-zsh theme/plugin 선택, 기본 로그인 셸 변경
- Karabiner의 `automatic_backups`

이전 Codex 보조 명령과 저장소 구현은 더 이상 관리하지 않는다.
