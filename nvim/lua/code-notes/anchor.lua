local M = {}

local function lines_for(path)
  if not vim.uv.fs_stat(path) then
    return nil
  end
  return vim.fn.readfile(path)
end

local function slice(lines, start_line, end_line)
  local result = {}
  for line = start_line, end_line do
    table.insert(result, lines[line] or "")
  end
  return result
end

local function same_lines(left, right)
  if #left ~= #right then
    return false
  end
  for index, value in ipairs(left) do
    if value ~= right[index] then
      return false
    end
  end
  return true
end

function M.create(lines, start_line, end_line)
  local snippet = slice(lines, start_line, end_line)
  return {
    snippet = snippet,
    hash = vim.fn.sha256(table.concat(snippet, "\n")),
    before_hash = vim.fn.sha256(table.concat(slice(lines, math.max(1, start_line - 2), start_line - 1), "\n")),
    after_hash = vim.fn.sha256(table.concat(slice(lines, end_line + 1, math.min(#lines, end_line + 2)), "\n")),
  }
end

local function unique_match(lines, snippet)
  if #snippet == 0 or #snippet > #lines then
    return nil
  end
  local found
  for start_line = 1, #lines - #snippet + 1 do
    if same_lines(slice(lines, start_line, start_line + #snippet - 1), snippet) then
      if found then
        return nil
      end
      found = start_line
    end
  end
  return found
end

function M.validate(note, project_root)
  local path = vim.fs.joinpath(project_root, note.relative_path)
  local lines = lines_for(path)
  if not lines then
    if note.status == "legacy" and note.last_start_line then
      note.start_line = note.last_start_line
      note.end_line = note.last_end_line
    end
    note.status = "orphan"
    return true
  end
  if note.kind == "file" then
    note.status = "active"
    return false
  end

  local anchor = note.anchor
  local start_line = note.start_line
  local end_line = note.end_line
  if start_line > 0 and end_line >= start_line and same_lines(slice(lines, start_line, end_line), anchor.snippet) then
    if note.status ~= "active" then
      note.status = "active"
      return true
    end
    return false
  end

  local relocated = unique_match(lines, anchor.snippet)
  if relocated then
    note.start_line = relocated
    note.end_line = relocated + #anchor.snippet - 1
    note.last_start_line = note.start_line
    note.last_end_line = note.end_line
    note.status = "active"
    return true
  end

  note.last_start_line = note.last_start_line or note.start_line
  note.last_end_line = note.last_end_line or note.end_line
  note.start_line = 0
  note.end_line = 0
  note.status = "legacy"
  return true
end

return M
