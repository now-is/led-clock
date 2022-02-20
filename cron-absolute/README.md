cron-absolute.lua
========

`cron-absolute.lua` manages clocks that execute actions at specified times.

Unlike `cron.lua`, it bows to the tyranny of absolute time. You can only set a
time on a clock, you cannot increment it by an interval.

API
===

`local clock = cron.after(interval, callback, ...)`.
Creates a clock that will execute `callback` after `interval` passes. If additional params were provided, they are passed to `callback`.

`local clock = cron.every(interval, callback, ...)`.
Creates a clock that will execute `callback` every `interval`, periodically. Additional parameters are passed to the `callback` too.


Clock methods:

`local expired = clock:set(t)`.
Sets the time in the clock to `t`.

The first `set` on a clock sets its start time. It does not invoke a callback and returns false, i.e. not expired.

On subsequent `set`s:

* A one-time clock invokes its `callback` if the time has increased by more than its `interval` from its start time.
* A periodic clock invokes its `callback` 0 or more times, depending on how much its time has increased.
* `expired` is true for one-time clocks whose `callback` has been invoked.


Examples
========

```lua
local cron = require 'cron'

local function printMessage()
  print('Hello')
end

-- the following calls are equivalent:
local c1 = cron.after(5, printMessage)

c1:set(0) -- initializes internal time
c1:set(2) -- prints nothing, the action is not done yet
c1:set(7) -- prints 'Hello' once

-- Create a periodical clock:
local c2 = cron.every(10, printMessage)

c1:set(0) -- initializes internal time
c2:set(5) -- nothing
c2:set(9) -- nothing
c2:set(21) -- prints 'Hello' twice
```

Gotchas / Warnings
==================

* `cron-absolute.lua` does *not* implement any hardware or software clock; you will have to provide it with the access to the hardware timers, in the form of periodic calls to `cron.set`
* `cron` does not have any defined time units (seconds, milliseconds, etc). You define the units it uses by passing it a `dt` on `cron.update`. If `dt` is in seconds, then `cron` will work in seconds. If `dt` is in milliseconds, then `cron` will work in milliseconds.

Installation
============


Copy the cron.lua file somewhere in your projects (maybe inside a /lib/ folder) and require it accordingly.

```lua
local cron = require 'cron'
```

Specs
=====

This project uses [busted](https://olivinelabs.com/busted) for its specs. If you want to run the specs, you will have to install it first. Then run:

```bash
cd path/where/the/spec/folder/is
busted
```
