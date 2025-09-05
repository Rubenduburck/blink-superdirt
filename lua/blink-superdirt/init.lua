-- blink-superdirt main module
-- Exports the 'new' function required by blink.cmp

local source = require("blink-superdirt.source")

-- Export the new function directly for blink.cmp
return {
  new = source.new
}