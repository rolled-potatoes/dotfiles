# dotfiles

새 Mac에서 개인 개발 환경의 설정을 복원하기 위한 저장소다. 애플리케이션과 CLI는 별도로 설치하고, 이 저장소의 `install.sh`로 추적 중인 설정과 공용 agent skills를 연결한다.

이 저장소는 애플리케이션 버전, 로그인·OAuth 상태, API key와 기기별 비밀값까지 복원하지 않는다.

## 새 Mac 설정

### 1. 사전 준비

지원 대상은 Homebrew를 사용하는 macOS다. 먼저 다음 항목을 준비한다.

- Git과 GitHub SSH 인증
- [Homebrew](https://brew.sh/)
- Python 3.10 이상
- 설정을 사용할 애플리케이션: OpenCode, Ghostty, Neovim, Karabiner-Elements, Codex
- OpenCode plugin 설치에 사용할 Bun 또는 npm

필수 명령을 설치한다.

```bash
brew install git python stow neovim
brew install --cask ghostty karabiner-elements
```

OpenCode, Codex 등 AI CLI는 각 도구의 공식 설치 방법으로 설치한다. Bun 또는 npm은 OpenCode plugin을 사용할 때만 필요하다.

### 2. 저장소 복제

저장소를 개인 설정 경로에 복제한다.

```bash
git clone git@github.com:rolled-potatoes/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. 설정 연결

설치 스크립트는 GNU Stow로 설정을 연결한다. 기존 설정 파일과 충돌하면 덮어쓰지 않고 중단한다.

```bash
./install.sh
```

스크립트는 다음 설정을 연결한다.

| 대상 | 저장소 경로 | 설치 위치 |
| --- | --- | --- |
| OpenCode | `opencode/.config/opencode` | `~/.config/opencode` |
| 공용 agent skills | `agents/.agents` | `~/.agents` |
| Ghostty | `ghostty` | `~/.config/ghostty` |
| Neovim | `nvim` | `~/.config/nvim` |
| Karabiner-Elements | `karabiner` | `~/.config/karabiner` |
| Codex token usage 도구 | `codex/.local/bin/codex-token-usage` | `~/.local/bin/codex-token-usage` |

### 4. 기기별 설정

처음 실행하면 `opencode/.config/opencode/opencode.json.example`을 복사해 git에서 제외된 `opencode.json`을 만든다. 아래 agent별 `provider/model` 값을 사용할 model로 변경한다.

```text
opencode/.config/opencode/opencode.json
```

OpenCode와 Codex 등 사용하는 AI 도구에서 인증을 별도로 완료한다. OAuth 상태와 API key는 저장소에 추가하지 않는다.

### 5. PATH 설정

`codex-token-usage`를 바로 실행하려면 shell 설정에 다음 경로를 추가한다.

```bash
export PATH="$HOME/.local/bin:$PATH"
```

설정을 적용한 뒤 확인한다.

```bash
source ~/.zshrc
codex-token-usage --help
```

이 저장소는 `.zshrc`를 관리하지 않으므로 PATH 설정은 PC마다 직접 추가해야 한다.

### 6. 설치 확인

- `nvim`을 열어 `lazy.nvim` plugin 설치와 Mason의 LSP 설치가 끝나는지 확인한다.
- OpenCode를 실행해 선택한 model과 `@rolled-potatoes/opencode-mermaid` plugin을 확인한다.
- Ghostty가 `~/.config/ghostty/config`를 읽는지 확인한다.
- Karabiner-Elements를 열어 저장된 profile과 complex modification을 확인한다.
- 사용하는 AI 도구의 인증과 MCP 연결을 확인한다.

## 기존 설정과 충돌할 때

설치 스크립트는 기존 파일을 삭제하거나 GNU Stow의 `--adopt`로 가져오지 않는다. 오류에 표시된 설정을 먼저 백업한 뒤 다시 실행한다.

예를 들어 기존 Neovim 설정을 백업하려면 다음과 같이 실행한다.

```bash
mv ~/.config/nvim ~/.config/nvim.backup
./install.sh
```

다른 애플리케이션도 오류에 표시된 경로를 같은 방식으로 백업한다. 새 설정을 확인한 뒤 필요할 때만 백업에서 개인 설정을 옮긴다.

## 설정 갱신

다른 PC에서 반영한 설정을 가져올 때는 저장소를 갱신한 뒤 설치 스크립트를 다시 실행한다.

```bash
cd ~/dotfiles
git pull
./install.sh
```

`./install.sh`는 이미 올바르게 연결된 설정에는 다시 실행해도 같은 결과를 유지한다.

## 저장소에서 관리하지 않는 항목

- Homebrew 전체 package 목록과 애플리케이션 버전
- 로그인, OAuth, API key와 기타 비밀값
- `opencode.json`의 PC별 provider와 model 선택
- OpenCode의 `node_modules`, lock file, plugin runtime 파일
- Karabiner의 `automatic_backups`
- shell의 PATH와 PC별 환경 변수
