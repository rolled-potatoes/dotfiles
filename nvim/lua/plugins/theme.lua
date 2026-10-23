return {
	"rebelot/kanagawa.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		vim.o.background = "dark"
		require("kanagawa").setup({
			colors = {
				theme = "dragon",
			},
		})
		vim.cmd.colorscheme("kanagawa-dragon")
	end,
}
