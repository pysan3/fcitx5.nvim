# FCITX5.NVIM

## What Is It

A Neovim plugin writing in Lua to switch and restore fcitx state for each buffer. For example, switching to English input when leaving the INSERT mode, and restore Non-Latin input (like Japanese input) when enter the INSERT mode or COMMAND mode (for searching).

The input method specified when calling `setup` is set as default.

You can find the current `<imname>` with the following command, which is required to setup this plugin.

```sh
$ fcitx5-remote -n
```

## Requirements

**This plugin does NOT work with `fcitx`. Only works with `fcitx5`.**

- This plugin requires `nvim v0.8+`
- `fcitx5-remote`

## Installation

For [packer](https://github.com/wbthomason/packer.nvim) user:

```lua
require("packer").startup(function(use)
  use({ "pysan3/fcitx5.nvim" })

  -- If you want to lazy load...
  use({
    "pysan3/fcitx5.nvim",
    cond = vim.fn.executable("fcitx5-remote") == 1,
    event = { "ModeChanged" },
  })
end)
```

## Setup

This plugin will only be loaded after `setup` is called. The `setup` function should be called with a lua table with the following keys.

The following values are the default which will be chosen if the keys do not exist.

See [## Recommended Setup](#recommended-setup) and [`./lua/fcitx5/config.lua`](./lua/fcitx5/config.lua) for more details.

```lua
require("fcitx5").setup({
  msg = nil, -- string | nil: printed when startup is completed
  imname = { -- fcitx5.Imname | nil: imnames on each mode set as prior. See `:h map-table` for more in-depth information.
    norm = nil, -- string | nil: imname to set in normal mode. if nil, will restore the mode on exit.
    ins = nil,
    cmd = nil,
    vis = nil,
    sel = nil,
    opr = nil,
    term = nil,
    lang = nil,
  },
  remember_prior = true, -- boolean: if true, it remembers the mode on exit and restore it when entering the mode again.
  --                                 if false, uses what was set in config.
  define_autocmd = true, -- boolean: if true, defines autocmd at `ModeChanged` to switch fcitx5 mode.
  log = "warn", -- string: log level (default: warn)
})
```

## Recommended Setup

- Japanese (**`mozc`**)
  - If you are using [`mozc`](https://github.com/google/mozc) with `fcitx5`, you can use the following setup.
  - This will default to using `mozc` when inside `ins` (Insert Mode).
  - `remember_prior = true` makes it remembers the mode on exit and restores it when entering the mode again.

```lua
local en = "keyboard-us"
local ja = "mozc"

require("fcitx5").setup({
  imname = {
    norm = en,
    ins = ja,
    cmd = en,
  },
  remember_prior = true,
})

-- If you are using `jk` to escape, map 全角のｊｋ.
vim.cmd([[
inoremap <silent> ｊｋ <Esc>
tnoremap <silent> ｊｋ <Esc>
]])
```

## Commands

I strongly recommend to set `define_autocmd = true` and let the plugin manage the modes, but there are commands to manually control the behavior as well.

- `:Fcitx5`
  - Show Help
- `:Fcitx5SetName <imname>`
  - Force load the input method. Expect one arg of `imname`.
- `:Fcitx5Geneious`
  - Does what should be intuitive.
- `:Fcitx5OnModeChanged`
  - Function to call as an autocmd.
- `:Fcitx5SetPrior <imname> <mode>`
  - Manually set prior imname. Expect args of `imname` and `mode`. If `mode` is not specified, uses the current mode.
- `:Fcitx5GetImname <mode>`
  - Get the `imname` for the given mode. Expect one arg of `mode` or if none, uses current mode.
- `:Fcitx5GetImnames`
  - Return a list of `imname` for all modes.

## Alternative

- [fcitx.vim](https://github.com/lilydjwg/fcitx.vim)
- [fcitx.nvim](https://github.com/h-hg/fcitx.nvim)
- [vim-barbaric](https://github.com/rlue/vim-barbaric)

## Credits

- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
  - Provided me the code to check the current mode.

## License

All files in this repository without annotation are licensed under the MIT license as detailed in [LICENSE](./LICENSE).
