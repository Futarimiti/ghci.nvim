local GHCi = {}

-- Set up ghci buffer options
---@param _ ghci.Config
---@param job vim.SystemObj
---@param win integer
local setup_opts = function(_, job, win)
  local buf = vim.api.nvim_win_get_buf(win)
  vim.bo[buf].buftype = 'nofile'
  if not pcall(vim.treesitter.start, buf, 'haskell') then vim.bo[buf].syntax = 'haskell' end
  vim.wo[win].statusline = '[GHCi scratchpad]'
  vim.keymap.set('i', '<CR>', function()
    if job:is_closing() then
      -- not sure when would this branch be triggered
      vim.notify_once('Current GHCi session has already finished', vim.log.levels.WARN)
      return '<Nop>'
    else
      local line = vim.api.nvim_get_current_line()
      job:write(line .. '\n')
      return '<End><CR>'
    end
  end, { buffer = buf, expr = true })
  vim.bo[buf].filetype = 'ghci'
end

-- Spawn a GHCi session on the given window.
---@param config ghci.Config
---@param win? integer Spawn in which window, current win by default
---@param files? string[] Any file to load into repl
---@param cmd? string[] Override default cmd to launch ghci for example ['cabal', 'repl']
---@param cwd? string Override cwd, or just current dir
---@return vim.SystemObj job GHCi session object
GHCi.spawn = function(config, win, files, cmd, cwd)
  win = win and (vim.api.nvim_win_is_valid(win) and win or error('not a valid window: ' .. win))
    or vim.api.nvim_get_current_win()
  cmd = cmd or config.cmd
  files = files or {}
  vim.iter(files):each(function(f) table.insert(cmd, f) end)

  local buf = vim.api.nvim_create_buf(false, true)

  -- XXX
  if config.confirm then
    local confirm = vim.o.confirm
    vim.o.confirm = true
    vim.api.nvim_win_set_buf(win, buf)
    vim.o.confirm = confirm
  else
    vim.api.nvim_win_set_buf(win, buf)
  end

  -- XXX not sure if would work, but I need some pseudokey
  -- \0\0\0
  local prompt = string.char(0):rep(3)
  local set_prompt = ':set prompt "\\0\\0\\0"\n'
  local prompt_cont = string.char(0):rep(4)
  local set_prompt_cont = ':set prompt "\\0\\0\\0\\0"\n'

  local ready = false
  -- Buffers to assemble broken lines
  ---@class Buffers
  ---@field stdout string
  ---@field stderr string
  local buffers = {
    stdout = '',
    stderr = '',
  }

  ---@param err string what's this???
  ---@param data string?
  local handle_stdout = function(err, data)
    if not ready then return end
    if err ~= nil then error(err) end
    if data == nil then return end
    -- print('stdout:', vim.inspect(data))
    buffers.stdout = buffers.stdout .. (data or '')

    -- XXX prompt-cont must be checked before prompt since it's longer
    vim.schedule(function()
      if vim.endswith(buffers.stdout, prompt) then
        if buffers.stderr ~= '' then
          config.output.on_stderr(buffers.stderr)
          buffers.stderr = ''
        end
        buffers.stdout = buffers.stdout:sub(0, -(1 + #prompt)):gsub(prompt_cont, '')
        if buffers.stdout ~= '' then
          config.output.on_stdout(buffers.stdout)
          buffers.stdout = ''
        end
      end
    end)
  end

  -- Only collect pieces of stderr messages.
  -- They will be printed in the stdout handler.
  ---@param err string what's this???
  ---@param data string
  local handle_stderr = function(err, data)
    if not ready then return end
    if err ~= nil then error(err) end
    if not data then return end
    -- print('stderr:', vim.inspect(data))
    buffers.stderr = buffers.stderr .. (data or '')
  end

  ---@param o vim.SystemCompleted
  local on_exit = function(o)
    vim.schedule(function()
      vim.api.nvim_win_call(win, vim.cmd.stopinsert)
      if buffers.stderr ~= '' then config.output.on_stderr(buffers.stderr) end
      if buffers.stdout ~= '' then config.output.on_stdout(buffers.stdout) end
      vim.notify(('GHCi session finished with signal %d'):format(o.signal), vim.log.levels.INFO)
      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end

  local job = vim.system(cmd, {
    cwd = cwd,
    cmd = cmd,
    stdin = true,
    stdout = handle_stdout,
    stderr = handle_stderr,
    text = true,
  }, on_exit)
  job:write(set_prompt)
  job:write(set_prompt_cont)
  job:write(
    ([[let _print = putStrLn . (\str -> let (xs0, xs1) = splitAt %d str in if null xs1 then xs0 else xs0 ++ "...") . show]]):format(
      config.output.maximum
    ) .. '\n'
  )
  job:write([[:set -interactive-print _print]] .. '\n')
  setup_opts(config, job, win)
  vim.defer_fn(function() ready = true end, 50) -- XXX
  return job
end

return GHCi
