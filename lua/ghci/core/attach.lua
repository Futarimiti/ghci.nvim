local M = {}

-- Attach a GHCi session to a window.
---@param config ghci.Config.Attach
---@param job vim.SystemObj
---@param win integer
M.attach = function(config, job, win)
  if not vim.api.nvim_win_is_valid(win) then error('not a valid window: ' .. win) end
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

  if config.keymaps.enter then
    vim.keymap.set('i', '<CR>', function()
      if job:is_closing() then
        vim.notify_once('Current GHCi session has already finished', vim.log.levels.WARN)
        return '<CR>'
      else
        local line = vim.api.nvim_get_current_line()
        job:write(line .. '\n')
        return '<End><CR>'
      end
    end, { buffer = buf, expr = true })
  end
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].filetype = 'ghci'
end

return M
