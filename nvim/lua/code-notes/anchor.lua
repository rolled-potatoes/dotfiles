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

function M.validate(note, source)
  local lines
  if source == false then
    lines = nil
  elseif type(source) == "table" then
    lines = source
  else
    lines = lines_for(vim.fs.joinpath(source, note.relative_path))
  end
  if not lines then
    local changed = note.status ~= "orphan"
    if note.status == "legacy" and note.last_start_line then
      changed = changed or note.start_line ~= note.last_start_line or note.end_line ~= note.last_end_line
      note.start_line = note.last_start_line
      note.end_line = note.last_end_line
    end
    note.status = "orphan"
    return changed
  end
  if note.kind == "file" then
    local changed = note.status ~= "active"
    note.status = "active"
    return changed
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

  local last_start_line = note.last_start_line or note.start_line
  local last_end_line = note.last_end_line or note.end_line
  local changed = note.status ~= "legacy" or note.start_line ~= 0 or note.end_line ~= 0
    or note.last_start_line ~= last_start_line or note.last_end_line ~= last_end_line
  note.last_start_line = last_start_line
  note.last_end_line = last_end_line
  note.start_line = 0
  note.end_line = 0
  note.status = "legacy"
  return changed
end

return M
