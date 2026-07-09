#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# GNU Stow 설치 확인
if ! command -v stow &>/dev/null; then
  echo "GNU Stow not found. Installing via Homebrew..."
  brew install stow
fi

# opencode 로컬 설정 초기화 (dotfiles 경로)
OPENCODE_DOTFILES_CONFIG_DIR="$DOTFILES_DIR/opencode/.config/opencode"
OPENCODE_CONFIG_FILE="$OPENCODE_DOTFILES_CONFIG_DIR/opencode.json"
OPENCODE_CONFIG_EXAMPLE="$OPENCODE_DOTFILES_CONFIG_DIR/opencode.json.example"

if [ ! -f "$OPENCODE_CONFIG_FILE" ] && [ -f "$OPENCODE_CONFIG_EXAMPLE" ]; then
  cp "$OPENCODE_CONFIG_EXAMPLE" "$OPENCODE_CONFIG_FILE"
  echo "Created local opencode config: $OPENCODE_CONFIG_FILE"
  echo "Edit model values in this file before using opencode."
fi

# stow 패키지 목록 (디렉토리 이름 = 패키지)
PACKAGES=(opencode agents claude ghostty nvim)

for pkg in "${PACKAGES[@]}"; do
  if [ -d "$DOTFILES_DIR/$pkg" ]; then
    echo "Stowing: $pkg"
    stow --restow --target="$HOME" --dir="$DOTFILES_DIR" "$pkg"
  fi
done

# opencode 플러그인 설치 (package.json 있을 경우)
if [ -f "$HOME/.config/opencode/package.json" ]; then
  echo "Installing opencode plugins..."
  cd "$HOME/.config/opencode"
  if command -v bun &>/dev/null; then
    bun install
  elif command -v npm &>/dev/null; then
    npm install
  fi
fi

echo "Done."
