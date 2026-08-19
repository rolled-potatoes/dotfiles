return {
	"rebelot/kanagawa.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		vim.o.background = "light"
		require("kanagawa").setup({
			colors = {
				theme = {
					lotus = {
						ui = {
							bg = "#e5ede6",
							bg_gutter = "#e5ede6",
						},
					},
				},
			},
		})
		vim.cmd.colorscheme("kanagawa-lotus")
	end,
}
