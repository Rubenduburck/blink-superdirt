# blink-superdirt

A [blink.cmp](https://github.com/Saghen/blink.cmp) source for SuperDirt/TidalCycles autocompletion in Neovim.

## Features

- Autocomplete SuperDirt samples and synths in `.tidal` files
- Context-aware completion (only suggests in sound contexts like `s "..."`)
- Integrates seamlessly with blink.cmp

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "your-username/blink-superdirt",
  dependencies = { "saghen/blink.cmp" },
  config = function()
    require("blink-superdirt").setup({
      -- Optional configuration
      dir = vim.fn.expand("~/.cache/tidal-autocomplete"), -- default
      include_synths = true,  -- default
      include_samples = true, -- default
    })
  end
}
```

Then add the source to your blink.cmp configuration:

```lua
require("blink.cmp").setup({
  sources = {
    providers = {
      -- ... other providers
      superdirt = {
        name = "SuperDirt",
        module = "blink-superdirt.source",
        opts = {}, -- optional, will use defaults from setup()
      },
    },
  },
})
```

Or if you want to create the source directly:

```lua
require("blink.cmp").setup({
  sources = {
    providers = {
      -- ... other providers
      superdirt = require("blink-superdirt").create_source(),
    },
  },
})
```

## Prerequisites

The plugin expects to find SuperDirt sample and synth lists at:
- `~/.cache/tidal-autocomplete/samples.txt`
- `~/.cache/tidal-autocomplete/synths.txt`

These files should contain one sample/synth name per line.

## Configuration

```lua
require("blink-superdirt").setup({
  -- Directory containing samples.txt and synths.txt
  dir = vim.fn.expand("~/.cache/tidal-autocomplete"),
  
  -- Whether to include synths in completions
  include_synths = true,
  
  -- Whether to include samples in completions  
  include_samples = true,
})
```

## License

MIT