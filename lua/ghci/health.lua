-- :checkhealth

local M = {}

M.check = function()
  vim.health.start 'Installation'
  local path = vim.fn.exepath 'ghci'
  if path == '' then
    vim.health.warn('`ghci` executable not found on path', {
      'make sure you have a proper installation of ghc toolchain',
    })
  else
    vim.health.ok(('`ghci` executable found: %s'):format(path))
  end
end

return M
