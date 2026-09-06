local root = assert(vim.env.CODE_NOTES_NVIM_DIR, "CODE_NOTES_NVIM_DIR is required")
vim.opt.runtimepath:append(root .. "/nvim")
vim.g.mapleader = " "
require("code-review").setup()
require("code-notes").setup({
  notes_dir = assert(vim.env.CODE_NOTES_TEST_NOTES_DIR, "CODE_NOTES_TEST_NOTES_DIR is required"),
  start_dir = assert(vim.env.CODE_NOTES_TEST_PROJECT_DIR, "CODE_NOTES_TEST_PROJECT_DIR is required"),
})

if vim.env.CODE_REVIEW_ASSERT_FILE then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      require("code-review").disable()
      vim.fn.writefile({ tostring(vim.bo.readonly and vim.bo.modifiable) }, vim.env.CODE_REVIEW_ASSERT_FILE)
    end,
  })
end
