return {
	"loctvl842/monokai-pro.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		local function apply_highlights()
			vim.api.nvim_set_hl(0, "LineNr", { fg = "#ffffff", bold = true })
			vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff", bold = true })
			vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "NONE" })
		end

		require("monokai-pro").setup({
			transparent_background = true,
		})
		vim.cmd.colorscheme("monokai-pro")
		apply_highlights()

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("custom_theme_highlights", { clear = true }),
			callback = apply_highlights,
		})
	end,
}
