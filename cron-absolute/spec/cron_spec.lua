local cron = require 'cron'

describe('cron', function ()

	local counter, called_at
	local function increment (time, amount)
		amount = amount or 1
		counter = counter + amount
		called_at = time
	end
	local countable = setmetatable({}, {__call = increment})

	before_each(function ()
		counter = 0
	end)

	describe(':set', function()
		it('fails on non-integers', function ()
			local clock = cron.every(1, increment)
			assert.error(function () clock:set() end)
			assert.error(function () clock:set('one') end)
			assert.not_error(function () clock:set(-1) end)
			assert.not_error(function () clock:set(0) end)
			assert.not_error(function () clock:set(2) end)
		end)

		it('fails if clock is set too far back', function ()
			local clock = cron.every(3, increment)
			clock:set(0)
			assert.not_error(function () clock:set(2) end)
			assert.not_error(function () clock:set(5) end)
			assert.error(function () clock:set(1) end)
		end)
	end)

	describe('.after', function ()
		it('checks parameters', function ()
			assert.error(function() cron.after('error', increment) end)
			assert.error(function() cron.after(2, 'error') end)
			assert.error(function() cron.after(-2, increment) end)
			assert.error(function() cron.after(2, {}) end)
			assert.not_error(function() cron.after(2, increment) end)
			assert.not_error(function() cron.after(2, countable) end)
		end)

		it('executes exactly once and at the right time', function ()
			local c1 = cron.after(2, increment)
			local c2 = cron.after(4, increment)

			c1:set(0)
			assert.equal(counter, 0)
			c2:set(0)
			assert.equal(counter, 0)

			c1:set(2)
			assert.equal(counter, 1)
			assert.equal(called_at, 2)
			c2:set(2)
			assert.equal(counter, 1)
			assert.equal(called_at, 2)

			c1:set(3)
			assert.equal(counter, 1)
			assert.equal(called_at, 2)
			c2:set(3)
			assert.equal(counter, 1)
			assert.equal(called_at, 2)

			c1:set(5)
			assert.equal(counter, 1)
			assert.equal(called_at, 2)
			c2:set(5)
			assert.equal(counter, 2)
			assert.equal(called_at, 4)

			c2:set(10)
			assert.equal(counter, 2)
			assert.equal(called_at, 4)
		end)

		it('reports its expiration', function ()
			local c1 = cron.after(2, increment)
			c1:set(0)
			assert.is_false(c1:set(1))
			assert.is_true(c1:set(2))
			assert.is_true(c1:set(3))
		end)

		it('passes arguments to the callback', function ()
			local c1 = cron.after(1, increment, 2)
			c1:set(0)
			c1:set(1)
			assert.equal(counter, 2)
		end)
	end)

	describe('.every', function()
		it('checks parameters', function()
			assert.error(function() cron.every('error', increment) end)
			assert.error(function() cron.every(2, 'error') end)
			assert.error(function() cron.every(-2, increment) end)
			assert.error(function() cron.every(-2, {}) end)
			assert.not_error(function() cron.every(2, increment) end)
			assert.not_error(function() cron.every(2, countable) end)
		end)

		it('executes periodically', function ()
			local c = cron.every(3, increment)
			c:set(0)

			c:set(1)
			assert.equal(counter, 0)

			c:set(3)
			assert.equal(counter, 1)
			assert.equal(called_at, 3)

			c:set(5)
			assert.equal(counter, 1)
			assert.equal(called_at, 3)

			c:set(6)
			assert.equal(counter, 2)
			assert.equal(called_at, 6)
		end)

		it('executes multiple times on a single set if appropriate', function ()
			local c = cron.every(1, increment)
			c:set(0)

			c:set(2)
			assert.equal(counter, 2)
		end)

		it('passes arguments to the callback', function ()
			local c = cron.every(1, increment, 2)
			c:set(0)

			c:set(2)
			assert.equal(counter, 4)
		end)
	end)

end)
