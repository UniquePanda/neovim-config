-- Set leader key first to make sure it doesn't collide with any plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- # EDITOR OPTIONS
vim.opt.number = true -- show line numbers
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.scrolloff = 10 -- always keep 10 lines above/below cursor

vim.opt.mouse = '' -- disable mouse usage

vim.opt.wrap = true -- wrap long lines
vim.opt.breakindent = true -- keep indendation when wrapping long lines
vim.opt.tabstop = 4 -- use 4 spaces for 1 tab
vim.opt.shiftwidth = 4 -- use 4 spaces for automatically indented lines
vim.opt.expandtab = false -- don't transform tabs to spaces

vim.opt.ignorecase = true -- ignore case when searching

vim.opt.colorcolumn = { 120 } -- highlight 120th column
vim.opt.cursorline = true -- highlight line that the cursor is in
vim.opt.splitbelow = true -- split below by default (instead of top)
vim.opt.splitright = true -- split right (after below) by default (instead of left)
vim.opt.signcolumn = 'yes' -- always show sign column (colum left of line numbers) 

vim.opt.termguicolors = true -- allow for 24bit colors (i think?)
vim.opt.showmode = false -- don't show mode as it is already shown by lualine
vim.opt.inccommand = 'split' -- show a preview window when performing substitutions (e.g. `:%s/old/new/g`)

vim.opt.undofile = true -- store undo history in a file to not lose it
vim.opt.updatetime = 250 -- reduce the time (ms) after last keystroke when the swap file is written to disk
vim.opt.timeoutlen = 600 -- reduce the time (ms) in which Vim waits for the next key in a keybind

vim.opt.list = true
vim.opt.listchars = { tab = '→ ', trail = '·', nbsp = '␣' }

-- install lazy.nvim (plugin manager)
local lazy = {}

function lazy.install(path)
	if (vim.uv or vim.loop).fs_stat(path) then
		return
	end

	print('Installing lazy.nvim...')
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable',
		path,
	})
	print('Installed lazy.vim')
end

function lazy.setup(plugins)
	if vim.g.plugins_ready then
		return
	end

	lazy.install(lazy.path)

	vim.opt.rtp:prepend(lazy.path)

	require('lazy').setup(plugins, lazy.opts)
	vim.g.plugins_ready = true
end

-- # PLUGIN INSTALLATION (via lazy.nvim)
lazy.path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
lazy.opts = {} -- Add lazy options here if needed

lazy.setup({
	-- # Theming / GUI
	{
		-- GUI Theme
		'folke/tokyonight.nvim'
	},
	{
		-- Status Bar
		'nvim-lualine/lualine.nvim',
		dependencies = {
			{
				'nvim-tree/nvim-web-devicons' -- integrate some nice icons
			}
		}
	},

	-- # Parsing / LSP
	{
		-- Parsing/Syntax Highlighting
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			require('nvim-treesitter.configs').setup {
				ensure_installed = { 'c', 'lua', 'vimdoc' }, -- Add all needed languages here
				highlight = { enable = true }
			}
		end
	},
	{
		-- LSP
		'neovim/nvim-lspconfig',
		dependencies = {
			-- Package manager for LSPs
			{
				'williamboman/mason.nvim',
				config = true
			},
			-- Connect mason with lspconfig
			{
				'williamboman/mason-lspconfig.nvim'
			},
			{
				-- Easier installation/updating of mason tools
				'WhoIsSethDaniel/mason-tool-installer.nvim'
			}
		}
	},

	-- # Fuzzy Finding
	{
		-- Fuzzy Finder
		'nvim-telescope/telescope.nvim', branch = '0.1.x',
		dependencies = {
			{
				'nvim-lua/plenary.nvim', -- some helper functions
			},
			{
				'nvim-telescope/telescope-ui-select.nvim', -- use telescope list ui for other plugins as well
			},
			{
				'nvim-tree/nvim-web-devicons' -- integrate some nice icons
			}
		}
	},
	{
		-- Fuzzy Finding Implementation for Telescope
		'nvim-telescope/telescope-fzf-native.nvim',
		build = 'make'
	},

	-- # Git
	{
		-- Integration for Git
		'tpope/vim-fugitive'
	},
	{
		-- Git features (like highlighting new/modified/deleted lines, git blame, ...)
		'lewis6991/gitsigns.nvim'
	},
	-- LazyGit integration (GUI for Git)
	{
		'kdheepak/lazygit.nvim',
		cmd = {
			'LazyGit',
			'LazyGitConfig',
			'LazyGitCurrentFile',
			'LazyGitFilter',
			'LazyGitFilterCurrentFile',
		},
		dependencies = {
			'nvim-lua/plenary.nvim'
		}
	},

	-- # Additional Stuff
	{
		-- Show list with available keybindings when beginning to type one
		'folke/which-key.nvim',
		event = 'VeryLazy',
	},
	{
		-- Automatically detect tabstop and shiftwidth based on current file
		'tpope/vim-sleuth'
	},
	{
		-- Comment lines easily
		'numToStr/Comment.nvim'
	}
})

-- # PLUGIN Loading + CONFIG
require('telescope').setup {
	extensions = {
		fzf = {
			case_mode = 'ignore_case'
		}
	}
}
require('telescope').load_extension('fzf');
require('telescope').load_extension('ui-select');

require('which-key').setup()
require('Comment').setup()

require('gitsigns').setup {
	current_line_blame = true,
	signs = {
		add = { text = '+' },
		change = { text = '=' },
		delete = { text = '-' }
	}
}

-- # THEMING
local util = require("tokyonight.util")
theming = {}

function theming.initLualine()
	require('lualine').setup({
		options = {
			theme = 'tokyonight'
		}
	})
end

function theming.initDark()
	require('tokyonight').setup({
		style = 'moon',

		on_colors = function(colors)
			colors.fg_gutter = util.lighten(colors.fg_gutter, 0.7)
		end,

		on_highlights = function (highlights, colors)
			highlights.Whitespace = { fg = util.lighten(colors.bg, 0.85) }
		end
	})
	vim.cmd.colorscheme('tokyonight')

	theming.initLualine()

	local colors = require("tokyonight.colors").setup()
	vim.cmd('highlight ColorColumn ctermbg=0 guibg=' .. util.darken(colors.comment, 0.3))
end

function theming.initLight()
	require('tokyonight').setup({
		style = 'day',
		day_brightness = 0.4,

		on_colors = function(colors)
			colors.fg_gutter = util.darken(colors.fg_dark, 0.5)
		end,

		on_highlights = function (highlights, colors)
			highlights.Whitespace = { fg = util.lighten(colors.bg, 0.85) }
		end
	})
	vim.cmd.colorscheme('tokyonight')

	theming.initLualine()

	local colors = require("tokyonight.colors").setup()
	vim.cmd('highlight ColorColumn ctermbg=0 guibg=' .. util.lighten(colors.comment, 0.5))
end

theming.initDark()

-- # KEYBINDS
-- Change theme
vim.keymap.set('n', '<leader>bgd', '<cmd>lua theming.initDark()<CR>') -- Leader+bgd to switch to dark mode
vim.keymap.set('n', '<leader>bgl', '<cmd>lua theming.initLight()<CR>') -- Leader+bgl to switch to light mode

-- Editor movement
vim.keymap.set('n', '<Tab>', '<C-W>w') -- Tab to move to next window
vim.keymap.set('n', '<S-Tab>', '<C-W>W') -- Shif+Tab to move to previous window
vim.keymap.set('n', '<C-h>', 'b') -- Ctrl+h to move back a word
vim.keymap.set('n', '<C-l>', 'w') -- Ctrl+l to move forward a word
vim.keymap.set('n', '<C-j>', '<C-d>') -- Ctrl+j to move down half a page
vim.keymap.set('n', '<C-k>', '<C-u>') -- Ctrl+k to move up half a page

-- Editor misc
vim.keymap.set('n', '<Esc>', 'i') -- Esc enters insert mode before current character
vim.keymap.set('n', '<leader>n', '<cmd>noh<cr>', { desc = 'Remove search result highlights' })

-- Telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader><leader>', telescope.current_buffer_fuzzy_find, { desc = 'Find in current file' })
vim.keymap.set('n', '<leader>fw', telescope.grep_string, { desc = 'Find current word' })
vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = 'Find files' })

-- Git
local gitsigns = require('gitsigns')
-- Staging/Resetting hunks
vim.keymap.set('v', '<leader>gs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'Stage selected range' })
vim.keymap.set('v', '<leader>gu', function() gitsigns.undo_stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'Unstage selected range' })
vim.keymap.set('v', '<leader>gr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'Revert selected range' })
-- Staging/Resetting buffer
vim.keymap.set({'n', 'v'}, '<leader>gS', gitsigns.stage_buffer, { desc = 'Stage all' })
vim.keymap.set({'n', 'v'}, '<leader>gU', '<cmd>:Git restore --staged %<cr>', { desc = 'Unstage all' })
vim.keymap.set({'n', 'v'}, '<leader>gR', gitsigns.reset_buffer, { desc = 'Revert all' })
-- Committing/Pushing
vim.keymap.set({'n', 'v'}, '<leader>gc', '<cmd>:Git commit -a<cr>', { desc = 'Commit staged changes' })
vim.keymap.set({'n', 'v'}, '<leader>gp', '<cmd>:Git push<cr>', { desc = 'Push new commits' })
vim.keymap.set({'n', 'v'}, '<leader>gpf', '<cmd>:Git push --force<cr>', { desc = 'Force push new commits' })
-- LazyGit (e.g. used for interactive rebases)
vim.keymap.set({'n', 'v'}, '<leader>gl', '<cmd>LazyGitCurrentFile<cr>', {desc = 'Open LazyGit' })
