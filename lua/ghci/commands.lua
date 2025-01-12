local GHCi = require 'ghci.core'

local Commands = {}

---@param config ghci.Config
Commands.setup = function(config)
  if config.commands.enable then
    vim.api.nvim_create_user_command('GHCi', function(o)
      local win = vim.api.nvim_get_current_win()
      local job = GHCi.spawn(vim.tbl_deep_extend('force', config.session, {
        cmd = vim.list_extend(vim.deepcopy(config.session.cmd), o.fargs),
        output = {
          exit = {
            on_exit = function(exit)
              config.session.output.exit.on_exit(exit)
              vim.api.nvim_win_call(win, vim.cmd.stopinsert)
              vim.api.nvim_buf_delete(vim.api.nvim_win_get_buf(win), { force = true })
            end,
          },
        },
      }))
      GHCi.attach(config.attach, job, win)
    end, {
      desc = 'spawn GHCi session in current window with a command-line-window-like buffer',
      bang = false,
      bar = true,
      nargs = '*',
      complete = config.commands.complete and function(arglead, _, _)
        local options = vim
          .iter(require('ghci.complete').options)
          :filter(function(item) return vim.startswith(item, arglead) end)
          :totable()
        local files =
          vim.iter(vim.fn.glob(arglead .. '*', true, true)):map(vim.fs.normalize):totable()
        return vim.list_extend(options, files)
      end or 'file',
    })
  else
    pcall(vim.api.nvim_del_user_command, 'GHCi')
  end
end

return Commands
