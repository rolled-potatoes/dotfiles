#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bash -n "$ROOT/install.sh" "$ROOT/bin/bootstrap" "$ROOT/bin/verify" "$ROOT/scripts/bootstrap-lib.sh"
for expected in ripgrep neovim ghostty zsh codex opencode lazygit mise; do rg -qx "(brew|cask) \"$expected\"" "$ROOT/Brewfile"; done
rg -Fqx 'brew "tree-sitter-cli"' "$ROOT/Brewfile"
rg -Fqx "bootstrap_neovim" "$ROOT/bin/bootstrap"
rg -Fq "MasonToolsInstallSync" "$ROOT/scripts/bootstrap-lib.sh"
rg -Fq 'config.nvim-bootstrap").install_parsers' "$ROOT/scripts/bootstrap-lib.sh"
rg -Fq 'verify_app Ghostty' "$ROOT/scripts/bootstrap-lib.sh"
rg -Fq '"javascriptreact"' "$ROOT/nvim/lua/plugins/tresitter.lua"
rg -Fq 'ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "markdown" }' "$ROOT/nvim/lua/plugins/autotag.lua"
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

printf '%s\n' 'export USER_SETTING=kept' > "$HOME/.zshrc"
configure_zsh
configure_zsh
test "$(rg -Fxc "alias nvimr='nvim -R'" "$HOME/.zshrc")" -eq 1
rg -Fqx 'export USER_SETTING=kept' "$HOME/.zshrc"
rg -Fqx "$MANAGED_BEGIN" "$HOME/.zshrc"
rg -Fqx "$MANAGED_END" "$HOME/.zshrc"

# The shared Codex package must populate ~/.codex without replacing the
# machine-local config.toml or putting instructions in the home directory.
mkdir -p "$HOME/.codex"
printf '%s\n' 'model = "machine-local-model"' > "$HOME/.codex/config.toml"
stow_package .codex "$HOME/.codex" no-folding
test -L "$HOME/.codex/AGENTS.md"
test ! -L "$HOME/.codex/agents"
test -L "$HOME/.codex/agents/explorer.toml"
test -L "$HOME/.codex/agents/verifier.toml"
test -L "$HOME/.codex/agents/worker.toml"
test ! -e "$HOME/AGENTS.md"
rg -Fqx 'model = "machine-local-model"' "$HOME/.codex/config.toml"
printf '%s\n' 'name = "machine-local-role"' > "$HOME/.codex/agents/local.toml"
stow_package .codex "$HOME/.codex" no-folding
rg -Fqx 'model = "machine-local-model"' "$HOME/.codex/config.toml"
rg -Fqx 'name = "machine-local-role"' "$HOME/.codex/agents/local.toml"

# Earlier installer versions put this package directly in HOME. Remove only
# links that resolve to the matching dotfiles source.
ln -s "$ROOT/.codex/AGENTS.md" "$HOME/AGENTS.md"
ln -s "$ROOT/.codex/agents" "$HOME/agents"
remove_legacy_codex_links
test ! -e "$HOME/AGENTS.md"
test ! -e "$HOME/agents"
ln -s /tmp/unrelated-command "$HOME/AGENTS.md"
remove_legacy_codex_links
test -L "$HOME/AGENTS.md"
rm "$HOME/AGENTS.md"

# A regular machine-local role file remains a conflict; stow must not replace
# it even when the shared package is otherwise valid.
conflict_home="$(mktemp -d)"
trap 'rm -rf "$temporary_home" "$conflict_home"' EXIT
mkdir -p "$conflict_home/.codex/agents"
printf '%s\n' '# personal instructions' > "$conflict_home/.codex/AGENTS.md"
printf '%s\n' 'name = "personal-explorer"' > "$conflict_home/.codex/agents/explorer.toml"
if stow --restow --no-folding --target "$conflict_home/.codex" --dir "$ROOT" .codex; then
  printf '%s\n' 'expected a role-file conflict' >&2
  exit 1
fi
rg -Fqx '# personal instructions' "$conflict_home/.codex/AGENTS.md"
rg -Fqx 'name = "personal-explorer"' "$conflict_home/.codex/agents/explorer.toml"
