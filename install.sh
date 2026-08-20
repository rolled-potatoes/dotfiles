#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fail() {
  echo "Error: $*" >&2
  exit 1
}

if [ "$(uname -s)" != "Darwin" ]; then
  fail "This installer supports macOS only."
fi

if ! command -v brew &>/dev/null; then
  fail "Homebrew is required. Install it from https://brew.sh and run this script again."
fi

# Codex token usage 도구는 Python 3.10 이상 필요
if ! command -v python3 &>/dev/null || ! python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)'; then
  echo "Python 3.10 or newer is required." >&2
  echo "Install it, then run this script again:" >&2
  echo "  brew install python" >&2
  exit 1
fi

if ! command -v stow &>/dev/null; then
  echo "GNU Stow not found. Installing via Homebrew..."
  brew install stow
fi

for font_cask in font-cascadia-code font-d2coding; do
  if ! brew list --cask "$font_cask" &>/dev/null; then
    echo "Installing $font_cask via Homebrew..."
    brew install --cask "$font_cask"
  fi
done

# opencode 로컬 설정 초기화 (기기별 값이므로 git에서 제외)
OPENCODE_DOTFILES_CONFIG_DIR="$DOTFILES_DIR/opencode/.config/opencode"
OPENCODE_CONFIG_FILE="$OPENCODE_DOTFILES_CONFIG_DIR/opencode.json"
OPENCODE_CONFIG_EXAMPLE="$OPENCODE_DOTFILES_CONFIG_DIR/opencode.json.example"

if [ ! -f "$OPENCODE_CONFIG_FILE" ] && [ -f "$OPENCODE_CONFIG_EXAMPLE" ]; then
  cp "$OPENCODE_CONFIG_EXAMPLE" "$OPENCODE_CONFIG_FILE"
  echo "Created local opencode config: $OPENCODE_CONFIG_FILE"
  echo "Edit the model values before using OpenCode."
fi

STOW_IGNORE_ARGS=(
  --ignore='(^|/)\.DS_Store$'
  --ignore='(^|/)automatic_backups($|/)'
  --ignore='(^|/)node_modules($|/)'
  --ignore='(^|/)bun\.lock$'
  --ignore='(^|/)package-lock\.json$'
  --ignore='^\.config/opencode/oh-my-opencode\.json$'
  --ignore='^\.config/opencode/skills-lock\.json$'
  --ignore='^\.config/opencode/plugins($|/)'
)

canonical_path() {
  python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1"
}

stow_package() {
  local package="$1"
  local target="$2"
  local source="$DOTFILES_DIR/$package"

  [ -d "$source" ] || return 0

  if [ -L "$target" ]; then
    if [ "$(canonical_path "$target")" = "$(canonical_path "$source")" ]; then
      echo "Already linked: $target -> $source"
      return 0
    fi

    fail "$target is a symbolic link to another location. Back it up or remove it, then run this script again."
  fi

  if [ -e "$target" ] && [ ! -d "$target" ]; then
    fail "$target already exists and is not a directory. Back it up, then run this script again."
  fi

  mkdir -p "$target"

  echo "Stowing $package into $target"
  if ! stow \
    --restow \
    "${STOW_IGNORE_ARGS[@]}" \
    --target="$target" \
    --dir="$DOTFILES_DIR" \
    "$package"; then
    echo "Failed to stow $package because files already exist in $target." >&2
    echo "Back up the conflicting files or directory, then run this script again." >&2
    exit 1
  fi
}

# Stow 2.4에는 --no-folding이 없으므로 중간 디렉터리를 먼저 만들어
# ~/.config, ~/.local 또는 ~/.agents 전체가 저장소 링크가 되는 것을 방지한다.
mkdir -p \
  "$HOME/.config/opencode" \
  "$HOME/.agents/references" \
  "$HOME/.agents/scripts" \
  "$HOME/.local/bin"

# HOME 아래의 공용 설정.
for package in opencode agents codex .codex; do
  stow_package "$package" "$HOME"
done

# 애플리케이션별 XDG 설정 위치.
stow_package ghostty "$HOME/.config/ghostty"
stow_package nvim "$HOME/.config/nvim"
stow_package karabiner "$HOME/.config/karabiner"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *)
    echo 'Warning: ~/.local/bin is not in PATH.'
    echo 'Add this line to your shell configuration:'
    echo '  export PATH="$HOME/.local/bin:$PATH"'
    ;;
esac

if [ -f "$HOME/.config/opencode/package.json" ]; then
  echo "Installing OpenCode plugins..."
  if command -v bun &>/dev/null; then
    (cd "$HOME/.config/opencode" && bun install)
  elif command -v npm &>/dev/null; then
    (cd "$HOME/.config/opencode" && npm install)
  else
    echo "Warning: Bun and npm were not found; OpenCode plugin installation was skipped." >&2
  fi
fi

echo "Done. Complete the post-install checks in README.md."
