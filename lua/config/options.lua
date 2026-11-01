-- # EDITOR OPTIONS

-- Set leader key first to make sure it doesn't collide with any plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true -- show line numbers
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.scrolloff = 10 -- always keep 10 lines above/below cursor

vim.opt.mouse = '' -- disable mouse usage

vim.opt.wrap = true -- wrap long lines
vim.opt.linebreak = true -- wrap long lines at word boundaries instead of in the middle of a word
vim.opt.breakindent = true -- keep indentation when wrapping long lines

-- Fallbacks only, vim-sleuth detects the indentation per file
vim.opt.tabstop = 4 -- display a tab as 4 spaces
vim.opt.shiftwidth = 0 -- use the tabstop value for automatically indented lines
vim.opt.expandtab = false -- don't transform tabs to spaces

vim.opt.ignorecase = true -- ignore case when searching...
vim.opt.smartcase = true -- ...but don't ignore case if the search contains uppercase letters

vim.opt.colorcolumn = '120' -- highlight 120th column
vim.opt.cursorline = true -- highlight line that the cursor is in
vim.opt.splitbelow = true -- split below by default (instead of top)
vim.opt.splitright = true -- split right (after below) by default (instead of left)
vim.opt.splitkeep = 'screen' -- keep text in place when opening/closing splits (e.g. Trouble, quickfix)
vim.opt.signcolumn = 'yes' -- always show sign column (column left of line numbers)

vim.opt.showmode = false -- don't show mode as it is already shown by lualine
vim.opt.inccommand = 'split' -- show a preview window when performing substitutions (e.g. `:%s/old/new/g`)
vim.o.winborder = 'rounded' -- rounded borders for floating windows (LSP hover, diagnostics, ...)

vim.opt.undofile = true -- store undo history in a file to not lose it
vim.opt.updatetime = 250 -- time (ms) without typing until CursorHold fires (used for LSP word highlighting) and the swap file is written
vim.opt.timeoutlen = 600 -- reduce the time (ms) in which Vim waits for the next key in a keybind
vim.opt.confirm = true -- ask to save instead of failing on :q with unsaved changes

vim.opt.list = true
vim.opt.listchars = { tab = '→ ', trail = '·', nbsp = '␣' }
