local M = {}

local uv = vim.uv

local function decode(path)
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

function M.save_project(notes_dir, project)
  write_atomic(vim.fs.joinpath(M.project_dir(notes_dir, project), "project.json"), project)
end

function M.save(notes_dir, project, note)
  M.save_project(notes_dir, project)
  write_atomic(vim.fs.joinpath(M.note_dir(notes_dir, project), note.id .. ".json"), note)
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

function M.delete(notes_dir, project, id)
  local path = vim.fs.joinpath(M.note_dir(notes_dir, project), id .. ".json")
  if uv.fs_stat(path) then
    assert(uv.fs_unlink(path))
  end
end

function M.clear(notes_dir, project)
  for _, note in ipairs(M.list(notes_dir, project)) do
    M.delete(notes_dir, project, note.id)
  end
end

return M
