#!/usr/bin/env lua

-- docs: https://lubyk.github.io/lubyk/xml.html
local X = require 'xml'

local fields = {
    'observation_time_rfc822',
    'weather',
    'temp_f',
    'temp_c',
    'wind_degrees',
    'wind_mph',
    'windchill_f',
    'windchill_c',
    'station_id',
}

local function is_field (v)
	local is = false
	for _, f in ipairs(fields) do
		if f == v.xml then
			is = true
			break
		end
	end
	return is
end

local dir_of_quad = {
	[0] = 'NE',
	[1] = 'SE',
	[2] = 'SW',
	[3] = 'NW',
}

local function dir_of_deg (deg)
	return dir_of_quad[math.floor(deg/90)]
end

local function extracted (nws_data)
	local t = {}
	for _, v in ipairs(nws_data) do
		if is_field(v) then
			t[v.xml] = v[1]
		end
	end
	return t
end

local function prettify_table (t)
	t.wind = string.format('%s %s', dir_of_deg(t.wind_degrees), t.wind_mph)
end

local url = 'https://w1.weather.gov/xml/current_obs/KORD.xml'
-- but for now:
local nws = X.load(io.read("*all"))

if nws.xml ~= 'current_observation' then
	os.exit(1)
end

local weather = extracted(nws)
prettify_table(weather)

for k, v in pairs(weather) do
	print(string.format('%s: %s', k, v))
end

