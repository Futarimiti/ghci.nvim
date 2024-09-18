local Session = {}

-- Spawn a GHCi session.
---@param config ghci.Config.Session
---@return vim.SystemObj
Session.spawn = function(config)
  -- XXX not sure if would work, but I need some pseudokey
  -- \0\0\0
  local prompt = string.char(0):rep(3)
  local set_prompt = ':set prompt "\\0\\0\\0"\n'
  local prompt_cont = string.char(0):rep(4)
  local set_prompt_cont = ':set prompt-cont "\\0\\0\\0\\0"\n'

  local ready = false
  -- Buffers to assemble broken lines
  ---@class Buffers
  ---@field stdout string
  ---@field stderr string
  local buffers = {
    stdout = '',
    stderr = '',
  }

  local job = vim.system(config.cmd, {
    stdin = true,
    stdout = function(err, data)
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
    end,
    -- Only collect pieces of stderr messages.
    -- They will be printed in the stdout handler.
    stderr = function(err, data)
      if not ready then return end
      if err ~= nil then error(err) end
      if not data then return end
      -- print('stderr:', vim.inspect(data))
      buffers.stderr = buffers.stderr .. (data or '')
    end,
    text = true,
  }, function(o)
    vim.schedule(function()
      if config.output.exit.purge then
        if buffers.stderr ~= '' then config.output.on_stderr(buffers.stderr) end
        if buffers.stdout ~= '' then config.output.on_stdout(buffers.stdout) end
      end
      config.output.exit.on_exit(o)
    end)
  end)

  job:write(set_prompt)
  job:write(set_prompt_cont)
  -- FIXME cannot survive :r, :l, etc
  job:write(
    ([[let _print = putStrLn . (\str -> let (xs0, xs1) = splitAt %d str in if null xs1 then xs0 else xs0 ++ "...") . show]]):format(
      config.output.maximum
    ) .. '\n'
  )
  job:write ':set -interactive-print _print\n'
  vim.defer_fn(function() ready = true end, 100) -- XXX
  return job
end

return Session
