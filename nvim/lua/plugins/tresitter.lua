return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter.configs")
		ts.setup({
			ensure_installed = {
				"lua",
				"vim",
				"markdown",
				"tsx",
				"css",
				"html",
				"javascript",
				"typescript",
				"json",
				"scss",
			},
			auto_install = true,
		})
	end,
}
