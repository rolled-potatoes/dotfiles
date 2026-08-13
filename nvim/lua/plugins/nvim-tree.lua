vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<C-n>t", "<cmd>NvimTreeToggle<CR>", desc = "파일 트리 토글" },
		{ "<C-n>f", "<cmd>NvimTreeFindFile<CR>", desc = "현재 파일을 트리에서 찾기" },
	},
	opts = function()
		local function on_attach(bufnr)
			local api = require("nvim-tree.api")
			local function map(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, {
					buffer = bufnr,
					desc = "nvim-tree: " .. desc,
					nowait = true,
					silent = true,
				})
			end

			api.config.mappings.default_on_attach(bufnr)
			map("<leader>ws", api.node.open.horizontal, "가로 분할로 열기")
			map("<leader>wv", api.node.open.vertical, "세로 분할로 열기")
		end

		return {
			on_attach = on_attach,
			view = {
				side = "left",
				width = "25%",
			},
			git = {
				ignore = false,
			},
		}
	end,
}
