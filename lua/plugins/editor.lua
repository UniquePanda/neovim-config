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
			lazygit = {
				enabled = true,
				config = {
					os = {
						-- Close the LazyGit float and open the file in the parent Neovim instance
						edit = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || nvim --server "$NVIM" --remote-expr "v:lua.LazygitEdit(\'{{filename}}\')"',
						editAtLine = '[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || nvim --server "$NVIM" --remote-expr "v:lua.LazygitEdit(\'{{filename}}\', {{line}})"',
					},
				},
			},
			notifier = { enabled = true },
			picker = { enabled = true },
			scratch = { enabled = true },
		},
		config = function(_, opts)
			require('snacks').setup(opts)

			-- Called by LazyGit (via --remote-expr) when pressing "e" on a file:
			-- closes the LazyGit float and opens the file in the previous window
			_G.LazygitEdit = function(file, line)
				vim.schedule(function()
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local buf = vim.api.nvim_win_get_buf(win)
						if vim.bo[buf].filetype == 'snacks_terminal' and vim.api.nvim_win_get_config(win).relative ~= '' then
							pcall(vim.api.nvim_win_close, win, true)
						end
					end
					vim.cmd.edit(vim.fn.fnameescape(file))
					if line then
						pcall(vim.api.nvim_win_set_cursor, 0, { tonumber(line), 0 })
						return
					end

					-- Jump to the first Git hunk once gitsigns has computed the hunks
					local buf = vim.api.nvim_get_current_buf()
					local attempts = 0
					local function jump_to_first_hunk()
						if not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_get_current_buf() ~= buf then return end
						local ok, gs = pcall(require, 'gitsigns')
						local hunks = ok and gs.get_hunks(buf) or nil
						if hunks and #hunks > 0 then
							gs.nav_hunk('first')
						elseif attempts < 20 then
							attempts = attempts + 1
							vim.defer_fn(jump_to_first_hunk, 50)
						end
					end
					jump_to_first_hunk()
				end)
				return ''
			end

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
