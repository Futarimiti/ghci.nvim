local Config = {}

---@class ghci.Config.Commands
---@field enable boolean

---@class ghci.Config.Output
---@field maximum integer Maximum number of characters for output, exceeding characters will be truncated and appended '...'. This is to avoid infinite output like "[1..]"
---@field on_stdout fun(string) What to do with ghci feedback from stdout
---@field on_stderr fun(string) What to do with ghci feedback from stderr

-- Buffer and window local options should go to after/ftplugin/ghci.{vim,lua}
---@class ghci.Config
---@field commands ghci.Config.Commands User command settings
---@field cmd string[] Default command to start ghci
---@field confirm boolean Prompt for confirm if spawning in a window containing modified buffer
---@field output ghci.Config.Output Output settings
Config.default = {
  commands = {
    enable = true,
  },
  cmd = { 'ghci' },
  confirm = true,
  output = {
    maximum = 10000,
    on_stdout = function(msg) vim.notify(msg, vim.log.levels.INFO) end,
    on_stderr = function(msg) vim.notify(msg, vim.log.levels.ERROR) end,
  },
}

return Config
