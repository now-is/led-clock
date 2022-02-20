local function isCallable (callback)
	local tc = type(callback)
	if tc == 'function' then return true end
	if tc == 'table' then
		local mt = getmetatable(callback)
		return type(mt) == 'table' and type(mt.__call) == 'function'
	end
	return false
end

local function isInteger (value)
	return type(value) == 'number' and math.floor(value) == value
end

local function isPositiveInteger (value)
	return isInteger(value) and value > 0
end

local Clock = {}
local Clock_mt = {__index = Clock}

local function newClock (limit, interval, callback, ...)
	assert(isPositiveInteger(interval), 'interval not a positive integer')
	assert(isInteger(limit), 'limit not an integer')
	assert(isCallable(callback), 'callback not a function')

	return setmetatable({
		interval  = interval,
		callback  = callback,
		limit     = limit,
		number    = 0,
		args      = {...},
		start     = nil,
		post_call = nil,
		post_args = {}
	}, Clock_mt)
end

function Clock:set (t)
	assert(isInteger(t), 'attempt to set clock to a non-integer')
	if self.start == nil then
		self.start = t
		return
	end

	assert(isPositiveInteger(t - self.start), 'attempt to set clock too far back')

	local expired, called = false, false
	while true do
		if self.limit > 0 and self.number >= self.limit then
			expired = true
			break
		end
		local tick = self.start + self.interval
		if tick > t then
			break
		end
		self.callback(tick, unpack(self.args))
		self.start = tick
		self.number = self.number + 1
		called = true
	end
	if self.post_call ~= nil and called then
		self.post_call(unpack(self.post_args))
	end
	return expired
end

function Clock:post (callback, ...)
	assert(isCallable(callback), 'post-set callback not a function')
	self.post_call = callback
	self.post_args = {...}
end

return {
	after = function (interval, callback, ...)
		return newClock(1, interval, callback, ...)
	end,

	-- see above: limit = 0 means unlimited
	every = function (interval, callback, ...)
		return newClock(0, interval, callback, ...)
	end
}
