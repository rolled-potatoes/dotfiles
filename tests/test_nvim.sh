#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_root="$(mktemp -d)"
trap 'rm -rf "$temporary_root"' EXIT
project_dir="$temporary_root/project"
notes_dir="$temporary_root/notes"
mkdir -p "$project_dir/src" "$notes_dir"
printf '%s\n' 'local one = 1' 'local two = 2' 'local three = 3' 'return one' > "$project_dir/src/sample.lua"
git -C "$project_dir" init -q

CODE_NOTES_NVIM_DIR="$ROOT" \
CODE_NOTES_TEST_PROJECT_DIR="$project_dir" \
CODE_NOTES_TEST_NOTES_DIR="$notes_dir" \
nvim --headless -u "$ROOT/tests/nvim/minimal_init.lua" "$project_dir/src/sample.lua" -l "$ROOT/tests/nvim/test_code_notes.lua"

printf '%s\n' 'local one = 1' 'local two = 2' 'local three = 3' 'return one' > "$project_dir/src/sample.lua"
review_state="$temporary_root/review-state"
CODE_NOTES_NVIM_DIR="$ROOT" \
CODE_NOTES_TEST_PROJECT_DIR="$project_dir" \
CODE_NOTES_TEST_NOTES_DIR="$notes_dir" \
CODE_REVIEW_ASSERT_FILE="$review_state" \
nvim --headless -u "$ROOT/tests/nvim/minimal_init.lua" -R "$project_dir/src/sample.lua" \
  '+lua local review=require("code-review"); assert(review.is_enabled()); assert(vim.bo.readonly); assert(not vim.bo.modifiable); vim.api.nvim_exec_autocmds("VimEnter", {})' +qa
test "$(<"$review_state")" = true

CODE_NOTES_NVIM_DIR="$ROOT" \
CODE_NOTES_TEST_PROJECT_DIR="$project_dir" \
CODE_NOTES_TEST_NOTES_DIR="$notes_dir" \
nvim --headless -u "$ROOT/tests/nvim/minimal_init.lua" "$project_dir/src/sample.lua" \
  '+lua local original=vim.api.nvim_get_current_buf(); require("code-review").enable(); assert(not vim.bo[original].modifiable); local b=vim.api.nvim_create_buf(false,true); vim.bo[b].buftype="nofile"; vim.api.nvim_set_current_buf(b); assert(vim.bo[b].modifiable); require("code-review").disable(); assert(vim.bo[original].modifiable)' +qa

non_git_dir="$temporary_root/non-git-start"
mkdir -p "$non_git_dir"
CODE_NOTES_NVIM_DIR="$ROOT" \
CODE_NOTES_TEST_PROJECT_DIR="$non_git_dir" \
CODE_NOTES_TEST_NOTES_DIR="$non_git_dir/code-notes" \
nvim --headless -u "$ROOT/tests/nvim/minimal_init.lua" +qa
