local function split_on_char (c, text)
	local l = {}
	if #text == 0 then
		return l
	end

	-- pos: beginning of a segment
	local pos = 1
	while pos <= #text do
		s = text:find(c, pos)
		if s == nil then
			s = #text + 1
		end
		l[#l+1] = text:sub(pos, s-1)
		pos = s + 1
	end
	if s == #text then
		l[#l+1] = ''
	end

	return l
end

local function paint_rectangle (scr, l, c, rect)
	for i, line in ipairs(split_on_char('\n', rect)) do
		scr:mvaddstr(l+i-1, c, line)
	end
end

local function rectangle_width (rect)
	local width = 0
	for _, line in ipairs(split_on_char('\n', rect)) do
		if width < #line then
			width = #line
		end
	end
	return width
end

local function paint_rectangles (scr, l, c, rects, space)
	local width
	for _, rect in ipairs(rects) do
		paint_rectangle(scr, l, c, rect)
		c = c + rectangle_width(rect) + space
	end
end

return {
	rectangles = paint_rectangles,
}
