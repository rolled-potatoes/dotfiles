return {
	"windwp/nvim-ts-autotag",
	ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "markdown" },
	config = function()
		local autotag = require("nvim-ts-autotag")

		autotag.setup({})
	end,
}
