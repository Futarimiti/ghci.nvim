# GHCi.nvim

Use GHCi sessions in a `q:`-like command-line window that
* When you insert `<CR>`, line you are currently on will be sent to ghci, outputs will be notified



https://github.com/user-attachments/assets/53f53f8c-6e49-42fd-bd8b-9808614e15d8



Basically, run GHCi/cabal repl/stack ghci but now you don't need to leave the editor

## Features

This plugin contaminates your environment by

* Provides a lua module `ghci`; once you call `.setup`, function `.spawn` and `.attach` will become available
* Provides a command `:GHCi [args]`, quick way to spawn a session (can be turned off)
* bruh just read the source code its not that many lines

## Usage

```lua
-- can be setup multiple times - each time override previous config
-- configuration & defaults see lua/ghci/config.lua and doc
local GHCi = require('ghci').setup {...}

-- Spawn a GHCi session.
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

## Project outline

See doc

## Limitations/TODO

- [ ] No way to interrupt evaluation, basically done when stuck
- [ ] Use a binding (`_print` or something) for custom interactive print, which pollutes GHCi environment 
    - [ ] Problematic upon `:reload`, which seems to clear that binding
- [ ] Users must not `:set prompt` to something else - we need to know the end of output

## Similar projects

* codi.vim

## Licence

WTFPL
