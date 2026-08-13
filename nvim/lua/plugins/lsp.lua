-- lua/plugins/lsp.lua
return {
	-- 언어 서버와 외부 도구 설치 관리자
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		opts = {},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = true,
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = { "stylua", "prettierd" },
			auto_update = false,
			run_on_start = true,
			start_delay = 3000,
			debounce_hours = 24,
		},
		config = function(_, opts)
			local installer = require("mason-tool-installer")
			installer.setup(opts)
			if vim.v.vim_did_enter == 1 then
				installer.run_on_start()
			end
		end,
	},

	-- LSP 핵심 설정
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local mason_lspconfig = require("mason-lspconfig")
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- 웹 풀스택 개발에 사용하는 서버만 자동으로 활성화한다.
			local servers = {
				"ts_ls",
				"eslint",
				"jsonls",
				"cssls",
				"html",
				"dockerls",
				"marksman",
				"bashls",
				"tailwindcss",
			}

			local on_attach = function(client, bufnr)
				local opts = { buffer = bufnr, noremap = true, silent = true }
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				vim.keymap.set("n", "[d", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, opts)
				vim.keymap.set("n", "]d", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, opts)
				vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
			end

			for _, server_name in ipairs(servers) do
				if server_name == "eslint" then
					vim.lsp.config("eslint", {
						on_attach = on_attach,
						capabilities = capabilities,
						settings = {
							-- monorepo 환경에서 파일별 ESLint 작업 디렉터리를 자동 결정한다.
							workingDirectory = { mode = "auto" },
						},
					})
				else
					vim.lsp.config(server_name, {
						on_attach = on_attach,
						capabilities = capabilities,
					})
				end
			end

			mason_lspconfig.setup({
				ensure_installed = servers,
				automatic_enable = servers,
			})
		end,

		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
	},
}
