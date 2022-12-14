# FCITX5.NVIM

## What Is It

A Neovim plugin writing in Lua to switch and restore fcitx state for each buffer. For example, switching to English input when leaving the INSERT mode, and restore Non-Latin input (like Japanese input) when enter the INSERT mode or COMMAND mode (for searching).

The input method specified when calling `setup` is set as default.

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
  use({ "pysan3/fcitx5.nvim", event = { "ModeChanged" } })
end)
```

## Alternative

- [fcitx.vim](https://github.com/lilydjwg/fcitx.vim)
- [fcitx.nvim](https://github.com/h-hg/fcitx.nvim)
- [vim-barbaric](https://github.com/rlue/vim-barbaric)

## Credits

- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
  - Provided me the code to check the current mode.

## License

All files in this repository without annotation are licensed under the MIT license as detailed in [LICENSE](./LICENSE).
