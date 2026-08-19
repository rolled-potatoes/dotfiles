return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	opts = {
		install_dir = vim.fn.stdpath("data") .. "/site",
	},
	config = function(_, opts)
		local treesitter = require("nvim-treesitter")
		treesitter.setup(opts)
		treesitter.install({
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
		})

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter_highlighting", { clear = true }),
			pattern = { "css", "html", "javascript", "json", "lua", "markdown", "scss", "typescript", "typescriptreact", "vim" },
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
			end,
		})
	end,
}
