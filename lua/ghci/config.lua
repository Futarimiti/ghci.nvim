-- Configuration spec and defaults.
-- Buffer and window local options/keymaps should go to after/ftplugin/ghci.{vim,lua}

local Config = {}

---@class ghci.Config
---@field commands ghci.Config.Commands User command settings
---@field session ghci.Config.Session Settings for spawning ghci sessions
---@field attach ghci.Config.Attach Settings for attaching ghci session to a window

---@class ghci.Config.Commands
---@field enable boolean

---@class ghci.Config.Session
---@field cmd string[] Command to start ghci e.g. `{'ghci'}`, `{'stack', 'ghci', '--nix'}`
---@field output ghci.Config.Session.Output Output settings

---@class ghci.Config.Session.Output
---@field maximum integer Maximum number of characters for output. Exceeding characters will be truncated. This is to avoid infinite output like "[1..]"
---@field on_stdout fun(string) What to do with ghci feedback from stdout
---@field on_stderr fun(string) What to do with ghci feedback from stderr

---@class ghci.Config.Attach
---@field confirm boolean Prompt for confirm if spawned in a window with a modified buffer

---@type ghci.Config
Config.default = {
  commands = { enable = true },
  session = {
    cmd = { 'ghci' },
    output = {
      maximum = 10000,
      on_stdout = function(msg) vim.notify(msg, vim.log.levels.INFO) end,
      on_stderr = function(msg) vim.notify(msg, vim.log.levels.ERROR) end,
    },
  },
  attach = { confirm = true },
}

return Config
