return {
	"windwp/nvim-ts-autotag",
	event = "InsertEnter",
	config = function()
		local autotag = require("nvim-ts-autotag")

		autotag.setup({})
	end,
}
