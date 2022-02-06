#!/usr/bin/env lua

local utf8 = require 'lua-utf8'

local box_char_chars =
	'┏┳┓'..
	'┣╋┫'..
	'┗┻┛'..
	'┃━'

local box_char_names = {
	'tl', 'tc', 'tr',
	'ml', 'mc', 'mr',
	'bl', 'bc', 'br',
	'vx', 'hx'
}

local box_char = {}

for i = 1, utf8.len(box_char_chars) do
	local name = box_char_names[i]
	local l, c = name:sub(1,1), name:sub(2,2)
	if box_char[l] == nil then
		box_char[l] = {}
	end
	box_char[l][c] = utf8.sub(box_char_chars, i, i)
end

local function line (level, width)
	if width < 2 then
		return ''
	end
	local chars = box_char[level]
	return chars.l .. string.rep(box_char.h.x, width - 2) .. chars.r
end

local function rectangle (width, height)
	if height < 2 then
		return ''
	end
	if width < 2 then
		return string.rep('\n', height)
	end
	local mid = box_char.v.x .. string.rep(' ', width - 2) .. box_char.v.x
	local rectangle = { line('t', width) }
	for i = 2, height - 1 do
		rectangle[i] = mid
	end
	rectangle[height] = line('b', width)
	return rectangle
end

local figure = rectangle(0+arg[1], 0+arg[2])
for _,f in ipairs(figure) do
	print(f)
end
