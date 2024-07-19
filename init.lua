-- This config is obviously inspired by the famous kickstart.nvim config

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

vim.opt.autoindent = true
vim.g.PHP_IndentFunctionDeclarationParameters = true

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

vim.filetype.add({
	pattern = {
		['.*%.blade%.php'] = 'blade',
	},
})

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
	print('Installed lazy.nvim')
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
		opts = {
			ensure_installed = {
				-- Add all needed languages here
				'bash',
				'c',
				'cpp',
				'html',
				'java',
				'javascript',
				'json',
				'lua',
				'luadoc',
				'markdown',
				'php',
				'typescript',
				'vim',
				'vimdoc',
				'vue',
			},
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		},
		config = function(_, opts)
			require('nvim-treesitter.install').prefer_git = true
			require('nvim-treesitter.configs').setup(opts)
			require('nvim-treesitter.parsers').get_parser_configs().blade = {
				install_info = {
					url = "https://github.com/EmranMR/tree-sitter-blade",
					files = {"src/parser.c"},
					branch = "main",
				},
				filetype = 'blade',
			}
		end,
	},
	{
		-- LSP
		'neovim/nvim-lspconfig',
		opts = function()
			return {
				diagnostics = {
					underline = true,
					update_in_insert = false,
					severity_sort = false,
				}
			}
		end,
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
			-- Easier installation/updating of mason tools
			{
				'WhoIsSethDaniel/mason-tool-installer.nvim'
			},
			-- Status updates for LSP
			{
				'j-hui/fidget.nvim'
			},
			-- Neovim Config LUA LSP
			{
				'folke/neodev.nvim'
			}
		},
		config = function()
			-- Called everytime an LSP is attached to a file (everytime a file with a recognized extension is opened)
			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(event)
					local keymap = function(keys, func, desc)
						vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
					end

					local telescope = require('telescope.builtin')
					keymap('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
					keymap('gr', telescope.lsp_references, '[G]oto [R]eferences')
					keymap('gm', telescope.lsp_implementations, '[G]oto I[m]plementation')
					keymap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
					keymap('<leader><cr>', vim.lsp.buf.code_action, 'Code Action (suggestions etc.)')
					keymap('K', vim.lsp.buf.hover, 'Show documentation (hover)')
					keymap('<leader>h', vim.diagnostic.open_float, 'Show diagnostics [h]int')

					-- Autocommands to highlight the word under the cursor (and clear highlight on cursor move)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if (client and client.server_capabilities.documentHighlightProvider) then
						local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
						vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
							group = highlight_augroup,
							buffer = event.buf,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
							group = highlight_augroup,
							buffer = event.buf,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd('LspDetach', {
							callback = function (event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
							end,
						})
					end

					-- Display inlay hints by default and add toggle
					if (client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint) then
						vim.lsp.inlay_hint.enable(true)
						keymap(
							'<leader>th',
							function()
								vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
							end,
							'[T]oggle Inlay [H]ints'
						)
					end
				end,
			})

			-- Merge capabilities of plugins into the default neovim capabilities list
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

			-- Enabled language servers
			local servers = {
				bashls = {}, -- bash
				clangd = {}, -- c++
				html = {}, -- html
				jdtls = {}, -- java
				jsonls = {}, -- json
				lua_ls = { -- lua
					settings = {
						Lua = {
							completion = {
								callSnippet = 'Replace',
							},
							diagnostics = {
								globals = { 'vim' },
							},
						},
					},
				},
				marksman = {}, -- markdown
				phpactor = {}, -- php
				tsserver = {},
				volar = {}, -- vuejs
			}

			-- Setup mason to automatically install the servers and tools
			require('mason').setup()

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				-- additional tools that should be installed via mason
				'stylua', -- format Lua code
			})

			require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

			require('mason-lspconfig').setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- override default LSP config with values defined above
						server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
						require('lspconfig')[server_name].setup(server)
					end,
				},
			})
		end,
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

	-- File Browser
	{
		'stevearc/oil.nvim',
		dependencies = { "echasnovski/mini.icons" },
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
	},
	{
		-- Auto completion
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			{
				'L3MON4D3/LuaSnip', -- Snippet engine for snippets in different programming languages
				build = (function()
					return 'make install_jsregexp'
				end)(),
			},
			'saadparwaiz1/cmp_luasnip',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-path',
		},
		config = function()
			local cmp = require 'cmp'
			local luasnip = require 'luasnip'
			luasnip.config.setup({})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = 'menu,menuone,noinsert' },
				mapping = cmp.mapping.preset.insert {
					['<Tab>'] = cmp.mapping.select_next_item(),
					['<S-Tab>'] = cmp.mapping.select_prev_item(),
					['<CR>'] = function(fallback)
						if (not cmp.visible() or not cmp.get_selected_entry() or cmp.get_selected_entry().source.name == 'nvim_lsp_signature_help') then
							fallback() -- normal enter (probably just adds a line break in current buffer)
						else
							cmp.confirm({ select = true })
							if luasnip.expandable() then
								luasnip.expand()
							end
						end
					end,

					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),

					['<C-Space>'] = cmp.mapping.complete({}),

					-- Move to next snippet expansion location
					['<C-l>'] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { 'i', 's' }),

					-- Move to previous snippet expansion location
					['<C-h>'] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { 'i', 's' }),
				},
				sources = {
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'path' },
				},
			})
		end,
	},
	-- Session Manager
	{
		'rmagatti/auto-session',
		dependencies = {
			'nvim-telescope/telescope.nvim',
		},
	},
	-- Highlight todo comments
	{
		'folke/todo-comments.nvim',
		event = 'VimEnter',
		dependencies = {
			'nvim-lua/plenary.nvim',
		},
	},
	-- Visual Clipboard History
	{
		'AckslD/nvim-neoclip.lua',
		dependencies = {
			{'nvim-telescope/telescope.nvim'}
		}
	},
	-- Easier access and visualizations of notifications
	{
		'rcarriga/nvim-notify',
	},
	-- Reminds you of how to do things better in NeoVim :)
	{
		'm4xshen/hardtime.nvim',
		dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
	},
})

-- # PLUGIN LOADING + CONFIG
require('telescope').setup {
	defaults = {
		vimgrep_arguments = {
			'rg',
			'--follow',
			'--hidden',
			'--no-heading',
			'--with-filename',
			'--line-number',
			'--column',
			'--ignore-case',

			'--glob=!**/.git/*',
			'--glob=!**/.vscode/*',
			'--glob=!**/package-lock.json',
		},
	},
	pickers = {
		find_files = {
			hidden = true,
		},
	},
	extensions = {
		fzf = {
			case_mode = 'ignore_case'
		},
	}
}
require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')
require('telescope').load_extension('neoclip')
require('telescope').load_extension('notify')

require('gitsigns').setup {
	current_line_blame = true,
	signs = {
		add = { text = '+' },
		change = { text = '=' },
		delete = { text = '-' }
	}
}

require('neoclip').setup({
	keys = {
		telescope = {
			i = {
				paste_behind = '<CR>',
			},
			n = {
				paste_behind = '<CR>',
			},
		},
	},
})

require('todo-comments').setup({
	keywords = {
		FIX = {
			icon = " ",
			color = "error",
			alt = { "FIXME", "BUG", "FIXIT", "ISSUE", 'fix', 'fixme', 'bug', 'fixit', 'issue' },
		},
		TODO = { icon = "", color = "info", alt = {'todo'} },
		HACK = { icon = " ", color = "warning", alt = {'hack'} },
		WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX", 'warn', 'warning', 'xxx' } },
		PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE", 'perf', 'optim', 'performance', 'optimize' } },
		NOTE = { icon = " ", color = "hint", alt = { "INFO", 'note', 'info' } },
		TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED", 'test', 'testing', 'passed', 'failed' } },
	},
	highlight = {
		keyword = "bg",
		before = "",
		after = "bg",
		pattern = [[.*<(KEYWORDS)\W]],
	},
	search = {
		pattern = [[\b(KEYWORDS)\b]],
	},
})

require("oil").setup({
	view_options = {
		show_hidden = true,
		case_insensitive = true,
	},
})

require('auto-session').setup({
	cwd_change_handling = {
		post_cwd_changed_hook = function()
			require("lualine").refresh()
		end,
	},
})

require('which-key').setup()
require('Comment').setup()
require('hardtime').setup()

require('notify').setup()
vim.notify = require("notify")

-- # THEMING
local util = require("tokyonight.util")
Theming = {}

function Theming.initLualine()
	require('lualine').setup({
		options = {
			theme = 'tokyonight'
		}
	})
end

function Theming.initDark()
	vim.opt.background = 'dark'

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

	Theming.initLualine()

	local colors = require("tokyonight.colors").setup()
	vim.cmd('highlight ColorColumn ctermbg=0 guibg=' .. util.darken(colors.comment, 0.3))
end

function Theming.initLight()
	vim.opt.background = 'light'

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

	Theming.initLualine()

	local colors = require("tokyonight.colors").setup()
	vim.cmd('highlight ColorColumn ctermbg=0 guibg=' .. util.lighten(colors.comment, 0.5))
end

Theming.initDark()

-- # SNIPPETS (via LuaSnip)
local ls = require("luasnip")
local snippet = ls.snippet
local snippetInsertNode = ls.insert_node
local snippetTextNode = ls.text_node

-- C# Snippets
ls.add_snippets('cs', {
	snippet("log", {
		snippetTextNode('Debug.Log('), snippetInsertNode(1), snippetTextNode(')')
	}),
})

-- # KEYBINDS
-- Change theme
vim.keymap.set('n', '<leader>bgd', '<cmd>lua Theming.initDark()<CR>') -- Leader+bgd to switch to dark mode
vim.keymap.set('n', '<leader>bgl', '<cmd>lua Theming.initLight()<CR>') -- Leader+bgl to switch to light mode

-- Editor movement
vim.keymap.set('n', '<Tab>', '<C-W>w') -- Tab to move to next window
vim.keymap.set('n', '<S-Tab>', '<C-W>W') -- Shif+Tab to move to previous window
vim.keymap.set('n', '<C-h>', 'b') -- Ctrl+h to move back a word
vim.keymap.set('n', '<C-l>', 'w') -- Ctrl+l to move forward a word
vim.keymap.set('n', '<C-j>', '<C-d>') -- Ctrl+j to move down half a page
vim.keymap.set('n', '<C-k>', '<C-u>') -- Ctrl+k to move up half a page
vim.keymap.set('n', '°', ':bnext<cr>') -- Shift+^ (°) to move to next buffer (file) 

-- Editor misc
vim.keymap.set('n', '<Esc>', 'i') -- Esc enters insert mode before current character
vim.keymap.set('n', '<leader>n', '<cmd>noh<cr>', { desc = 'Remove search result highlights' })
vim.keymap.set({'n', 'i'}, '<A-p>', '<cmd>Telescope neoclip<CR>') -- Alt+P to open clipboard history

-- Oil (File browser)
vim.keymap.set('n', '<leader>o', '<cmd>Oil<cr>', { desc = 'Open Oil (file browser)' })

-- Telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader><leader>', telescope.current_buffer_fuzzy_find, { desc = 'Find string in current file' })
vim.keymap.set('n', '<leader><leader><leader>', telescope.live_grep, { desc = 'Find string in current git repo' })
vim.keymap.set('n', '<leader>fw', telescope.grep_string, { desc = 'Find current word in current git repo' })
vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', telescope.git_files, { desc = 'Find files in current git repo' })

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
