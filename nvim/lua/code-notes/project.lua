local M = {}

local function canonical(path)
  local expanded = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
  return vim.uv.fs_realpath(expanded) or vim.fs.normalize(expanded)
end

local function git_root(start_dir)
  if vim.fn.executable("git") ~= 1 then
    return nil
  end
  local output = vim.fn.systemlist({ "git", "-C", start_dir, "rev-parse", "--show-toplevel" })
  if vim.v.shell_error ~= 0 or not output[1] then
    return nil
  end
  return canonical(output[1])
end

function M.resolve(start_dir)
  local repository_root = git_root(start_dir)
  local root = repository_root or canonical(start_dir)
  local name = vim.fn.fnamemodify(root, ":t")
  if name == "" then
    name = "project"
  end
  local safe_name = name:gsub("[^%w_.-]", "-")
  return {
    root = root,
    key = safe_name .. "-" .. vim.fn.sha256(root):sub(1, 12),
    is_git = repository_root ~= nil,
  }
end

function M.relative_path(root, path)
  local relative = vim.fs.relpath(root, canonical(path))
  if not relative or relative:sub(1, 3) == "../" then
    return nil
  end
  return relative
end

function M.is_within(parent, child)
  parent = canonical(parent):gsub("/+$", "")
  child = canonical(child):gsub("/+$", "")
  return child == parent or child:sub(1, #parent + 1) == parent .. "/"
end

return M
