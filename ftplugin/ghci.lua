local win = vim.api.nvim_get_current_win()
local buf = vim.api.nvim_win_get_buf(win)

vim.wo[win].statusline = '[GHCi scratchpad]'
if not pcall(vim.treesitter.start, buf, 'haskell') then
  -- FIXME albeit this syntax will be set to ghci
  vim.bo[buf].syntax = 'haskell'
end
