local M = {}

M.defaults = {
  dir = vim.fn.expand("~/.cache/tidal-autocomplete"),
  include_synths = true,
  include_samples = true,
}

M.config = M.defaults

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

function M.create_source()
  local source = require("blink-superdirt.source")
  return source.new(M.config)
end

return M