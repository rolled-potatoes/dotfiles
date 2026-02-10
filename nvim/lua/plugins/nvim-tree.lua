-- keymap
-- 토글
-- vim.keymap.set('n','<C-n>t',':NvimTreeToggle <CR>')
-- 현재 열린 파일로 트리 검색
-- vim.keymap.set('n','<C-n>f',':NvimTreeFindFile <CR>')

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local function on_attach(bufnr)
			local api = require("nvim-tree.api")

			local function opts(desc)
				return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
			end

			-- default mappings
			api.config.mappings.default_on_attach(bufnr)
			vim.keymap.set("n", "sv", api.node.open.vertical, opts("세로 분할"))
			vim.keymap.set("n", "ss", api.node.open.horizontal, opts("가로 분할"))
		end
		require("nvim-tree").setup({
			on_attach = on_attach,
			view = {
				side = "left",
				width = '250',
			},
			git = {
				ignore = false,
			},
			view = {
				side = "left",
        width = "250"
			},
		})
		vim.keymap.set("n", "<C-n>t", ":NvimTreeToggle <CR>")
		-- 현재 열린 파일로 트리 검색
		vim.keymap.set("n", "<C-n>f", ":NvimTreeFindFile <CR>")
	end,
}
