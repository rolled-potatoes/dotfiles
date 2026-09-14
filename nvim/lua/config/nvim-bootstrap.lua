local M = {}

M.parsers = {
  "lua",
  "vim",
  "markdown",
  "markdown_inline",
  "tsx",
  "css",
  "html",
  "javascript",
  "typescript",
  "json",
  "scss",
}

M.mason_tools = { "stylua", "prettierd" }

function M.install_parsers()
  local installed = require("nvim-treesitter").install(M.parsers):wait(300000)
  assert(installed, "nvim-treesitter parser installation failed")
end

function M.verify()
  local missing = {}
  if vim.fn.executable("tree-sitter") ~= 1 then
    table.insert(missing, "tree-sitter-cli")
  end
  for _, parser in ipairs(M.parsers) do
    if not pcall(vim.treesitter.language.add, parser) then
      table.insert(missing, "parser:" .. parser)
    end
  end
  local packages = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages")
  for _, tool in ipairs(M.mason_tools) do
    if not vim.uv.fs_stat(vim.fs.joinpath(packages, tool)) then
      table.insert(missing, "mason:" .. tool)
    end
  end
  assert(#missing == 0, "Neovim setup is incomplete: " .. table.concat(missing, ", "))
end

return M
