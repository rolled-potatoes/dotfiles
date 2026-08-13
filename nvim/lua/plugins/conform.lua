return {
	"stevearc/conform.nvim",
	cmd = "ConformInfo",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", "prettier", stop_after_first = true },
			scss = { "prettierd", "prettier", stop_after_first = true },
			html = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		},
	},
	keys = {
		{
			"<leader>p",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			desc = "현재 파일 포매팅",
		},
	},
}
