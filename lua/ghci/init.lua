local M = {}

local Commands = require 'ghci.commands'
local Config = require 'ghci.config'
local GHCi = require 'ghci.core'

---@param user? any
M.setup = function(user)
  user = user and user or {}
  local config = vim.tbl_deep_extend('force', Config.default, user)
  Commands.setup(config)

  -- Spawn and attach a GHCi session.
  ---@param win? integer Spawn in which window, current win by default
  ---@param files? string[] Any file to load into repl
  ---@param cmd? string[] Override default cmd to launch ghci for example ['cabal', 'repl']
  ---@param cwd? string Override cwd, or just current dir
  M.spawn = function(win, files, cmd, cwd) GHCi.spawn(config, win, files, cmd, cwd) end
end

return M
