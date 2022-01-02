#!/usr/bin/env lua

-- luarocks deps: lcurses, sleep
local C = require 'curses'
local LED = require 'led'
local sleep = require 'sleep'

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

C.initscr()
-- disable line buffering
C.cbreak()
C.echo(false)

local scr = C.stdscr()
scr:nodelay(true)

while true do
  scr:clear()
  paint_rectangle(scr, 1, 10, LED.digit(os.time() % 10, '@'))
  scr:move(0, 0)
  scr:refresh()

  if scr:getch() == 113 then -- 'q'
	  break
  end
  sleep(1000)
end

-- free curses memory
C.endwin()
