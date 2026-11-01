-- # General editor utilities
return {
	{
		-- Snacks (many handy utils in one plugin)
		'folke/snacks.nvim',
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			bufdelete = { enabled = true },
			gh = { enabled = true },
			indent = { enabled = true },
			lazygit = { enabled = true },
			notifier = { enabled = true },
			picker = { enabled = true },
			scratch = { enabled = true },
		},
		config = function(_, opts)
			require('snacks').setup(opts)

			vim.keymap.set('n', '<leader>nh', function() Snacks.notifier.show_history() end, { desc = 'Show notification history' })
		end,
	},
	{
		-- File Browser
		'stevearc/oil.nvim',
		dependencies = { 'nvim-mini/mini.icons' },
		config = function()
			require('oil').setup({
				default_file_explorer = true,
				view_options = {
					show_hidden = true,
					case_insensitive = true,
				},
				columns = {
					'mtime',
					'icon',
				},
				constrain_cursor = 'name',
				keymaps = {
					['q'] = 'actions.close',
					['<PageUp>'] = 'actions.preview_scroll_up',
					['<PageDown>'] = 'actions.preview_scroll_down',
				},
				preview_win = {
					preview_method = 'load',
				},
				float = {
					padding = 2,
					border = 'rounded',
				},
			})

			-- Oil in floating window mode with preview open
			vim.keymap.set('n', '<leader>o', function() require('oil').open_float(nil, { preview = {} }) end, { desc = 'Open Oil (file browser)' })
		end,
	},
	{
		-- Comment lines easily
		'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup({
				mappings = {
					basic = false,
					extra = false,
				},
			})

			vim.keymap.set(
				'n',
				'<leader>#',
				function()
					return vim.v.count == 0
						and '<Plug>(comment_toggle_linewise_current)'
						or '<Plug>(comment_toggle_linewise_count)'
				end,
				{ expr = true, desc = '(Un)comment current line' }
			)
		end,
	},
	{
		-- Session Manager
		'rmagatti/auto-session',
		dependencies = {
			'nvim-telescope/telescope.nvim',
		},
		opts = {
			cwd_change_handling = {
				post_cwd_changed_hook = function()
					require('lualine').refresh()
				end,
			},
		},
	},
	{
		-- Automatically detect tabstop and shiftwidth based on current file
		'tpope/vim-sleuth',
	},
}
