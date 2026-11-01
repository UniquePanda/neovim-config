-- # GENERAL KEYBINDS
-- Plugin specific keybinds live next to the plugin config in lua/plugins/.

-- Editor movement
vim.keymap.set('n', '<Tab>', '<C-W>w') -- Tab to move to next window
vim.keymap.set('n', '<S-Tab>', '<C-W>W') -- Shift+Tab to move to previous window
vim.keymap.set('n', '<C-h>', 'b') -- Ctrl+h to move back a word
vim.keymap.set('n', '<C-l>', 'e') -- Ctrl+l to move to end of word
vim.keymap.set('n', '<C-j>', '<C-d>') -- Ctrl+j to move down half a page
vim.keymap.set('n', '<C-k>', '<C-u>') -- Ctrl+k to move up half a page

-- Editor misc
vim.keymap.set('n', '<Esc>', 'i') -- Esc enters insert mode before current character
vim.keymap.set('n', '<leader>n', '<cmd>noh<cr>', { desc = 'Remove search result highlights' })
