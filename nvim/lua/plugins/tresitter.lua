return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		local ts = require("nvim-treesitter.configs")
		ts.setup({
			ensure_installed = {
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
			},
			auto_install = false,
			highlight = { enable = true },
		})
	end,
}
