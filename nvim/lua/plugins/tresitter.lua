return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	opts = {
		install_dir = vim.fn.stdpath("data") .. "/site",
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
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter_highlighting", { clear = true }),
			pattern = { "css", "html", "javascript", "json", "lua", "markdown", "scss", "typescript", "typescriptreact", "vim" },
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
			end,
		})
	end,
}
