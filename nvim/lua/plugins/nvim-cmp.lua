--[[
-- @desectiption: 다양한 소스를 전달받아 완성 후보 항목을 수집하고 이를 사용자에게 통합된 인터페이스로 보여주어 쉽게 선택하고 삽입할수 있도록 하는 장치.
--]]
return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lsp",
	},
	-- event = 'InsertEnter',
	config = function()
		local cmp = require("cmp")
		cmp.setup({
			sources = cmp.config.sources({
				{ name = "nvim_lsp" }, -- **가장 중요!** LSP 서버의 제안 사용
				{ name = "buffer" }, -- 현재 파일에서 이미 입력된 단어 사용
				{ name = "path" }, -- 파일 경로 자동 완성
				{ name = "luasnip" }, -- 스니펫 플러그인을 사용한다면 추가 (선택 사항)
			}),
			mapping = cmp.mapping.preset.insert({
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(), -- 강제 자동 완성
				["<C-e>"] = cmp.mapping.abort(), -- 자동 완성 메뉴 닫기

				-- <CR> (Enter) 키 설정: 선택된 항목 확정
				["<CR>"] = cmp.mapping.confirm({ select = true }),

				-- <Tab> 키 설정: 항목 탐색 및 스니펫 이동
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item() -- 메뉴가 보이면 다음 항목 선택
					--[[
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump() -- 현재 위치에서 스니펫 확장 또는 다음 필드로 이동
            ]]
					--
					else
						fallback() -- 기본 Tab 동작 (들여쓰기)
					end
				end, { "i", "s" }), -- 'i' (Insert Mode), 's' (Snippet Mode)

				-- <S-Tab> (Shift + Tab) 키 설정: 이전 항목/스니펫 이동
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					--[[
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1) -- 이전 스니펫 필드로 이동
            ]]
					--
					else
						fallback()
					end
				end, { "i", "s" }),
			}),
		})
	end,
}
