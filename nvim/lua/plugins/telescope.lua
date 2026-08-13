return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		defaults = {
			file_ignore_patterns = {
				"%.git/",
				"%.DS_Store",
				"%.cache/",
				"node_modules/",
				"dist/",
				"build/",
			},
			cache_picker = {
				num_pickers = 10,
				limit_entries = 1000,
			},
		},
		pickers = {
			find_files = {
				theme = "dropdown",
			},
		},
	},
	keys = {
		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files({ no_ignore = false, hidden = true })
			end,
			desc = "파일 찾기",
		},
		{
			"<leader>fg",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "문자열 찾기",
		},
		{
			"<leader>fb",
			function()
				require("telescope.builtin").buffers()
			end,
			desc = "버퍼 찾기",
		},
		{
			"<leader>fl",
			function()
				require("telescope.builtin").diagnostics()
			end,
			desc = "진단 목록",
		},
		{
			"<leader>fr",
			function()
				require("telescope.builtin").resume()
			end,
			desc = "마지막 검색 재개",
		},
		{
			"<leader>fp",
			function()
				require("telescope.builtin").pickers()
			end,
			desc = "최근 검색 목록",
		},
	},
}
