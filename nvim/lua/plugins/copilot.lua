return {
  "github/copilot.vim",
  init = function()
    vim.g.copilot_no_tab_map = true

    vim.keymap.set("i", "<C-]>", 'copilot#Accept("\\<C-]>")', {
      expr = true,
      replace_keycodes = false,
      silent = true,
      desc = "Copilot: 제안 수락",
    })
  end,
}
