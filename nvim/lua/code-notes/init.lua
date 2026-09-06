local project_module = require("code-notes.project")
local storage = require("code-notes.storage")
local anchor = require("code-notes.anchor")
local ui = require("code-notes.ui")

local M = {}
local config
local project
local namespace = vim.api.nvim_create_namespace("code_notes")
local group = vim.api.nvim_create_augroup("code_notes", { clear = true })

local function now()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function note_id()
  return vim.fn.sha256(table.concat({ project.root, tostring(vim.uv.hrtime()), tostring(math.random()) }, ":")):sub(1, 24)
end

local function current_file()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" or not vim.uv.fs_stat(path) then
    vim.notify("저장된 일반 파일 버퍼에서만 메모를 만들 수 있습니다", vim.log.levels.WARN)
    return nil
  end
  local relative = project_module.relative_path(project.root, path)
  if not relative then
    vim.notify("현재 파일이 현재 프로젝트 밖에 있습니다", vim.log.levels.WARN)
    return nil
  end
  return path, relative
end

local function save(note)
  note.updated_at = now()
  storage.save(config.notes_dir, project, note)
end

local function validate_notes(notes)
  for _, note in ipairs(notes) do
    if anchor.validate(note, project.root) then
      save(note)
    end
  end
  return notes
end

function M.notes()
  return validate_notes(storage.list(config.notes_dir, project))
end

function M.filtered_notes(options)
  options = options or {}
  local notes = M.notes()
  local result = {}
  local current = vim.api.nvim_buf_get_name(0)
  local current_relative = current ~= "" and project_module.relative_path(project.root, current) or nil
  for _, note in ipairs(notes) do
    local include = (not options.status or note.status == options.status)
    include = include and (not options.buffer or note.relative_path == current_relative)
    include = include and (not options.path or note.relative_path:lower():find(options.path:lower(), 1, true))
    include = include and (not options.grep or note.content:lower():find(options.grep:lower(), 1, true))
    if include then
      table.insert(result, note)
    end
  end
  return result
end

local function refresh_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local relative = name ~= "" and project_module.relative_path(project.root, name) or nil
  if not relative then
    return
  end
  for _, note in ipairs(M.notes()) do
    if note.status == "active" and note.relative_path == relative then
      local line = note.kind == "file" and 0 or math.max(0, note.start_line - 1)
      vim.api.nvim_buf_set_extmark(bufnr, namespace, line, 0, {
        sign_text = "●",
        sign_hl_group = "DiagnosticInfo",
        priority = 20,
      })
    end
  end
end

local function refresh_current()
  refresh_buffer(vim.api.nvim_get_current_buf())
end

local function create_note(kind, start_line, end_line)
  local path, relative = current_file()
  if not path then
    return
  end
  local lines = vim.fn.readfile(path)
  local note = {
    id = note_id(),
    project_key = project.key,
    project_root = project.root,
    relative_path = relative,
    kind = kind,
    start_line = start_line,
    end_line = end_line,
    last_start_line = start_line,
    last_end_line = end_line,
    status = "active",
    content = "",
    created_at = now(),
    updated_at = now(),
  }
  if kind ~= "file" then
    note.anchor = anchor.create(lines, start_line, end_line)
  end
  ui.edit(note, function(content)
    note.content = content
    save(note)
    refresh_current()
  end, function()
    storage.delete(config.notes_dir, project, note.id)
    refresh_current()
  end)
end

function M.create_line()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  create_note("line", line, line)
end

function M.create_visual()
  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]
  if start_line == 0 or end_line == 0 then
    vim.notify("Visual 선택 범위를 찾을 수 없습니다", vim.log.levels.WARN)
    return
  end
  create_note("range", math.min(start_line, end_line), math.max(start_line, end_line))
end

function M.create_file()
  create_note("file", 0, 0)
end

function M.delete_note(note)
  storage.delete(config.notes_dir, project, note.id)
  refresh_current()
end

function M.edit_note(note)
  ui.edit(note, function(content)
    note.content = content
    save(note)
    refresh_current()
  end, function()
    M.delete_note(note)
  end)
end

function M.open_note(note)
  local function update(content)
    note.content = content
    save(note)
    refresh_current()
  end
  local function remove()
    M.delete_note(note)
  end
  if note.status == "orphan" then
    return ui.view(note, update, remove)
  end
  local path = vim.fs.joinpath(project.root, note.relative_path)
  if note.status == "active" and vim.uv.fs_stat(path) then
    vim.cmd.edit(vim.fn.fnameescape(path))
    if note.start_line > 0 then
      vim.api.nvim_win_set_cursor(0, { note.start_line, 0 })
    end
  end
  ui.view(note, update, remove)
end

local function current_notes()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local path = vim.api.nvim_buf_get_name(0)
  local relative = path ~= "" and project_module.relative_path(project.root, path) or nil
  return vim.tbl_filter(function(note)
    return note.relative_path == relative and (note.kind == "file" or (note.status == "active" and note.start_line <= line and line <= note.end_line))
  end, M.notes())
end

local function choose_current(action)
  local matches = current_notes()
  if #matches == 0 then
    vim.notify("현재 위치에 메모가 없습니다", vim.log.levels.INFO)
  elseif #matches == 1 then
    action(matches[1])
  else
    vim.ui.select(matches, {
      prompt = "메모 선택",
      format_item = function(note)
        return string.format("[%s] %s", note.status, note.content:gsub("\n.*", ""))
      end,
    }, action)
  end
end

function M.show_current()
  choose_current(M.open_note)
end

function M.edit_current()
  choose_current(M.edit_note)
end

function M.delete_current()
  choose_current(function(note)
    if vim.fn.confirm("이 메모를 삭제할까요?", "&삭제\n&취소", 2) == 1 then
      M.delete_note(note)
    end
  end)
end

function M.format_notes(notes)
  return table.concat(vim.tbl_map(function(note)
    return table.concat({ note.relative_path, string.format("%d:%d", note.start_line, note.end_line), note.content }, "\n")
  end, notes), "\n\n")
end

function M.copy_notes(notes)
  vim.fn.setreg("+", M.format_notes(notes))
  vim.notify(string.format("%d개 코드 메모를 시스템 클립보드에 복사했습니다", #notes), vim.log.levels.INFO)
end

function M.open_picker(options)
  require("code-notes.telescope").open(M, options or {})
end

function M.clear()
  if vim.fn.confirm("현재 프로젝트의 모든 코드 메모를 삭제할까요?", "&삭제\n&취소", 2) == 1 then
    storage.clear(config.notes_dir, project)
    refresh_current()
    vim.notify("현재 프로젝트의 코드 메모를 삭제했습니다", vim.log.levels.INFO)
  end
end

function M.show_help()
  ui.help()
end

local function configure(options)
  options = options or {}
  local notes_dir = options.notes_dir or (config and config.notes_dir) or "~/code-notes"
  local start_dir = options.start_dir or (project and project.root) or vim.fn.getcwd()
  local next_config = { notes_dir = vim.fn.fnamemodify(vim.fn.expand(notes_dir), ":p") }
  local next_project = project_module.resolve(start_dir)
  if next_project.is_git and project_module.is_within(next_project.root, next_config.notes_dir) then
    error("code-notes: notes_dir must be outside the project root")
  end
  config = next_config
  project = next_project
end

function M.setup(options)
  if config then
    if options and next(options) then
      configure(options)
      refresh_current()
    end
    return M
  end
  configure(options)

  vim.api.nvim_create_user_command("CodeNoteLine", M.create_line, { desc = "현재 줄 코드 메모 만들기" })
  vim.api.nvim_create_user_command("CodeNoteRange", M.create_visual, { desc = "Visual 범위 코드 메모 만들기" })
  vim.api.nvim_create_user_command("CodeNoteFile", M.create_file, { desc = "파일 코드 메모 만들기" })
  vim.api.nvim_create_user_command("CodeNoteShow", M.show_current, { desc = "현재 위치 코드 메모 보기" })
  vim.api.nvim_create_user_command("CodeNoteEdit", M.edit_current, { desc = "현재 위치 코드 메모 수정" })
  vim.api.nvim_create_user_command("CodeNoteDelete", M.delete_current, { desc = "현재 위치 코드 메모 삭제" })
  vim.api.nvim_create_user_command("CodeNotes", function()
    M.open_picker({ title = "Code Notes" })
  end, { desc = "프로젝트 코드 메모" })
  vim.api.nvim_create_user_command("CodeNotesPath", function(args)
    M.open_picker({ title = "Code Notes: path", path = args.args })
  end, { nargs = 1, desc = "경로로 코드 메모 검색" })
  vim.api.nvim_create_user_command("CodeNotesGrep", function(args)
    M.open_picker({ title = "Code Notes: grep", grep = args.args })
  end, { nargs = 1, desc = "본문으로 코드 메모 검색" })
  vim.api.nvim_create_user_command("CodeNotesBuffer", function()
    M.open_picker({ title = "Code Notes: buffer", buffer = true })
  end, { desc = "현재 버퍼 코드 메모" })
  vim.api.nvim_create_user_command("CodeNotesStatus", function(args)
    M.open_picker({ title = "Code Notes: " .. args.args, status = args.args })
  end, { nargs = 1, complete = function()
    return { "active", "legacy", "orphan" }
  end, desc = "상태로 코드 메모 검색" })
  vim.api.nvim_create_user_command("CodeNotesCopy", function()
    M.copy_notes(M.notes())
  end, { desc = "프로젝트 코드 메모 복사" })
  vim.api.nvim_create_user_command("CodeNotesClear", M.clear, { desc = "현재 프로젝트 코드 메모 전체 삭제" })
  vim.api.nvim_create_user_command("CodeNotesHelp", M.show_help, { desc = "코드 메모 키맵 도움말" })

  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
  end
  map("n", "<leader>mn", M.create_line, "현재 줄 코드 메모 만들기")
  map("x", "<leader>mn", M.create_visual, "선택 범위 코드 메모 만들기")
  map("n", "<leader>mF", M.create_file, "파일 코드 메모 만들기")
  map("n", "<leader>mo", M.show_current, "현재 위치 코드 메모 보기")
  map("n", "<leader>me", M.edit_current, "현재 위치 코드 메모 수정")
  map("n", "<leader>md", M.delete_current, "현재 위치 코드 메모 삭제")
  map("n", "<leader>ml", function()
    M.open_picker({ title = "Code Notes" })
  end, "프로젝트 코드 메모 목록")
  map("n", "<leader>mb", function()
    M.open_picker({ title = "Code Notes: buffer", buffer = true })
  end, "현재 버퍼 코드 메모 목록")
  map("n", "<leader>mp", function()
    vim.ui.input({ prompt = "경로 검색: " }, function(value)
      if value and value ~= "" then M.open_picker({ title = "Code Notes: path", path = value }) end
    end)
  end, "경로로 코드 메모 검색")
  map("n", "<leader>mg", function()
    vim.ui.input({ prompt = "본문 검색: " }, function(value)
      if value and value ~= "" then M.open_picker({ title = "Code Notes: grep", grep = value }) end
    end)
  end, "본문으로 코드 메모 검색")
  map("n", "<leader>ms", function()
    vim.ui.select({ "active", "legacy", "orphan" }, { prompt = "상태 선택" }, function(value)
      if value then M.open_picker({ title = "Code Notes: " .. value, status = value }) end
    end)
  end, "상태로 코드 메모 검색")
  map("n", "<leader>mc", function()
    M.copy_notes(M.notes())
  end, "프로젝트 코드 메모 복사")
  map("n", "<leader>mC", M.clear, "프로젝트 코드 메모 전체 삭제")
  map("n", "<leader>m?", M.show_help, "코드 메모 키맵 도움말")

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    group = group,
    callback = function(args)
      refresh_buffer(args.buf)
    end,
  })
  return M
end

return M
