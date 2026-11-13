-- 표의 줄바꿈 계산에서 둥근 끝과 인접 글자를 한 단위로 취급한다.
local function atoms(units)
	local result, rounded = {}, false
	for _, unit in ipairs(units) do
		local previous = result[#result]
		if previous and (previous.open or unit.text == "") then
			previous.text = previous.text .. unit.text
			previous.width = previous.width + unit.width
			previous.parts[#previous.parts + 1] = unit
			previous.open = false
		else
			result[#result + 1] = {
				text = unit.text,
				width = unit.width,
				highlight = #result + 1,
				parts = { unit },
				open = unit.text == "",
			}
		end
		rounded = rounded or unit.text == "" or unit.text == ""
	end
	return result, rounded
end

return {
	parse = function(ctx)
		local parser = require("render-markdown.parser.table")
		local measure, wrap = parser.measure, parser.wrap
		parser.measure = function(units)
			local grouped, rounded = atoms(units)
			return measure(rounded and grouped or units)
		end
		parser.wrap = function(units, width)
			local grouped, rounded = atoms(units)
			if not rounded then
				return wrap(units, width)
			end
			local lines = wrap(grouped, width)
			-- 그룹 번호는 계산에만 쓰고, 출력에서는 각 글자의 원래 색상을 복원한다.
			for i, line in ipairs(lines) do
				local expanded = {}
				for _, chunk in ipairs(line) do
					for _, part in ipairs(grouped[chunk[2]].parts) do
						local previous = expanded[#expanded]
						if previous and vim.deep_equal(previous[2], part.highlight) then
							previous[1] = previous[1] .. part.text
						else
							expanded[#expanded + 1] = { part.text, part.highlight }
						end
					end
				end
				lines[i] = expanded
			end
			return lines
		end
		-- 빌트인 파싱은 동기 실행된다. 실패하더라도 계산 함수를 즉시 복원한다.
		local ok, marks = pcall(require("render-markdown.handler.markdown").parse, ctx)
		parser.measure, parser.wrap = measure, wrap
		if not ok then
			error(marks)
		end
		return marks
	end,
}
