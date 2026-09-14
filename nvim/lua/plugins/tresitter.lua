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
		treesitter.install(require("config.nvim-bootstrap").parsers)

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter_highlighting", { clear = true }),
			pattern = { "css", "html", "javascript", "javascriptreact", "json", "lua", "markdown", "scss", "typescript", "typescriptreact", "vim" },
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			group = vim.api.nvim_create_augroup("treesitter_after_install", { clear = true }),
			pattern = "TSUpdate",
			callback = function()
				for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(bufnr) then
						pcall(vim.treesitter.start, bufnr)
					end
				end
			end,
		})
	end,
}
