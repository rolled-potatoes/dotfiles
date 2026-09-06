local M = {}

local function popup(title, content, editable, mappings)
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.bo[buffer].buftype = editable and "acwrite" or "nofile"
  vim.bo[buffer].bufhidden = "wipe"
  vim.bo[buffer].swapfile = false
  vim.bo[buffer].filetype = "code-notes"
  vim.b[buffer].code_notes_popup = true
  vim.api.nvim_buf_set_name(buffer, "code-note://popup-" .. buffer)
  vim.bo[buffer].modifiable = true
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(content or "", "\n", { plain = true }))
  vim.bo[buffer].modifiable = editable

  local width = math.min(math.max(48, math.floor(vim.o.columns * 0.6)), math.max(48, vim.o.columns - 4))
  local height = math.min(math.max(8, math.floor(vim.o.lines * 0.45)), math.max(8, vim.o.lines - 4))
  local window = vim.api.nvim_open_win(buffer, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  })
  for lhs, callback in pairs(mappings or {}) do
    vim.keymap.set("n", lhs, callback, { buffer = buffer, silent = true, desc = "코드 메모 " .. lhs })
  end
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(window) then
      vim.api.nvim_win_close(window, true)
    end
  end, { buffer = buffer, silent = true, desc = "코드 메모 팝업 닫기" })
  return buffer, window
end

local function editable_popup(title, note, on_save, on_delete)
  local buffer, window
  buffer, window = popup(title, note.content, true)
  local function save()
    local content = table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n")
    on_save(content)
    vim.bo[buffer].modified = false
  end
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buffer,
    callback = save,
  })
  vim.keymap.set({ "n", "i" }, "<C-s>", function()
    save()
    if vim.api.nvim_win_is_valid(window) then
      vim.api.nvim_win_close(window, true)
    end
  end, { buffer = buffer, silent = true, desc = "코드 메모 저장" })
  vim.keymap.set("n", "<C-d>", function()
    if vim.fn.confirm("이 메모를 삭제할까요?", "&삭제\n&취소", 2) == 1 then
      on_delete()
      if vim.api.nvim_win_is_valid(window) then
        vim.api.nvim_win_close(window, true)
      end
    end
  end, { buffer = buffer, silent = true, desc = "코드 메모 삭제" })
end

function M.edit(note, on_save, on_delete)
  editable_popup("메모 · " .. note.status, note, on_save, on_delete)
end

function M.view(note, on_save, on_delete)
  local title = string.format("[%s] %s:%s", note.status, note.relative_path, note.start_line .. ":" .. note.end_line)
  editable_popup(title, note, on_save, on_delete)
end

function M.help()
  local lines = {
    "<leader>mn  현재 줄 / Visual 범위 메모 만들기",
    "<leader>mF  파일 메모 만들기",
    "<leader>mo  현재 위치 메모 조회·수정",
    "<leader>me  현재 위치 메모 수정",
    "<leader>md  현재 위치 메모 삭제",
    "<leader>ml  프로젝트 메모 목록",
    "<leader>mb  현재 버퍼 메모 목록",
    "<leader>mp  경로로 검색",
    "<leader>mg  본문으로 검색",
    "<leader>ms  상태로 검색",
    "<leader>mc  프로젝트 메모 복사",
    "<leader>mC  프로젝트 메모 전체 삭제",
    "",
    "popup 저장: <C-s> 또는 :w / :x   닫기: q",
  }
  local buffer = popup("코드 메모 키맵", table.concat(lines, "\n"), false)
  return buffer
end

return M
