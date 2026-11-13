local M = {}
local namespace = vim.api.nvim_create_namespace("markdown_light")
local previous = {}

local function highlights()
	-- 기존 테마의 밝은 문법 강조를 재사용하되 전체 colorscheme은 바꾸지 않는다.
	local colors = require("kanagawa.colors").setup({
		theme = "lotus",
		colors = {
			palette = {},
			theme = {
				all = {
					ui = {
						fg = "#1f2328",
						fg_dim = "#57606a",
						bg = "#ffffff",
						bg_dim = "#ffffff",
						bg_gutter = "#f6f8fa",
						bg_m3 = "#eff1f3",
						bg_m2 = "#f6f8fa",
						bg_m1 = "#f6f8fa",
						bg_p1 = "#f6f8fa",
						bg_p2 = "#eff1f3",
						bg_visual = "#c8e1ff",
						bg_search = "#fff8c5",
						nontext = "#6e7781",
						whitespace = "#afb8c1",
					},
				},
			},
		},
	})
	local config = vim.tbl_extend("force", require("kanagawa").config, { transparent = false, dimInactive = false })
	for name, value in pairs(require("kanagawa.highlights").setup(colors, config)) do
		vim.api.nvim_set_hl(namespace, name, value)
	end
	vim.api.nvim_set_hl(namespace, "@markup.link.label.markdown_inline", { link = "MarkdownLink" })
	vim.api.nvim_set_hl(namespace, "@markup.raw.markdown_inline", { link = "MarkdownInlineCode" })
end

local function windows()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local current = vim.api.nvim_get_hl_ns({ winid = win })
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "markdown" then
			if current ~= namespace then
				previous[win] = current
				vim.api.nvim_win_set_hl_ns(win, namespace)
			end
		elseif current == namespace then
			vim.api.nvim_win_set_hl_ns(win, previous[win] or -1)
			previous[win] = nil
		end
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup("markdown_light", { clear = true })
	vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "FileType" }, { group = group, callback = windows })
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			highlights()
			windows()
		end,
	})
	vim.api.nvim_create_autocmd("WinClosed", {
		group = group,
		callback = function(args)
			previous[tonumber(args.match)] = nil
		end,
	})
	highlights()
	windows()
end

return M
