local config = require("fcitx5.config")

local M = {}

M.log_level_int = function(level)
  if type(level) == "number" then
    return 0
  end
  return vim.log.levels[string.upper(level or "info")]
end

---echos `msg` as a vim.notify
---@param msg string: message to notify
---@param level integer | string | nil: ("info", "warn", "error"), if nil, "info" is used
---@param opts table?: Any options to pass to vim.notify
M.echo = function(msg, level, opts)
  local level_int = M.log_level_int(level)
  if M.log_level_int(config.log) <= level_int then
    vim.notify(msg, level_int, opts or {})
  end
end

---return true if file exists
---@param path string: path to file
---@return boolean
M.file_exist = function(path)
  local f = io.open(path, "r")
  return f ~= nil and io.close(f) == true
end

---returns string where `t` is trimmed from both sides of `s`
---@param s string: base string
---@param t string | nil: string to be trimmed, if nil, '%s' is used
M.s_trim = function(s, t)
  if not t then
    t = "%s"
  end
  local result = string.gsub(s, "^" .. t .. "*(.-)" .. t .. "*$", "%1")
  return result
end

---path_win2unix
-- Converts Windows style path to unix style (path with /)
---@param path string
M.path_win2unix = function(path)
  -- local result = string.gsub(path, "\\", "/")
  local result = path
  return result
end

---same as running `basename "$path"` in command line
---@param path string: path to file
M.basename = function(path)
  local result = string.gsub(M.s_trim(path), "(.*/)(.*)", "%2")
  return result
end

---Confirm: asks for a confirmation in cmd
---@param msg string: confirm message asking yes / no
---@param default boolean: return value if <CR> was pressed without any letter
---@return boolean:
M.Confirm = function(msg, default)
  local yes = default and "YES" or "yes"
  local no = default and "no" or "NO"
  local answer = vim.fn.confirm(msg, string.format("&%s\n&%s", yes, no), default and 1 or 2)
  if answer == 0 then
    return M.Confirm(msg .. " Press `y` or `n`.", default)
  end
  return answer == 1
end

---SessionName: returns the basename of `path`
---@param path string: path to cwd
M.SessionName = function(path)
  if path == "" then
    return ""
  end
  return M.s_trim(M.basename(M.path_win2unix(path)), "%.")
end

---FullPath: returns `path`'s absolute path
---@param path string: relative path
---@return string: absolute path of `path`
M.FullPath = function(path)
  return vim.fn.resolve(vim.fn.expand(path))
end

return M
