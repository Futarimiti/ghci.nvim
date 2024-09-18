# GHCi.nvim

Use GHCi sessions in a `q:`-like command-line window that
when you insert `<CR>`,
the current line will be sent to ghci and outputs will be notified



https://github.com/user-attachments/assets/53f53f8c-6e49-42fd-bd8b-9808614e15d8



Basically, run GHCi/cabal repl/stack ghci
but you don't need to leave vim motions aside

## Features

This plugin contaminates your environment by

* Provides a lua module `ghci`; once you `setup`, API functions will be available
* Provides a command `:GHCi [args]`, quick way to spawn a session (can be turned off)
* bruh just read the code its not that many lines

## Basic usage

```lua
-- Configure plugin behaviour here
-- can be setup multiple times - each time override previous config
-- check doc for configuration spec & defaults
local GHCi = require('ghci').setup {...}

-- Spawn a GHCi session.
-- Example: GHCi.spawn { cmd = { 'stack', 'ghci' } }
---@param extra? ghci.Config.Session Any extra session configuration
---@return vim.SystemObj
local job = GHCi.spawn()

-- Attach a spawned session to a window.
---@param job vim.SystemObj
---@param win? integer Current window by default
---@param extra? ghci.Config.Attach Extra attach configuration
GHCi.attach(job)
```

`:GHCi [args]` spawns a GHCi session and attach it to current window

## Limitations/TODO

- [ ] No way of interrupting evaluation, basically done when stuck
- [ ] Use a binding (`_print` or something) for custom interactive print, which pollutes GHCi environment 
    - [ ] Problematic upon `:reload` `:load` etc. where the binding will not survive
- [ ] Users must not `:set prompt` to something else - we need to know the end of output

## Similar projects

* codi.vim

## Licence

WTFPL
