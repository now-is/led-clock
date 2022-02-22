local cron = require 'cron'

describe('cron', function ()

	local counter, called_at, progress_bar
	local function increment (time, amount)
		amount = amount or 1
		counter = counter + amount
		called_at = time
	end
	local function progress (chars)
		progress_bar = progress_bar .. chars
	end
	local countable = setmetatable({}, {__call = increment})

	before_each(function ()
		counter = 0
		progress_bar = ''
	end)

	describe(':set', function ()
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
			assert.error(function () cron.after('error', increment) end)
			assert.error(function () cron.after(2, 'error') end)
			assert.error(function () cron.after(-2, increment) end)
			assert.error(function () cron.after(2, {}) end)
			assert.not_error(function () cron.after(2, increment) end)
			assert.not_error(function () cron.after(2, countable) end)
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
			assert.is_false(c1:set(0))
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

	describe('.every', function ()
		it('checks parameters', function ()
			assert.error(function () cron.every('error', increment) end)
			assert.error(function () cron.every(2, 'error') end)
			assert.error(function () cron.every(-2, increment) end)
			assert.error(function () cron.every(-2, {}) end)
			assert.not_error(function () cron.every(2, increment) end)
			assert.not_error(function () cron.every(2, countable) end)
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

	describe(':post', function ()
		it('checks parameters', function ()
			local c = cron.every(3, increment)

			assert.error(function () c:post('error') end)
			assert.error(function () c:post(2) end)
			assert.error(function () c:post({}) end)
			assert.not_error(function () c:post(increment, 2) end)
			assert.not_error(function () c:post(countable) end)
		end)

		it('calls post-set hook once per effective set', function ()
			local c = cron.every(2, increment)
			c:set(0)

			c:post(progress, 'X')

			c:set(4)
			assert.equal(counter, 2)
			assert.equal(progress_bar, 'X')

			c:set(5)
			assert.equal(counter, 2)
			assert.equal(progress_bar, 'X')

			c:set(7)
			assert.equal(counter, 3)
			assert.equal(progress_bar, 'XX')
		end)
	end)

	describe('.group', function ()
		it('chains :add, :after and :every', function ()
			local g = cron.group()
			assert.not_error(function ()
				g:add(ce)
					:after(3, increment)
					:every(5, increment, 4)
					:add(cron.after(3, increment, 10))
			end)
		end)

		it('sets times on all its clocks', function ()
			local counters = {0, 0, 0}
			local function incr_at (tick, i, delta)
				counters[i] = counters[i] + delta
			end

			local g = cron.group()
				:every(1, incr_at, 1, 1) -- "elapsed"
				:after(3, incr_at, 2, 1) -- "flag"
				:every(5, incr_at, 3, 8) -- "mi to km"

			assert.not_error(function () g:set(0) end)

			g:set(1)  assert.are.same(counters, { 1, 0,  0})
			g:set(2)  assert.are.same(counters, { 2, 0,  0})
			g:set(3)  assert.are.same(counters, { 3, 1,  0})
			g:set(4)  assert.are.same(counters, { 4, 1,  0})
			g:set(5)  assert.are.same(counters, { 5, 1,  8})
			g:set(6)  assert.are.same(counters, { 6, 1,  8})
			g:set(10) assert.are.same(counters, {10, 1, 16})
			g:set(12) assert.are.same(counters, {12, 1, 16})
			g:set(15) assert.are.same(counters, {15, 1, 24})
		end)

		it('reports expiration of all clocks', function ()
			local g = cron.group()
				:after(1, increment)
				:after(3, countable)
				:after(5, increment)

			g:set(0)

			assert.is_false(g:set(1))
			assert.is_false(g:set(2))
			assert.is_false(g:set(3))
			assert.is_false(g:set(4))

			assert.is_true(g:set(5))
			assert.is_true(g:set(6))
			assert.is_true(g:set(7))

			-- never expires
			g:every(1, increment, 3)
			assert.is_false(g:set(8))
			assert.is_false(g:set(100))

		end)
	end)
end)
