local led_segments = [[
 c11111111111111111111111111111d
22c111111111111111111111111111d33
222c1111111111111111111111111d333
22222                       33333
22222                       33333
22222                       33333
22222                       33333
22222                       33333
22222                       33333
22222                       33333
22222                       33333
22222                       33333
22222                       33333
22222                       33333
22222                       33333
222f4444444444444444444444444g333
 zz444444444444444444444444444yy 
555i4444444444444444444444444j666
55555                       66666
55555                       66666
55555                       66666
55555                       66666
55555                       66666
55555                       66666
55555                       66666
55555                       66666
55555                       66666
55555                       66666
55555                       66666
55555                       66666
555l7777777777777777777777777m666
55l777777777777777777777777777m66
 l77777777777777777777777777777m
]]

local led_spec = {
	[0] = {'123567'},
	[1] = {'36', 'cfilz'},
	[2] = {'13457'},
	[3] = {'13467'},
	[4] = {'2346', 'l'},
	[5] = {'12467'},
	[6] = {'124567'},
	[7] = {'136', 'filz'},
	[8] = {'1234567'},
	[9] = {'123467'},
}

local cements = 'cdfgijlmyz'

function digit (j, char)
	if unpack == nil then
		unpack = table.unpack
	end
	local segments, cement = unpack(led_spec[j])
	if segments == nil then
		return
	end
	segments = led_segments:gsub('[^' .. segments .. cements .. '\n]', ' ')
	if cement ~= nil then
		segments = segments:gsub('[' .. cement .. ']', ' ')
	end
	segments = segments:gsub('%S', char)
	return segments
end

return {
	digit = digit,
}
