return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = "markdown",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		-- 커서가 있는 줄도 렌더링을 유지한다.
		anti_conceal = { enabled = false },
		latex = { enabled = false },
		heading = {
			sign = false,
			icons = { "[1] ", "[2] ", "[3] ", "[4] ", "[5] ", "[6] " },
			position = "inline",
			backgrounds = { "MarkdownHeading" },
			foregrounds = { "MarkdownHeading" },
		},
		code = {
			sign = false,
			language = false,
			border = "hide",
			width = "full",
			left_pad = 1,
			right_pad = 1,
			-- 둥근 양끝 자체를 여백으로 사용하고 별도 공백은 추가하지 않는다.
			inline_left = "",
			inline_right = "",
			inline_pad = 0,
			highlight = "MarkdownCodeBlock",
			highlight_inline = "MarkdownInlineCode",
			highlight_inline_left = "MarkdownInlineCodeEdge",
			highlight_inline_right = "MarkdownInlineCodeEdge",
		},
		pipe_table = {
			-- 긴 셀은 창 너비에 맞춰 표 안에서 줄바꿈한다.
			wrap = true,
			cell = "trimmed",
			padding = 1,
			border_virtual = true,
			alignment_indicator = "─",
			head = "MarkdownTableHead",
			row = "MarkdownBorder",
		},
		bullet = { icons = { "•" } },
		link = {
			image = "",
			email = "",
			hyperlink = "",
			highlight = "MarkdownLink",
		},
		quote = { highlight = "MarkdownQuote" },
		dash = { highlight = "MarkdownBorder" },
	},
	config = function(_, opts)
		-- GitHub Light를 참고해 제목 색 띠를 없애고 요소별 대비를 맞춘다.
		local function highlights()
			local groups = {
				MarkdownHeading = { fg = "#1f2328", bold = true },
				MarkdownCodeBlock = { bg = "#f6f8fa" },
				MarkdownInlineCode = { fg = "#1f2328", bg = "#d8d8d8" },
				MarkdownInlineCodeEdge = { fg = "#d8d8d8", bg = "#ffffff" },
				MarkdownBorder = { fg = "#afb8c1" },
				MarkdownTableHead = { fg = "#57606a", bold = true },
				MarkdownLink = { fg = "#0969da", underline = true },
				MarkdownQuote = { fg = "#57606a" },
			}
			for name, value in pairs(groups) do
				vim.api.nvim_set_hl(0, name, value)
			end
			vim.api.nvim_set_hl(0, "@markup.link.label.markdown_inline", { link = "MarkdownLink" })
		end

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("markdown_github_highlights", { clear = true }),
			callback = highlights,
		})
		highlights()
		-- 기본 URL별 아이콘도 생략해 링크 본문만 표시한다.
		opts.link.custom = {}
		for name in pairs(require("render-markdown").default.link.custom) do
			opts.link.custom[name] = { icon = "" }
		end
		opts.custom_handlers = {
			markdown = require("config.markdown-rounded-code"),
		}
		require("render-markdown").setup(opts)
		require("config.markdown-light").setup()
	end,
}
