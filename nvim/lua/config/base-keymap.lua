local function map(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
end

map("<leader>wh", "<C-w>h", "왼쪽 창으로 이동")
map("<leader>wj", "<C-w>j", "아래 창으로 이동")
map("<leader>wk", "<C-w>k", "위 창으로 이동")
map("<leader>wl", "<C-w>l", "오른쪽 창으로 이동")
map("<leader>ws", "<cmd>split<CR>", "가로 창 분할")
map("<leader>wv", "<cmd>vsplit<CR>", "세로 창 분할")
map("te", "<cmd>tabedit<CR>", "새 탭 열기")
map("<Space>", "<Nop>", "Leader 키")
map("<leader>h", "<cmd>tabprevious<CR>", "이전 탭")
map("<leader>l", "<cmd>tabnext<CR>", "다음 탭")
