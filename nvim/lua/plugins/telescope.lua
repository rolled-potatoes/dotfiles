-- fuzzy finder: 파일 탐색기
-- https://github.com/nvim-telescope/telescope.nvim
return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				file_ignore_patterns = {
					".git",
					".DS_Store",
					"%.cache/",
					"node_modules",
					"dist",
					"build",
				},
				cache_picker = {
					num_pickers = 10, -- 최근 10개 검색 캐시
					limit_entries = 1000, -- 각 picker당 최대 1000개 항목
				},
			},
			pickers = {
				find_files = {
					theme = "dropdown",
				},
			},
		})

		vim.keymap.set("n", "<leader>ff", function()
			builtin.find_files({
				no_ignore = false,
				hidden = true,
			})
		end, { desc = "Telescope find files", noremap = true, silent = true })

		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
		vim.keymap.set("n", "<leader>fl", builtin.diagnostics, { desc = "Telescope buffers" })

		-- 검색 기록 관련 키맵
		vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Telescope resume last search" })
		vim.keymap.set("n", "<leader>fp", builtin.pickers, { desc = "Telescope cached pickers" })
	end,
}
