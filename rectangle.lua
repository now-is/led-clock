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

local function rectangles_of (str, fill_char)
	local rectangles = {}
	for c in str:gmatch('.') do
		local d = LED.digit(tonumber(c), fill_char)
		if d ~= nil then
			rectangles[#rectangles+1] = d
		end
	end
	return rectangles
end

C.initscr()
-- disable line buffering
C.cbreak()
C.echo(false)

local scr = C.stdscr()
scr:nodelay(true)

local quit_char = string.byte('q')

while true do
	scr:clear()
	local sec = tostring(os.time() % 60)
	if #sec < 2 then
		sec = '0' .. sec
	end
	paint_rectangles(scr, 5, 10, rectangles_of(sec, '@'), 6)
	scr:move(0, 0)
	scr:refresh()

	if scr:getch() == quit_char then
		break
	end
	sleep(1000)
end

-- free curses memory
C.endwin()
