local uv = vim.uv or vim.loop
local K  = require("blink.cmp.types").CompletionItemKind

local defaults = {
  dir = vim.fn.expand("~/.cache/tidal-autocomplete"),
  include_synths = true,
  include_samples = true,
}

local function read_lines(path)
  local fd = uv.fs_open(path, "r", 438)
  if not fd then return {} end
  local stat = uv.fs_fstat(fd); if not stat then uv.fs_close(fd); return {} end
  local data = uv.fs_read(fd, stat.size, 0) or ""
  uv.fs_close(fd)
  local out = {}
  for line in data:gmatch("[^\r\n]+") do
    if line ~= "" then out[#out+1] = line end
  end
  return out
end

local function in_sound_context(before)
  local q = before:reverse():find('"', 1, true)
  if not q then return false end
  local prefix = before:sub(1, #before - q)
  return prefix:match('%f[%w]s%s*$') or prefix:match('%f[%w]sound%s*$') or prefix:match('#%s*sound%s*$')
end

local function token_range(line, col0)
  local s, e = line:sub(1, col0):find('[%w_:%-]+$')
  if not s then s = col0 + 1; e = col0 end
  return s - 1, e
end

local Source = {}
Source.__index = Source

function Source.new(opts)
  local self = setmetatable({}, Source)
  self.opts = vim.tbl_deep_extend("force", defaults, opts or {})
  self.cache = nil
  return self
end

function Source:enabled()
  return vim.fn.expand("%:e") == "tidal"
end

function Source:get_trigger_characters()
  return { '"', ':', ' ', '/', '|', '<', '[' }
end

function Source:_load()
  if self.cache then return end
  local dir = self.opts.dir
  local items = {}

  if self.opts.include_samples then
    for _, name in ipairs(read_lines(dir .. "/samples.txt")) do
      items[#items+1] = {
        label = name,
        insertText = name,
        kind = K.Folder,                -- sample
        labelDescription = "sample",
      }
    end
  end

  if self.opts.include_synths then
    for _, name in ipairs(read_lines(dir .. "/synths.txt")) do
      items[#items+1] = {
        label = name,
        insertText = name,
        kind = K.Function,              -- synth
        labelDescription = "synth",
      }
    end
  end

  table.sort(items, function(a, b)
    if a.labelDescription ~= b.labelDescription then
      return a.labelDescription < b.labelDescription
    end
    return a.label < b.label
  end)

  self.cache = items
end

function Source:get_completions(ctx, cb)
  if not self:enabled() then return cb({ items = {} }) end
  self:_load()

  local row1, col0 = unpack(vim.api.nvim_win_get_cursor(0))
  local row0 = row1 - 1
  local line = vim.api.nvim_buf_get_lines(ctx.bufnr, row0, row0 + 1, true)[1] or ""
  if not in_sound_context(line:sub(1, col0)) then return cb({ items = {} }) end

  local s0, e0 = token_range(line, col0)
  local out = {}
  for _, it in ipairs(self.cache) do
    local item = vim.deepcopy(it)
    item.textEdit = {
      newText = item.insertText,
      range = { start = { line = row0, character = s0 }, ["end"] = { line = row0, character = e0 } },
    }
    out[#out+1] = item
  end
  cb({ items = out })
end

function Source:resolve(item, cb) cb(item) end

return { new = function(opts) return Source.new(opts) end }


