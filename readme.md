# GHCi.nvim

Use GHCi sessions in a `q:`-like command-line window that
* When you insert `<CR>`, line you are currently on will be sent to ghci, outputs will be notified



https://github.com/user-attachments/assets/53f53f8c-6e49-42fd-bd8b-9808614e15d8



Basically, run GHCi/cabal repl/stack ghci but now you don't need to leave the editor

## Features

This plugin contaminates your environment by

* Provides a lua module `ghci`; once you call `.setup` a `.spawn` function will become available
* Provides a command `:GHCi [filename]`, quick way to spawn a session (you can disable this if you want)
* bruh just read the source code its not that many lines

## Usage

```lua
-- can be setup multiple times, would override previous config
-- configuration & defaults see lua/ghci/config.lua and doc
local GHCi = require('ghci').setup {...}

---@param win? integer Spawn in which window, current win by default
---@param files? string[] Any file to load into repl
---@param cmd? string[] Override default cmd to launch ghci for example ['cabal', 'repl']
---@param cwd? string Default current dir
GHCi.spawn(win, files, cmd, cwd)
```

`:GHCi [files]` is equivalent to `GHCi.spawn(<current-win>, <files>)`

## Project outline

See doc

## Limitations/TODO

- [ ] 

## Similar projects

* codi.vim

## Licence

WTFPL
