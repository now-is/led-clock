#!/usr/bin/env lua

local C = require 'curses'; 

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

local function hello ()

  C.initscr()
  -- disable line buffering
  C.raw()
  C.echo(false)

  local scr = C.stdscr()
  scr:clear()
  paint_rectangle(scr, 1, 10, 'Hell\nOr\nHigh\nWater')
  scr:move(0, 0)
  scr:refresh()

  local ch = scr:getch()

  -- free curses memory
  C.endwin()

  return(ch)
end

print(hello())
