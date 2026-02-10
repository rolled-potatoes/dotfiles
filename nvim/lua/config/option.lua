-- vim 기본 옵션 설정 
vim.opt.encoding  	  =	'utf-8'
vim.opt.fileencoding	=	'utf-8'
vim.wo.number		      =	true
vim.opt.title		      =	true
vim.opt.hlsearch	    =	true
vim.opt.shell		      =	'fish'

vim.opt.expandtab     = true
vim.opt.smartindent   = true
vim.opt.shiftwidth    = 2
vim.opt.tabstop       = 2
vim.opt.softtabstop   = 2

vim.opt.wrap          = true
vim.opt.smarttab      = true
vim.opt.linebreak     = true
vim.opt.showbreak     = "↳ "
vim.opt.breakindent   = true

vim.opt.swapfile      = false
vim.opt.clipboard     = "unnamedplus"

-- 라인 넘버 색상 설정 (진한 흰색)
vim.api.nvim_set_hl(0, 'LineNr', { fg = '#ffffff', bold = true })
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#ffffff', bold = true })

