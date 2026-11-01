-- # Linting (as extension to LSP)
return {
	{
		'mfussenegger/nvim-lint',
		config = function()
			local lint = require('lint')
			lint.linters_by_ft = {
				markdown = { 'markdownlint' },
				php = { 'phpstan' },
			}
			lint.linters.cspell.stdin = true
			lint.linters.cspell.args = {
				'lint',
				'--no-color',
				'--no-progress',
				'--no-summary',
				'--show-suggestions',
				-- Make sure that data is read from stdin to make autocommand trigger 'InsertLeave' work
				function() return 'stdin://' .. vim.api.nvim_buf_get_name(0) end,
			}

			vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
