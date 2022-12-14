local lib = require("fcitx5.lib")
local config = require("fcitx5.config")
local mode_util = require("fcitx5.mode_util")

---@class fcitx5.Imname
-- See `:h map-table` for more in-depth information.
---@field norm string | nil: imname for Norm mode.
---@field ins string | nil: imname for Ins mode.
---@field cmd string | nil: imname for Cmd mode.
---@field vis string | nil: imname for Vis mode.
---@field sel string | nil: imname for Sel mode.
---@field opr string | nil: imname for Opr mode.
---@field term string | nil: imname for Term mode.
---@field lang string | nil: imname for Lang mode.

local M = {
  fcitx5_command = nil,
  ---@type fcitx5.Imname
  prior = {}
}

---Return `fcitx5-remote` command if possible
---@return string: "fcitx5-remote " (<space> at the end)
local function fcitx5_command()
  if M.fcitx5_command == nil then
    if vim.fn.executable('fcitx5-remote') == 1 then
      M.fcitx5_command = "fcitx5-remote"
    else
      lib.error("fcitx5-remote not found.")
      return "echo "
    end
  end
  return M.fcitx5_command .. " "
end

---return the field name of fcitx5.Imname based on `mode_char`
---@param mode_char? string: literal char result from `vim.api.nvim_get_mode()`. If none, current mode is used.
-- More details: https://neovim.io/doc/user/builtin.html#mode()
---@return string: field name of fcitx5.Imname
local function get_mode_key(mode_char)
  local mode_map = {
    ["NORMAL"] = "norm",
    ["O-PENDING"] = "opr",
    ["VISUAL"] = "vis",
    ["V-LINE"] = "vis",
    ["V-BLOCK"] = "vis",
    ["SELECT"] = "sel",
    ["S-LINE"] = "sel",
    ["S-BLOCK"] = "sel",
    ["INSERT"] = "ins",
    ["REPLACE"] = "ins",
    ["V-REPLACE"] = "ins",
    ["COMMAND"] = "cmd",
    ["EX"] = "cmd",
    ["MORE"] = "norm",
    ["CONFIRM"] = "norm",
    ["SHELL"] = "term",
    ["TERMINAL"] = "term",
  }
  local mode_key = mode_map[mode_util.get_mode(mode_char)]
  if mode_key == nil then
    lib.info(string.format("Unknown mode: `%s`. Fallback to norm", mode_util.get_mode()))
    mode_key = "norm"
  end
  return mode_key
end

-- https://neovim.io/doc/user/builtin.html#mode()
local function get_mode_imname(imname_table, mode)
  return imname_table[mode or get_mode_key()]
end

M.Fcitx5SetPrior = function(mode, imname)
  M.prior[mode or get_mode_key()] = imname
end

M.Fcitx5GetImname = function(mode)
  local imname = get_mode_imname(M.prior, mode)
  if config.prioritize_prior and imname ~= nil then
    return imname
  end
  return get_mode_imname(config.imname, mode)
end

M.Fcitx5GetImnames = function()
  ---@type table<string, string>
  local result = {}
  for _, key in ipairs(vim.tbl_keys(config.imname)) do
    result[key] = M.Fcitx5GetImname(key)
  end
  return result
end

---Fcitx5UpdateMethod
-- Set the imname to `imname`
---@param imname string | nil: e.g. "keyboard-us", if nil, only updates M.prior
---@param old_mode string | nil: one field name of fcitx5.Imname
---@param new_mode string | nil: one field name of fcitx5.Imname
---@return string[]: return line separated result of vim.fn.system
M.Fcitx5UpdateMethod = function(imname, old_mode, new_mode)
  lib.info(string.format("Fcitx5SetName: imname: %s, old_mode: %s, new_mode: %s", imname, old_mode, new_mode))
  local function run(...)
    local command = table.concat(vim.tbl_map(function(a)
      return fcitx5_command() .. a
    end, { "-n", ..., "-n" }), "; ")
    lib.info("Running: " .. command)
    return vim.split(vim.fn.system(command), "\n", { trimempty = true })
  end

  local result = imname ~= nil and run("-s " .. imname) or run("")
  local previous_imname, current_imname = table.remove(result, 1), table.remove(result)
  if old_mode ~= nil then
    M.Fcitx5SetPrior(old_mode, previous_imname)
  end
  if new_mode ~= nil then
    M.Fcitx5SetPrior(new_mode, current_imname)
  end
  lib.info(string.format("Mode changed (%s -> %s). Changed input method (%s -> %s).",
    old_mode, new_mode, previous_imname, current_imname))
  return result
end

M.Fcitx5SetName = function(imname)
  return M.Fcitx5UpdateMethod(imname, nil, get_mode_key())
end

M.Fcitx5Geneious = function()
  lib.info("call Fcitx5Geneious")
  local current_mode = get_mode_key()
  return M.Fcitx5UpdateMethod(M.Fcitx5GetImname(current_mode), nil, current_mode)
end

M.Fcitx5OnModeChanged = function()
  lib.info(string.format("Fcitx5OnModeChanged: old: %s, new: %s", vim.v.event.old_mode, vim.v.event.new_mode))
  local previous_mode, current_mode = get_mode_key(vim.v.event.old_mode), get_mode_key(vim.v.event.new_mode)
  return M.Fcitx5UpdateMethod(M.Fcitx5GetImname(current_mode), previous_mode, current_mode)
end

return M
