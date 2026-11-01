-- # Fuzzy Finding
return {
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim', -- some helper functions
			'nvim-telescope/telescope-ui-select.nvim', -- use telescope list ui for other plugins as well
			'nvim-tree/nvim-web-devicons', -- integrate some nice icons
			'nvim-telescope/telescope-live-grep-args.nvim',
			{
				-- Fuzzy Finding Implementation for Telescope
				'nvim-telescope/telescope-fzf-native.nvim',
				build = 'make',
			},
		},
		config = function()
			local telescope = require('telescope')
			local actions = require('telescope.actions')
			local builtin = require('telescope.builtin')

			local open_with_trouble = function(...)
				return require('trouble.sources.telescope').open(...)
			end
			local delete_buffer_and_reload = function()
				Snacks.bufdelete.delete(require('telescope.actions.state').get_selected_entry().bufnr)
				builtin.buffers()
			end

			local mappings = {
				['<C-t>'] = open_with_trouble,
				['<C-d>'] = delete_buffer_and_reload,
				['<PageUp>'] = actions.preview_scrolling_up,
				['<PageDown>'] = actions.preview_scrolling_down,
			}

			telescope.setup({
				defaults = {
					vimgrep_arguments = {
						'rg',
						'--follow',
						'--hidden',
						'--no-heading',
						'--with-filename',
						'--line-number',
						'--column',

						'--glob=!**/.git/*',
						'--glob=!**/.vscode/*',
						'--glob=!**/package-lock.json',
					},
					mappings = {
						i = mappings,
						n = mappings,
					},
					layout_config = {
						scroll_speed = 1,
					},
				},
				pickers = {
					find_files = {
						hidden = true,
					},
				},
				extensions = {
					fzf = {
						case_mode = 'ignore_case',
					},
				},
			})
			telescope.load_extension('fzf')
			telescope.load_extension('live_grep_args')
			telescope.load_extension('ui-select')

			-- Keybinds
			vim.keymap.set('n', '<leader><leader>', builtin.find_files, { desc = 'Find files' })
			vim.keymap.set('n', '<leader><leader><leader>', telescope.extensions.live_grep_args.live_grep_args, { desc = 'Find string in current git repo' })
			vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Find current word in current git repo' })
			vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'Find files in current git repo' })
			vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Find open buffers' })
		end,
	},
	{
		-- Better UI for search results etc.
		'folke/trouble.nvim',
		cmd = 'Trouble',
		opts = {
			focus = true,
			max_items = 3000,
		},
	},
	{
		-- Visual Clipboard History
		'AckslD/nvim-neoclip.lua',
		dependencies = {
			'nvim-telescope/telescope.nvim',
		},
		config = function()
			require('neoclip').setup({
				keys = {
					telescope = {
						i = {
							paste = '<CR>',
						},
						n = {
							paste = '<CR>',
						},
					},
				},
			})
			require('telescope').load_extension('neoclip')

			vim.keymap.set({ 'n', 'i' }, '<A-p>', '<cmd>Telescope neoclip<CR>', { desc = 'Open clipboard history' })
		end,
	},
}
