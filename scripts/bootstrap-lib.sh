#!/usr/bin/env bash
# Shared staged installer implementation. This file is sourced by bin scripts.

BREW_PREFIX=/opt/homebrew
BREW_BIN="$BREW_PREFIX/bin/brew"
MANAGED_BEGIN='# >>> dotfiles managed environment >>>'
MANAGED_END='# <<< dotfiles managed environment <<<'
STOW_IGNORE_ARGS=(
  --ignore='(^|/)\.DS_Store$' --ignore='(^|/)automatic_backups($|/)'
  --ignore='(^|/)node_modules($|/)' --ignore='(^|/)bun\.lock$'
  --ignore='(^|/)package-lock\.json$' --ignore='^\.config/opencode/oh-my-opencode\.json$'
  --ignore='^\.config/opencode/skills-lock\.json$' --ignore='^\.config/opencode/plugins($|/)'
)

say() { printf '%s\n' "$*"; }
warn() { printf 'Warning: %s\n' "$*" >&2; }
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
run() { if ((DRY_RUN)); then printf '+ '; printf '%q ' "$@"; printf '\n'; else "$@"; fi; }

require_apple_silicon_macos() {
  [[ $(uname -s) == Darwin ]] || fail 'This installer supports macOS only.'
  [[ $(uname -m) == arm64 ]] || fail 'This installer supports Apple Silicon (arm64) macOS only.'
}
check_command_line_tools() {
  if ! xcode-select -p >/dev/null 2>&1; then
    say "Xcode Command Line Tools are required. Starting Apple's installer..."
    ((DRY_RUN)) || xcode-select --install || true
    fail 'Complete Command Line Tools installation, then rerun ./bin/bootstrap.'
  fi
}
check_network() {
  command -v curl >/dev/null || fail 'curl is required to bootstrap Homebrew.'
  curl --fail --silent --show-error --head --max-time 10 https://brew.sh/ >/dev/null || fail 'Cannot reach https://brew.sh/. Check network, proxy, VPN, or TLS, then retry.'
}
preflight() {
  say '==> 1/7 Preflight'; require_apple_silicon_macos; check_command_line_tools
  ((VERIFY_ONLY)) || check_network
  report_pending_targets
  say "Platform: Apple Silicon macOS; CLT: $(xcode-select -p)"
}
report_pending_targets() {
  local target kind
  for target in "$HOME/.zprofile" "$HOME/.zshrc" "${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml" "$HOME/.oh-my-zsh" "$HOME/.config/ghostty" "$HOME/.config/nvim" "$HOME/.config/karabiner" "$HOME/.config/opencode"; do
    if [[ -L $target ]]; then kind="symbolic link -> $(readlink "$target")"; elif [[ -d $target ]]; then kind='directory'; elif [[ -f $target ]]; then kind='file'; else kind='absent'; fi
    say "Inspect target: $target ($kind)"
  done
}
activate_brew() {
  [[ -x $BREW_BIN ]] || fail "Homebrew not found at $BREW_BIN. Run /opt/homebrew/bin/brew doctor and retry."
  eval "$("$BREW_BIN" shellenv)"
  command -v brew >/dev/null || fail 'Homebrew shell environment could not be activated.'
}
bootstrap_homebrew() {
  say '==> 2/7 Homebrew bootstrap'
  if [[ ! -x $BREW_BIN ]]; then
    say "Homebrew is absent. Official installer will modify $BREW_PREFIX."
    if ((DRY_RUN)); then say '+ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'; else /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; fi
  else say "Homebrew already installed: $BREW_BIN"; fi
  activate_brew; say "Homebrew active: $(command -v brew)"
}
install_brew_packages() { say '==> 3/7 Homebrew packages'; activate_brew; run brew bundle install --file "$DOTFILES_DIR/Brewfile" --no-upgrade; }

backup_file_once() {
  local path=$1 backup
  [[ -e $path || -L $path ]] || return 0
  backup="${path}.dotfiles-backup-$(date +%Y%m%d%H%M%S)"
  say "Backup before managed update: $path -> $backup"; run cp -p "$path" "$backup"
}
replace_managed_block() {
  local file=$1 body=$2 temp
  mkdir -p "$(dirname "$file")"
  if [[ ! -e $file ]]; then say "Create shell startup file: $file"; ((DRY_RUN)) || : > "$file"; fi
  grep -Fq "$MANAGED_BEGIN" "$file" 2>/dev/null || backup_file_once "$file"
  say "Update managed shell block: $file"; ((DRY_RUN)) && return 0
  temp="$(mktemp "${TMPDIR:-/tmp}/dotfiles-zsh.XXXXXX")"
  awk -v begin="$MANAGED_BEGIN" -v end="$MANAGED_END" '$0 == begin {skip=1;next} $0 == end {skip=0;next} !skip {print}' "$file" > "$temp"
  { cat "$temp"; [[ -s $temp ]] && printf '\n'; printf '%s\n%s\n%s\n' "$MANAGED_BEGIN" "$body" "$MANAGED_END"; } > "${temp}.new"
  mv "${temp}.new" "$file"; rm -f "$temp"
}
configure_mise() {
  say '==> 4/7 mise runtimes'; activate_brew; command -v mise >/dev/null || fail 'mise unavailable after Homebrew installation. Retry: brew install mise'
  local node_version python_version config
  node_version="$(mise latest node)" || fail 'Could not resolve latest stable Node.js. Check network and retry.'
  python_version="$(mise latest python)" || fail 'Could not resolve latest stable Python. Check network and retry.'
  config="${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml"
  say "Global mise versions to pin: node@$node_version, python@$python_version"
  if [[ -f $config ]] && grep -Fqx "node = \"$node_version\"" "$config" && grep -Fqx "python = \"$python_version\"" "$config"; then
    say 'mise global versions already match; no configuration change needed.'
  else
    [[ -f $config ]] && backup_file_once "$config"
    run mise use --global "node@$node_version" "python@$python_version"
  fi
}
configure_zsh() {
  say '==> 5/7 zsh environment'
  replace_managed_block "$HOME/.zprofile" 'if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi'
  replace_managed_block "$HOME/.zshrc" 'if ! command -v brew >/dev/null 2>&1 && [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi'
}
install_oh_my_zsh() {
  say '==> 5/7 oh-my-zsh'
  [[ -d $HOME/.oh-my-zsh ]] && { say "oh-my-zsh already present: $HOME/.oh-my-zsh"; return; }
  say 'Install official oh-my-zsh (non-interactive; existing .zshrc preserved).'
  if ((DRY_RUN)); then say '+ KEEP_ZSHRC=yes RUNZSH=no CHSH=no sh -c "curl .../ohmyzsh/.../install.sh" "" --unattended --keep-zshrc'; else KEEP_ZSHRC=yes RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" '' --unattended --keep-zshrc; fi
}
stow_package() {
  local package=$1 target=$2 source="$DOTFILES_DIR/$package"
  [[ -d $source ]] || return 0
  if [[ -L $target ]]; then fail "$target is linked elsewhere. It will not be replaced; inspect and move it manually."; fi
  if [[ -e $target && ! -d $target ]]; then
    ((ALLOW_BACKUP)) || fail "$target is a file. It will not be overwritten; back it up or rerun with --backup."
    say "Backup conflicting file: $target -> ${target}.dotfiles-backup-<timestamp>"
    run mv "$target" "${target}.dotfiles-backup-$(date +%Y%m%d%H%M%S)"
  fi
  run mkdir -p "$target"; say "Stow $package into $target"
  if ((DRY_RUN)); then
    run stow --restow "${STOW_IGNORE_ARGS[@]}" --target "$target" --dir "$DOTFILES_DIR" "$package"
  elif ! stow --restow "${STOW_IGNORE_ARGS[@]}" --target "$target" --dir "$DOTFILES_DIR" "$package"; then
    fail "Stow conflict while linking $package. No files were overwritten; inspect the reported path, back it up, then rerun ./bin/bootstrap."
  fi
}
apply_dotfiles() {
  say '==> 6/7 dotfiles'; local config="$DOTFILES_DIR/opencode/.config/opencode"
  if [[ ! -f $config/opencode.json && -f $config/opencode.json.example ]]; then say "Create machine-local OpenCode config: $config/opencode.json"; run cp "$config/opencode.json.example" "$config/opencode.json"; fi
  run mkdir -p "$HOME/.config/opencode" "$HOME/.agents/references" "$HOME/.agents/scripts"
  local package; for package in opencode agents .codex; do stow_package "$package" "$HOME"; done
  stow_package ghostty "$HOME/.config/ghostty"; stow_package nvim "$HOME/.config/nvim"; stow_package karabiner "$HOME/.config/karabiner"
}
install_opencode_plugins() {
  ((SKIP_PLUGINS)) && { say 'OpenCode plugins skipped by request.'; return; }; local dir="$HOME/.config/opencode"
  [[ -f $dir/package.json ]] || return 0; say '==> optional OpenCode plugins'
  if command -v bun >/dev/null; then run bash -c "cd \"$dir\" && bun install"; elif command -v npm >/dev/null; then run bash -c "cd \"$dir\" && npm install"; else warn 'Bun/npm unavailable; plugins skipped. Rerun ./bin/bootstrap after mise activation.'; fi
}
remove_retired_codex_command() {
  local legacy="$HOME/.local/bin/codex-token-usage" link
  [[ -L $legacy ]] || return 0; link="$(readlink "$legacy")"
  if [[ $link == *dotfiles/codex/.local/bin/codex-token-usage ]]; then say "Remove retired Codex usage link: $legacy -> $link"; run rm "$legacy"; else warn "Retired command name points elsewhere; leaving untouched: $legacy -> $link"; fi
}
verify_command() { command -v "$1" >/dev/null && say "PASS command: $1 ($(command -v "$1"))" || { warn "MISSING command: $1"; return 1; }; }
verify_environment() {
  say '==> 7/7 verification'; require_apple_silicon_macos; activate_brew; local failed=0 cmd
  for cmd in brew mise node python zsh rg nvim ghostty lazygit codex opencode; do verify_command "$cmd" || failed=1; done
  mise current node >/dev/null 2>&1 || { warn 'mise Node.js is not active'; failed=1; }; mise current python >/dev/null 2>&1 || { warn 'mise Python is not active'; failed=1; }
  if /bin/zsh -lic 'command -v brew >/dev/null && command -v mise >/dev/null && command -v node >/dev/null && command -v python >/dev/null'; then say 'PASS new login zsh: brew, mise, node, python'; else warn 'New login zsh could not initialize required commands'; failed=1; fi
  if /bin/zsh -ic 'command -v brew >/dev/null && command -v mise >/dev/null && command -v node >/dev/null && command -v python >/dev/null'; then say 'PASS new interactive zsh: brew, mise, node, python'; else warn 'New interactive zsh could not initialize required commands'; failed=1; fi
  [[ ! -e $DOTFILES_DIR/codex/.local/bin/codex-token-usage ]] || { warn 'Retired Codex usage implementation remains'; failed=1; }
  if ! command -v rg >/dev/null; then
    warn 'Cannot inspect retired references because rg is unavailable'; failed=1
  elif rg -n -i 'codex[-_ ]?(token[-_ ]?)?usage' "$DOTFILES_DIR" -g '!/.git/**' -g '!scripts/bootstrap-lib.sh' -g '!tests/test_bootstrap_static.sh' >/dev/null 2>&1; then
    warn 'Retired Codex usage references remain'; failed=1
  else
    say 'PASS retired Codex usage references: none outside removal guard'
  fi
  ((failed == 0)) || fail 'Verification failed. Resolve warnings, then run ./bin/verify.'
}
