---@class fcitx5.Config
---@field msg string | nil: printed when startup is completed
---@field imname fcitx5.Imname | nil: imnames on each mode set as prior. See `:h map-table` for more in-depth information.
---@field remember_prior boolean: if true, load the mode from last time. if false, use what was set in setup.
---@field define_autocmd boolean: if true, defines autocmd at `ModeChanged` to switch fcitx5 mode.
---@field log string: log level (default: warn)

---@type fcitx5.Config
local DEFAULT_OPTS = {
  msg = nil,
  imname = {
    norm = nil,
    ins = nil,
    cmd = nil,
    vis = nil,
    sel = nil,
    opr = nil,
    term = nil,
    lang = nil,
  },
  remember_prior = true,
  define_autocmd = true,
  log = "warn",
}

---@type fcitx5.Config
local M = {}

local merge_options = function(opts, default)
  return vim.tbl_deep_extend("force", default, opts or {})
end

---load_opts
-- Merge user opts to DEFAULT_OPTS
---@param opts fcitx5.Config | nil: Options from user setup
M.set_options = function(opts)
  for key, value in pairs(merge_options(opts, DEFAULT_OPTS)) do
    M[key] = value
  end
end

return M
