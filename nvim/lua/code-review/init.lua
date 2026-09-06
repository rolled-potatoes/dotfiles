local M = {}

local state = { enabled = false, previous = {} }
local group = vim.api.nvim_create_augroup("code_review_mode", { clear = true })

local function is_regular_file_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
    return false
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" or name:match("^%a[%w+.-]*://") then
    return false
  end

  local stat = vim.uv.fs_stat(name)
  return not stat or stat.type ~= "directory"
end

local function restrict(bufnr)
  if not state.enabled or not is_regular_file_buffer(bufnr) then
    return
  end
  if not state.previous[bufnr] then
    state.previous[bufnr] = {
      readonly = vim.bo[bufnr].readonly,
      modifiable = vim.bo[bufnr].modifiable,
    }
  end
  vim.bo[bufnr].readonly = true
  vim.bo[bufnr].modifiable = false
end

local function restore_all()
  for bufnr, options in pairs(state.previous) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.bo[bufnr].readonly = options.readonly
      vim.bo[bufnr].modifiable = options.modifiable
    end
  end
  state.previous = {}
end

function M.is_enabled()
  return state.enabled
end

function M.status()
  local message = state.enabled and "CodeReview: enabled" or "CodeReview: disabled"
  vim.notify(message, vim.log.levels.INFO)
  return state.enabled
end

function M.enable()
  if state.enabled then
    return M.status()
  end
  state.enabled = true
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    restrict(bufnr)
  end
  vim.notify("CodeReview: enabled (regular file buffers are not modifiable)", vim.log.levels.INFO)
end

function M.disable()
  if not state.enabled then
    return M.status()
  end
  state.enabled = false
  restore_all()
  vim.notify("CodeReview: disabled (pre-plugin buffer options restored)", vim.log.levels.INFO)
end

function M.toggle()
  if state.enabled then
    M.disable()
  else
    M.enable()
  end
end

local function readonly_argument_present()
  for _, argument in ipairs(vim.v.argv) do
    if argument == "-R" then
      return true
    end
  end
  return false
end

function M.setup()
  vim.api.nvim_create_user_command("CodeReviewEnable", M.enable, { desc = "탐색 전용 모드 활성화" })
  vim.api.nvim_create_user_command("CodeReviewDisable", M.disable, { desc = "탐색 전용 모드 비활성화" })
  vim.api.nvim_create_user_command("CodeReviewToggle", M.toggle, { desc = "탐색 전용 모드 전환" })
  vim.api.nvim_create_user_command("CodeReviewStatus", M.status, { desc = "탐색 전용 모드 상태" })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufEnter" }, {
    group = group,
    callback = function(args)
      vim.schedule(function()
        restrict(args.buf)
      end)
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(args)
      state.previous[args.buf] = nil
    end,
  })

  if readonly_argument_present() then
    M.enable()
    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      once = true,
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        if state.previous[bufnr] then
          -- Neovim finishes applying -R after early buffer events. Keep that
          -- native readonly value while preserving the original modifiable one.
          state.previous[bufnr].readonly = vim.bo[bufnr].readonly
        end
      end,
    })
  end
end

return M
