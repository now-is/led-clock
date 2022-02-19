local cron = require 'cron'

describe( 'cron', function()

  local counter
  local function increment (amount)
    amount = amount or 1
    counter = counter + amount
  end
  local countable = setmetatable({}, {__call = increment})

  before_each(function()
    counter = 0
  end)


  describe('clock', function()

    describe(':update', function()
      it('throws an error if dt is not positive', function()
        local clock = cron.every(1, increment)
        assert.error(function() clock:update() end)
        assert.error(function() clock:update(-1) end)
        assert.not_error(function() clock:update(1) end)
      end)
    end)

    describe(':set', function()
      it('throws an error if time not monotonic', function()
        local clock = cron.every(1, increment)
        assert.error(function() clock:set('foo') end)
        assert.not_error(function() clock:set(-1) end)
        assert.not_error(function() clock:set(2) end)
        assert.not_error(function() clock:set(3) end)
        assert.error(function() clock:set(1) end)
      end)
    end)
  end)


  describe('.after', function()
    it('checks parameters', function()
      assert.error(function() cron.after('error', increment) end)
      assert.error(function() cron.after(2, 'error') end)
      assert.error(function() cron.after(-2, increment) end)
      assert.error(function() cron.after(2, {}) end)
      assert.not_error(function() cron.after(2, increment) end)
      assert.not_error(function() cron.after(2, countable) end)
    end)

    it('produces a clock that executes actions only once, at the right time', function()
      local c1 = cron.after(2, increment)
      local c2 = cron.after(4, increment)

      -- 1
      c1:update(1)
      assert.equal(counter, 0)
      c2:update(1)
      assert.equal(counter, 0)

      -- 2
      c1:update(1)
      assert.equal(counter, 1)
      c2:update(1)
      assert.equal(counter, 1)

      -- 3
      c1:update(1)
      assert.equal(counter, 1)
      c2:update(1)
      assert.equal(counter, 1)

      -- 5
      c1:update(1)
      assert.equal(counter, 1)
      c2:update(1)
      assert.equal(counter, 2)

    end)

    it('produces a clock that can be expired', function()
      local c1 = cron.after(2, increment)
      assert.is_false(c1:update(1))
      assert.is_true(c1:update(1))
      assert.is_true(c1:update(1))
    end)

    it('Passes on parameters to the callback', function()
      local c1 = cron.after(1, increment, 2)
      c1:update(1)
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

    it('Invokes callback periodically', function()
      local c = cron.every(3, increment)

      c:update(1)
      assert.equal(counter, 0)

      c:update(2)
      assert.equal(counter, 1)

      c:update(2)
      assert.equal(counter, 1)

      c:update(1)
      assert.equal(counter, 2)
    end)

    it('Executes the same action multiple times on a single update if appropiate', function()
      local c = cron.every(1, increment)
      c:update(2)
      assert.equal(counter, 2)
    end)

    it('Respects parameters', function()
      local c = cron.every(1, increment, 2)
      c:update(2)
      assert.equal(counter, 4)
    end)
  end)

end)
