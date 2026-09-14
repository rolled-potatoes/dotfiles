local M = {}

local uv = vim.uv

local function decode(path)
  if not uv.fs_stat(path) then
    return nil
  end
  local lines = vim.fn.readfile(path)
  if #lines == 0 then
    return nil
  end
  local ok, value = pcall(vim.fn.json_decode, table.concat(lines, "\n"))
  return ok and value or nil
end

local function write_atomic(path, value)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local temporary = path .. ".tmp-" .. tostring(uv.os_getpid()) .. "-" .. tostring(uv.hrtime())
  local fd, open_error = uv.fs_open(temporary, "w", 384)
  assert(fd, open_error)
  local payload = vim.fn.json_encode(value)
  assert(uv.fs_write(fd, payload, 0))
  assert(uv.fs_fsync(fd))
  assert(uv.fs_close(fd))
  local ok, rename_error = uv.fs_rename(temporary, path)
  if not ok then
    uv.fs_unlink(temporary)
    error(rename_error)
  end
end

function M.project_dir(notes_dir, project)
  return vim.fs.joinpath(notes_dir, project.key)
end

function M.note_dir(notes_dir, project)
  return vim.fs.joinpath(M.project_dir(notes_dir, project), "notes")
end

local function index_path(notes_dir, project)
  return vim.fs.joinpath(M.project_dir(notes_dir, project), "index.json")
end

local function load_index(notes_dir, project)
  return decode(index_path(notes_dir, project))
end

local function save_index(notes_dir, project, index)
  write_atomic(index_path(notes_dir, project), index)
end

local function build_index(notes)
  local index = { files = {}, ids = {} }
  for _, note in ipairs(notes) do
    index.files[note.relative_path] = index.files[note.relative_path] or {}
    table.insert(index.files[note.relative_path], note.id)
    index.ids[note.id] = note.relative_path
  end
  return index
end

function M.save_project(notes_dir, project)
  local path = vim.fs.joinpath(M.project_dir(notes_dir, project), "project.json")
  if not uv.fs_stat(path) then
    write_atomic(path, project)
  end
end

function M.save(notes_dir, project, note)
  M.save_project(notes_dir, project)
  write_atomic(vim.fs.joinpath(M.note_dir(notes_dir, project), note.id .. ".json"), note)
  local index = load_index(notes_dir, project) or build_index(M.list(notes_dir, project))
  local previous_path = index.ids[note.id]
  if previous_path and previous_path ~= note.relative_path then
    local ids = index.files[previous_path] or {}
    index.files[previous_path] = vim.tbl_filter(function(id)
      return id ~= note.id
    end, ids)
  end
  index.files[note.relative_path] = index.files[note.relative_path] or {}
  if not vim.tbl_contains(index.files[note.relative_path], note.id) then
    table.insert(index.files[note.relative_path], note.id)
  end
  index.ids[note.id] = note.relative_path
  save_index(notes_dir, project, index)
end

function M.list(notes_dir, project)
  local directory = M.note_dir(notes_dir, project)
  if not uv.fs_stat(directory) then
    return {}
  end
  local notes = {}
  for _, name in ipairs(vim.fn.readdir(directory)) do
    if name:sub(-5) == ".json" then
      local note = decode(vim.fs.joinpath(directory, name))
      if note then
        table.insert(notes, note)
      end
    end
  end
  table.sort(notes, function(left, right)
    return (left.updated_at or "") > (right.updated_at or "")
  end)
  return notes
end

function M.list_for_file(notes_dir, project, relative_path)
  local index = load_index(notes_dir, project)
  if not index or type(index.files) ~= "table" or type(index.ids) ~= "table" then
    local notes = M.list(notes_dir, project)
    return vim.tbl_filter(function(note)
      return note.relative_path == relative_path
    end, notes)
  end

  local notes = {}
  for _, id in ipairs(index.files[relative_path] or {}) do
    local note = decode(vim.fs.joinpath(M.note_dir(notes_dir, project), id .. ".json"))
    if note then
      table.insert(notes, note)
    end
  end
  table.sort(notes, function(left, right)
    return (left.updated_at or "") > (right.updated_at or "")
  end)
  return notes
end

function M.delete(notes_dir, project, id)
  local path = vim.fs.joinpath(M.note_dir(notes_dir, project), id .. ".json")
  if uv.fs_stat(path) then
    assert(uv.fs_unlink(path))
  end
  local index = load_index(notes_dir, project)
  if index and index.ids and index.ids[id] then
    local relative_path = index.ids[id]
    index.ids[id] = nil
    index.files[relative_path] = vim.tbl_filter(function(indexed_id)
      return indexed_id ~= id
    end, index.files[relative_path] or {})
    save_index(notes_dir, project, index)
  end
end

function M.clear(notes_dir, project)
  for _, note in ipairs(M.list(notes_dir, project)) do
    M.delete(notes_dir, project, note.id)
  end
  save_index(notes_dir, project, { files = {}, ids = {} })
end

return M
