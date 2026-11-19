vim.o.background = "dark"
vim.cmd("highlight clear")
vim.g.colors_name = "codex-og"

local bg, fg, cursor = "#343541", "#d1d5db", "#ececf1"
local sidebar, panel, accent = "#202123", "#444654", "#10a37f"
local comment, green, orange = "#acacbe", "#65c99a", "#f8b86f"
local purple, teal, blue, red = "#b4a1e5", "#8bd5ca", "#8dc8f4", "#f28b82"

local groups = {
	Normal = { fg = fg, bg = bg },
	Cursor = { fg = bg, bg = cursor },
	CursorLine = { bg = panel },
	CursorLineNr = { fg = cursor, bold = true },
	LineNr = { fg = comment },
	NonText = { fg = comment },
	Visual = { fg = cursor, bg = panel },
	Search = { fg = sidebar, bg = orange },
	IncSearch = { fg = sidebar, bg = green },
	StatusLine = { fg = cursor, bg = panel },
	StatusLineNC = { fg = comment, bg = sidebar },
	NormalFloat = { fg = fg, bg = sidebar },
	FloatBorder = { fg = comment, bg = sidebar },
	Pmenu = { link = "NormalFloat" },
	PmenuSel = { fg = sidebar, bg = teal },
	NvimTreeNormal = { fg = cursor, bg = sidebar },
	Comment = { fg = comment },
	String = { fg = green },
	Constant = { fg = orange },
	Character = { link = "String" },
	Statement = { fg = purple },
	PreProc = { fg = purple },
	Operator = { fg = fg },
	Delimiter = { fg = fg },
	Identifier = { fg = fg },
	["@variable"] = { link = "Identifier" },
	["@keyword.operator"] = { link = "Operator" },
	Type = { fg = teal },
	Function = { fg = blue },
	Special = { fg = orange },
	Error = { fg = red },
	DiagnosticError = { fg = red },
	DiagnosticWarn = { fg = orange },
	DiagnosticInfo = { fg = blue },
	DiagnosticHint = { fg = teal },
	DiffAdd = { fg = green, bg = panel },
	DiffDelete = { fg = red, bg = panel },
	DiffChange = { fg = blue, bg = panel },
	DiffText = { fg = sidebar, bg = blue },
	MarkdownHeading = { fg = cursor, bold = true },
	MarkdownCodeBlock = { bg = sidebar },
	MarkdownInlineCode = { fg = fg, bg = panel },
	MarkdownInlineCodeEdge = { fg = panel, bg = bg },
	MarkdownBorder = { fg = comment },
	MarkdownTableHead = { fg = cursor, bold = true },
	MarkdownLink = { fg = accent, underline = true },
	MarkdownQuote = { fg = comment },
	["@markup.link.label.markdown_inline"] = { link = "MarkdownLink" },
	["@markup.raw.markdown_inline"] = { link = "MarkdownInlineCode" },
}
for group, attributes in pairs(groups) do
	vim.api.nvim_set_hl(0, group, attributes)
end

local ansi = { sidebar, red, green, orange, blue, purple, teal, fg, comment, red, green, orange, blue, purple, teal, cursor }
for index, color in ipairs(ansi) do
	vim.g["terminal_color_" .. (index - 1)] = color
end
