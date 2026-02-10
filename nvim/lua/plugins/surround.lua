return {
	"kylechui/nvim-surround",
	version = "^3.0.0", 
	event = "VeryLazy",
	config = function()
		local surround = require("nvim-surround")
    surround.setup{}
	end,
}
