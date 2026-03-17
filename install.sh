#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# GNU Stow 설치 확인
if ! command -v stow &>/dev/null; then
  echo "GNU Stow not found. Installing via Homebrew..."
  brew install stow
fi

# stow 패키지 목록 (디렉토리 이름 = 패키지)
PACKAGES=(opencode agents ghostty nvim)

for pkg in "${PACKAGES[@]}"; do
  if [ -d "$DOTFILES_DIR/$pkg" ]; then
    echo "Stowing: $pkg"
    stow --restow --target="$HOME" --dir="$DOTFILES_DIR" "$pkg"
  fi
done

# opencode 플러그인 설치 (package.json 있을 경우)
OPENCODE_CONFIG="$HOME/.config/opencode"
if [ -f "$OPENCODE_CONFIG/package.json" ]; then
  echo "Installing opencode plugins..."
  cd "$OPENCODE_CONFIG"
  if command -v bun &>/dev/null; then
    bun install
  elif command -v npm &>/dev/null; then
    npm install
  fi
fi

echo "Done."
