vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 현재 설정은 원격 플러그인 provider를 사용하지 않는다.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

require("config.option")
require("config.base-keymap")
require("config.lazy")
