#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bash -n "$ROOT/install.sh" "$ROOT/bin/bootstrap" "$ROOT/bin/verify" "$ROOT/scripts/bootstrap-lib.sh"
for expected in ripgrep neovim ghostty zsh codex opencode lazygit mise; do rg -qx "(brew|cask) \"$expected\"" "$ROOT/Brewfile"; done
! test -e "$ROOT/codex/.local/bin/codex-token-usage"
! test -e "$ROOT/tests/test_codex_token_usage.py"
! rg -n -i 'codex[-_ ]?(token[-_ ]?)?usage' "$ROOT" -g '!/.git/**' -g '!scripts/bootstrap-lib.sh' -g '!tests/test_bootstrap_static.sh'

temporary_home="$(mktemp -d)"
trap 'rm -rf "$temporary_home"' EXIT
HOME="$temporary_home"
DOTFILES_DIR="$ROOT"
DRY_RUN=0
mkdir -p "$HOME/.local/bin"
ln -s "$ROOT/codex/.local/bin/codex-token-usage" "$HOME/.local/bin/codex-token-usage"
source "$ROOT/scripts/bootstrap-lib.sh"
remove_retired_codex_command
! test -L "$HOME/.local/bin/codex-token-usage"
ln -s /tmp/unrelated-command "$HOME/.local/bin/codex-token-usage"
remove_retired_codex_command
test -L "$HOME/.local/bin/codex-token-usage"
