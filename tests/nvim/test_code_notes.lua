local notes = require("code-notes")
local project_module = require("code-notes.project")
local storage = require("code-notes.storage")
local anchor = require("code-notes.anchor")
local ui = require("code-notes.ui")
local telescope = require("code-notes.telescope")

local project_dir = assert(vim.env.CODE_NOTES_TEST_PROJECT_DIR)
local notes_dir = assert(vim.env.CODE_NOTES_TEST_NOTES_DIR)
local project = project_module.resolve(project_dir)
local file = vim.fs.joinpath(project_dir, "src", "sample.lua")
local now = "2026-09-06T00:00:00Z"

assert(project.root == (vim.uv.fs_realpath(project_dir) or project_dir), "Git top-level is the project root")
assert(project.is_git, "Git project is identified")
assert(project_module.is_within(project.root, vim.fs.joinpath(project.root, "notes-inside-project")), "project-local notes paths are detected")

local function make_note(id, kind, start_line, end_line, content)
  local note = {
    id = id,
    project_key = project.key,
    project_root = project.root,
    relative_path = "src/sample.lua",
    kind = kind,
    start_line = start_line,
    end_line = end_line,
    last_start_line = start_line,
    last_end_line = end_line,
    status = "active",
    content = content,
    created_at = now,
    updated_at = now,
  }
  if kind ~= "file" then
    note.anchor = anchor.create(vim.fn.readfile(file), start_line, end_line)
  end
  return note
end

local line_note = make_note("line", "line", 2, 2, "line memo")
local range_note = make_note("range", "range", 3, 4, "range memo")
local file_note = make_note("file", "file", 0, 0, "file memo")
storage.save(notes_dir, project, line_note)
storage.save(notes_dir, project, range_note)
storage.save(notes_dir, project, file_note)

local loaded = notes.notes()
assert(#loaded == 3, "notes survive storage reload")
assert(loaded[1].kind == "file" or loaded[1].kind == "line" or loaded[1].kind == "range", "line/range/file CRUD records load")
assert(#notes.filtered_notes({ buffer = true }) == 3, "current buffer filter")
assert(#notes.filtered_notes({ path = "sample" }) == 3, "path filter")
assert(#notes.filtered_notes({ grep = "range" }) == 1, "body grep filter")
assert(#notes.filtered_notes({ status = "active" }) == 3, "status filter")

local copied = notes.format_notes({ line_note, file_note })
assert(copied == "src/sample.lua\n2:2\nline memo\n\nsrc/sample.lua\n0:0\nfile memo", "copy format")
assert(not copied:find("local two", 1, true), "anchor source is not exported")
assert(vim.deep_equal(telescope.preview_lines({
  status = "active",
  relative_path = "src/sample.lua",
  start_line = 2,
  end_line = 3,
  content = "first line\nsecond line",
}), {
  "상태: active",
  "파일: src/sample.lua",
  "범위: 2:3",
  "",
  "first line",
  "second line",
}), "preview splits multiline note content into buffer lines")

vim.fn.writefile({ "local inserted = true", "local one = 1", "local two = 2", "local three = 3", "return one" }, file)
local changed = anchor.validate(line_note, project.root)
assert(changed and line_note.status == "active" and line_note.start_line == 3, "unique anchor relocation")

vim.fn.writefile({ "local one = 1", "local two = 2", "local changed = 2", "local two = 2", "local three = 3", "return one" }, file)
anchor.validate(line_note, project.root)
assert(line_note.status == "legacy" and line_note.start_line == 0 and line_note.end_line == 0, "ambiguous anchor becomes legacy")

vim.fn.delete(file)
anchor.validate(line_note, project.root)
assert(line_note.status == "orphan" and line_note.start_line == 3 and line_note.end_line == 3, "legacy orphan keeps its last trusted range")
anchor.validate(file_note, project.root)
assert(file_note.status == "orphan", "missing file becomes orphan")
assert(project.key == project_module.resolve(project_dir).key, "project key is stable")

local outside = vim.fn.tempname()
vim.fn.mkdir(outside, "p")
local non_git_project = project_module.resolve(outside)
assert(not non_git_project.is_git and non_git_project.key ~= project.key, "non-git projects are separated")
vim.fn.delete(outside, "rf")

storage.delete(notes_dir, project, range_note.id)
assert(#storage.list(notes_dir, project) == 2, "delete removes one note")
storage.clear(notes_dir, project)
assert(#storage.list(notes_dir, project) == 0, "clear removes project notes")

local alternate_notes_dir = vim.fn.tempname()
assert(pcall(notes.setup, { notes_dir = alternate_notes_dir }), "setup accepts an external notes directory")
local rejected = pcall(notes.setup, { notes_dir = vim.fs.joinpath(project.root, "notes-inside-project") })
assert(not rejected, "setup rejects a notes directory inside the project")

local popup_content
ui.edit({ status = "active", content = "before" }, function(content)
  popup_content = content
end, function() end)
local popup_buffer = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(popup_buffer, 0, -1, false, { "saved with write" })
vim.cmd.write()
assert(popup_content == "saved with write", "popup :write saves the note")

local viewed_content
ui.view({ status = "active", relative_path = "src/sample.lua", start_line = 2, end_line = 2, content = "before" }, function(content)
  viewed_content = content
end, function() end)
popup_buffer = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(popup_buffer, 0, -1, false, { "saved from view" })
vim.cmd.write()
assert(viewed_content == "saved from view", "view popup is directly editable")

local help_buffer = ui.help()
assert(vim.api.nvim_buf_get_lines(help_buffer, 0, 1, false)[1]:find("<leader>mn", 1, true), "keymap help shows note mappings")
assert(vim.fn.exists(":CodeNotesHelp") == 2, "keymap help command is registered")
