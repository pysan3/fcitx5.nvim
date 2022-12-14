# FCITX5.NVIM

## What Is It

A Neovim plugin writing in Lua to switch and restore fcitx state for each buffer. For example, switching to English input when leaving the INSERT mode, and restore Non-Latin input (like Japanese input) when enter the INSERT mode or COMMAND mode (for searching).

The input method specified when calling `setup` is set as default.

## Requirements

**`fcitx5` is highly recommended but `fcitx` should work as well.**

- This plugin requires neovim >= 0.5.0
- `fcitx5-remote` or `fcitx-remote`

## Installation

For [packer](https://github.com/wbthomason/packer.nvim) user:

```lua
require("packer").startup(function(use)
  use({ "pysan3/fcitx5.nvim" })

  -- If you want to lazy load...
  use({ "pysan3/fcitx5.nvim", event = { "InsertEnter", "CmdlineEnter" } })
end)
```

## Alternative

- [fcitx.vim](https://github.com/lilydjwg/fcitx.vim)
- [fcitx.nvim](https://github.com/h-hg/fcitx.nvim)
- [vim-barbaric](https://github.com/rlue/vim-barbaric)
