-- # Theming / GUI
-- The actual theme + statusline setup happens in lua/config/theme.lua
return {
	{
		-- GUI Theme
		'folke/tokyonight.nvim',
	},
	{
		-- Status Bar
		'nvim-lualine/lualine.nvim',
		dependencies = {
			'nvim-tree/nvim-web-devicons', -- integrate some nice icons
			'AndreM222/copilot-lualine', -- copilot status component
		},
	},
	{
		-- Better markdown rendering (e.g. for README.md files)
		'MeanderingProgrammer/render-markdown.nvim',
		ft = { 'markdown', 'codecompanion' },
	},
	{
		-- Show list with available keybindings when beginning to type one
		'folke/which-key.nvim',
		event = 'VeryLazy',
		opts = {},
	},
	{
		-- Show context of current line (e.g. name of function you are currently in)
		'nvim-treesitter/nvim-treesitter-context',
		opts = {
			mode = 'topline',
			separator = '⁕',
		},
	},
	{
		-- Highlight todo comments
		'folke/todo-comments.nvim',
		event = 'VimEnter',
		dependencies = {
			'nvim-lua/plenary.nvim',
		},
		opts = {
			keywords = {
				FIX = {
					icon = ' ',
					color = 'error',
					alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE', 'fix', 'fixme', 'bug', 'fixit', 'issue' },
				},
				TODO = { icon = '', color = 'info', alt = { 'todo', 'Todo' } },
				HACK = { icon = ' ', color = 'warning', alt = { 'hack' } },
				WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX', 'warn', 'warning', 'xxx' } },
				PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE', 'perf', 'optim', 'performance', 'optimize' } },
				NOTE = { icon = ' ', color = 'hint', alt = { 'INFO', 'note', 'info' } },
				TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED', 'test', 'testing', 'passed', 'failed' } },
			},
			highlight = {
				keyword = 'bg',
				before = '',
				after = 'bg',
				pattern = [[(--|\/\/|*|#) <(KEYWORDS)>]],
			},
			search = {
				pattern = [[\b(KEYWORDS)\b]],
			},
		},
	},
}
