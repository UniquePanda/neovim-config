-- # THEMING (dark: dracula, light: tokyonight day; + lualine)
local M = {}

local function init_lualine(theme)
	require('lualine').setup({
		options = {
			theme = theme or 'tokyonight',
			component_separators = { left = '|', right = '|' },
		},
		sections = {
			lualine_a = { 'mode' },
			lualine_b = { 'branch' },
			lualine_c = { 'filename', 'diagnostics' },
			lualine_x = {
				{
					'copilot',
					symbols = {
						status = {
							icons = {
								enabled = ' e',
								sleep = ' s',
								disabled = 'dd',
								warning = ' w',
								unknown = ' u'
							},
						},
					},
				},
			},
			lualine_y = { 'lsp_status' },
			lualine_z = { 'progress', 'location' },
		},
	})
end

function M.dark()
	vim.opt.background = 'dark'

	require('dracula').setup({
		overrides = function(colors)
			return {
				Whitespace = { fg = colors.selection },
				CopilotSuggestion = { fg = colors.comment, italic = true },
				ColorColumn = { bg = colors.menu },
			}
		end,
	})
	vim.cmd.colorscheme('dracula')

	init_lualine('dracula-nvim')
end

function M.light()
	local util = require('tokyonight.util')
	vim.opt.background = 'light'

	require('tokyonight').setup({
		style = 'day',
		day_brightness = 0.3,

		on_colors = function(colors)
			colors.fg_gutter = util.darken(colors.fg_dark, 0.5)
			colors.bg = '#d6d1d0'
		end,

		on_highlights = function(highlights, colors)
			highlights.Whitespace = { fg = util.lighten(colors.bg, 0.65) }
			highlights.CopilotSuggestion = { fg = util.lighten(colors.red, 0.4) }
		end,
	})
	vim.cmd.colorscheme('tokyonight')

	init_lualine()

	local colors = require('tokyonight.colors').setup()
	vim.cmd('highlight ColorColumn ctermbg=0 guibg=' .. util.lighten(colors.comment, 0.9))
end

-- Change theme
vim.keymap.set('n', '<leader>BGD', M.dark, { desc = 'Switch to dark theme' })
vim.keymap.set('n', '<leader>BGL', M.light, { desc = 'Switch to light theme' })

return M
