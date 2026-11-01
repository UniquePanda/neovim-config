-- # Git
return {
	{
		-- Git features (like highlighting new/modified/deleted lines, git blame, ...)
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup({
				current_line_blame = true,
				signs = {
					add = { text = '+' },
					change = { text = '=' },
					delete = { text = '-' },
				},
			})

			-- Git blame
			vim.keymap.set('n', 'gb', '<cmd>Gitsigns blame<cr>', { desc = 'Toggle Git blame' })
			-- Hunk navigation
			vim.keymap.set('n', 'gn', '<cmd>Gitsigns nav_hunk next<cr>', { desc = 'Go to next Git hunk' })
			vim.keymap.set('n', 'gN', '<cmd>Gitsigns nav_hunk prev<cr>', { desc = 'Go to previous Git hunk' })

			-- LazyGit (e.g. used for interactive rebases) + GitHub issues/PRs, provided by snacks.nvim
			vim.keymap.set({ 'n', 'v' }, 'gl', function() Snacks.lazygit.open() end, { desc = 'Open LazyGit' })
			vim.keymap.set('n', '<leader>gi', function() Snacks.picker.gh_issue() end, { desc = 'GitHub Issues' })
			vim.keymap.set('n', '<leader>gI', function() Snacks.picker.gh_issue({ state = 'all' }) end, { desc = 'GitHub Issues (including closed)' })
			vim.keymap.set('n', '<leader>gp', function() Snacks.picker.gh_pr() end, { desc = 'GitHub Pull Requests' })
			vim.keymap.set('n', '<leader>gP', function() Snacks.picker.gh_pr({ state = 'all' }) end, { desc = 'GitHub Pull Requests (including closed)' })
		end,
	},
	{
		-- Additional git blame features
		'FabijanZulj/blame.nvim',
		lazy = false,
		opts = {},
	},
}
