local lib = require("fcitx5.lib")
local config = require("fcitx5.config")
local commands = require("fcitx5.commands")

local M = vim.tbl_deep_extend("force", {}, lib, config, commands)

local function setup_vim_commands()
  M.info("Setting up vim commands.")
  vim.api.nvim_create_user_command("Fcitx5", function(_)
    require("fcitx5").help()
  end, { desc = "[pysan3/fcitx5.nvim] Fcitx5 help" })
  vim.api.nvim_create_user_command("Fcitx5SetName", function(opts)
    if #opts.fargs < 1 then
      require("fcitx5").error("<Cmd>Fcitx5SetName requires one argument `imname`.")
      require("fcitx5").help()
      return
    end
    local imname = opts.fargs[1]
    require("fcitx5").Fcitx5SetName(imname)
  end, { desc = "[pysan3/fcitx5.nvim] Fcitx5SetName <imname>", nargs = 1 })
  vim.api.nvim_create_user_command("Fcitx5Geneious", function(_)
    require("fcitx5").Fcitx5Geneious()
  end, { desc = "[pysan3/fcitx5.nvim] Fcitx5Geneious" })
  vim.api.nvim_create_user_command("Fcitx5OnModeChanged", function(_)
    require("fcitx5").Fcitx5OnModeChanged()
  end, { desc = "[pysan3/fcitx5.nvim] Fcitx5OnModeChanged" })
  vim.api.nvim_create_user_command("Fcitx5SetPrior", function(opts)
    local mode, imname
    if #opts.fargs == 1 then
      mode, imname = nil, opts.fargs[1]
    elseif #opts.fargs == 2 then
      mode, imname = opts.fargs[2], opts.fargs[1]
    else
      require("fcitx5").error("<Cmd>Fcitx5SetPrior requires one or two arguments `imname` `mode?`.")
      require("fcitx5").help()
      return
    end
    require("fcitx5").Fcitx5SetPrior(mode, imname)
  end, { desc = "[pysan3/fcitx5.nvim] Fcitx5SetPrior", nargs = "*" })
  vim.api.nvim_create_user_command("Fcitx5GetImname", function(opts)
    local mode = #opts.fargs >= 1 and opts.fargs[1] or nil
    local result = require("fcitx5").Fcitx5GetImname(mode)
    print(result)
    return result
  end, { desc = "[pysan3/fcitx5.nvim] Fcitx5GetImname <mode>", nargs = "?" })
  vim.api.nvim_create_user_command("Fcitx5GetImnames", function(_)
    local result = require("fcitx5").Fcitx5GetImnames()
    vim.pretty_print(result)
    return result
  end, { desc = "[pysan3/fcitx5.nvim] Fcitx5GetImnames" })
end

local function setup_vim_autocmds()
  M.info("Setting vim autocommands.")
  local augroup = vim.api.nvim_create_augroup("Fcitx5Group", { clear = true })
  vim.api.nvim_create_autocmd({ "ModeChanged" }, {
    group = augroup,
    pattern = "*:*",
    callback = function(_)
      require("fcitx5").Fcitx5OnModeChanged()
    end
  })
end

local function check_valid_os()
  if vim.fn.executable('fcitx5-remote') == 1 then
    lib.info("fcitx5-remote found.")
    return true
  else
    lib.warn("`fcitx5-remote` not found. Abort.")
    return false
  end
  if os.getenv('SSH_TTY') ~= nil then
    lib.error("You are in a ssh session. This plugin does not work over ssh. Abort.")
    return false
  end
  local os_name = vim.loop.os_uname().sysname
  if (os_name == 'Linux' or os_name == 'Unix') and os.getenv('DISPLAY') == nil and os.getenv('WAYLAND_DISPLAY') == nil then
    lib.error("Cannot detect your display. Abort.")
    return false
  end
  return false
end

---setup function, call on setup
---@param opts fcitx5.Config look https://github.com/pysan3/fcitx5.nvim for config detail
M.setup = function(opts)
  config.set_options(opts)

  if not check_valid_os() then
    lib.info("check_valid_os failed. Returning without doing anything.")
    return
  end
  setup_vim_commands()
  if config.define_autocmd then
    setup_vim_autocmds()
  end
  if vim.v.event.new_mode ~= nil then
    commands.Fcitx5OnModeChanged()
  else
    commands.Fcitx5Geneious()
  end

  if config.msg ~= nil then
    lib.echo(config.msg)
  end
end

return M
