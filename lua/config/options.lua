-- # EDITOR OPTIONS

-- Leader key is "Space"
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true -- show line numbers
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.scrolloff = 10 -- always keep 10 lines above/below cursor

vim.opt.mouse = '' -- disable mouse usage

vim.opt.wrap = true -- wrap long lines
vim.opt.breakindent = true -- keep indendation when wrapping long lines
vim.opt.tabstop = 4 -- use 4 spaces for 1 tab
vim.opt.shiftwidth = 4 -- use 4 spaces for automatically indented lines
vim.opt.expandtab = false -- don't transform tabs to spaces

vim.g.PHP_IndentFunctionDeclarationParameters = true

vim.opt.ignorecase = true -- ignore case when searching

vim.opt.colorcolumn = '120' -- highlight 120th column
vim.opt.cursorline = true -- highlight line that the cursor is in
vim.opt.splitbelow = true -- split below by default (instead of top)
vim.opt.splitright = true -- split right (after below) by default (instead of left)
vim.opt.signcolumn = 'yes' -- always show sign column (colum left of line numbers)

vim.opt.termguicolors = true -- allow for 24bit colors
vim.opt.showmode = false -- don't show mode as it is already shown by lualine
vim.opt.inccommand = 'split' -- show a preview window when performing substitutions (e.g. `:%s/old/new/g`)

vim.opt.undofile = true -- store undo history in a file to not lose it
vim.opt.updatetime = 250 -- reduce the time (ms) after last keystroke when the swap file is written to disk
vim.opt.timeoutlen = 600 -- reduce the time (ms) in which Vim waits for the next key in a keybind

vim.opt.list = true
vim.opt.listchars = { tab = '→ ', trail = '·', nbsp = '␣' }
