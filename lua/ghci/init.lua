local M = {}

local Commands = require 'ghci.commands'
local Config = require 'ghci.config'
local GHCi = require 'ghci.core'

---@param user? table
M.setup = function(user)
  user = user and user or {}
  local config = vim.tbl_deep_extend('force', Config.default, user)
  Commands.setup(config)

  -- Spawn a GHCi session.
  ---@param extra? table|ghci.Config.Session Extra session configuration
  ---@return vim.SystemObj
  M.spawn = function(extra) return GHCi.spawn(vim.tbl_extend('force', config.session, extra or {})) end

  -- Attach a spawned session to a window.
  ---@param job vim.SystemObj
  ---@param win? integer Current window by default
  ---@param extra? table|ghci.Config.Attach Extra attach configuration
  M.attach = function(job, win, extra)
    GHCi.attach(
      vim.tbl_extend('force', config.attach, extra or {}),
      job,
      win or vim.api.nvim_get_current_win()
    )
  end
end

return M
