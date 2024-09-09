local GHCi = require 'ghci.core'

local Commands = {}

---@param config ghci.Config
Commands.setup = function(config)
  if config.commands.enable then
    vim.api.nvim_create_user_command('GHCi', function(o)
      local win = vim.api.nvim_get_current_win()
      GHCi.spawn(config, win, o.fargs)
    end, {
      bang = false,
      bar = true,
      nargs = '*',
      complete = 'file',
      desc = 'spawn GHCi session in current window with a command-line-window-like buffer',
    })
  else
    pcall(vim.api.nvim_del_user_command, 'GHCi')
  end
end

return Commands
