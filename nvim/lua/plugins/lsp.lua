-- lua/plugins/lsp.lua
return {
	-- 1. LSP 핵심 설정 (lspconfig)
	{
		"neovim/nvim-lspconfig",
		-- 플러그인이 로드될 때 실행할 설정 함수
		config = function()
			-- === 필수 모듈 로드 ===
			local lspconfig = require("lspconfig")
			local mason_lspconfig = require("mason-lspconfig")
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			local capabilities = cmp_nvim_lsp.default_capabilities()
			-- === 3. Mason 설정 (언어 서버 설치) ===
			-- Node.js 풀스택 개발을 위한 기본 언어 서버 목록
			local servers = {
				"ts_ls", -- TypeScript/JavaScript
				"eslint", -- ESLint (Linter)
				"jsonls", -- JSON
				"cssls", -- CSS
				"html", -- HTML
				"dockerls", -- Dockerfile
				"marksman", -- Markdown
				"bashls", -- Shell 스크립트
				"tailwindcss",
				"stylua",
			}

			require("mason").setup()
			mason_lspconfig.setup({
				ensure_installed = servers, -- 이 서버들이 자동으로 설치되도록 보장
				automatic_installation = true, -- 서버가 없을 경우 자동 설치
				automatic_enable = true,
			})

			local on_attach = function(client, bufnr)
				-- 도움말, 정의 추적, 코드 액션 등 LSP 핵심 기능 키매핑
				local opts = { buffer = bufnr, noremap = true, silent = true }
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				-- 진단(Diagnostics) 관련 키매핑
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
			end

			-- 서버별 커스텀 설정
			local server_configs = {
				-- 모노레포 환경에서 각 패키지의 package.json 기준으로 working directory를 잡아
				-- @typescript-eslint 등 플러그인을 올바른 node_modules에서 resolve하도록 설정
				eslint = {
					root_dir = require("lspconfig.util").root_pattern(
						".eslintrc",
						".eslintrc.js",
						".eslintrc.cjs",
						".eslintrc.json",
						"eslint.config.js",
						"eslint.config.mjs",
						"eslint.config.cjs",
						"package.json"
					),
					settings = {
						workingDirectory = { mode = "auto" },
					},
				},
			}

			for _, server_name in ipairs(servers) do
				local config = server_configs[server_name] or {}
				config.on_attach = on_attach
				config.capabilities = capabilities
				vim.lsp.config(server_name, config)
			end
		end,

		-- === 의존성 플러그인 목록 ===
		dependencies = {
			-- 언어 서버 자동 설치 및 관리
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
		},
	},
}
