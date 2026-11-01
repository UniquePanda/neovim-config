-- # THEMING (tokyonight + lualine, with dark and light variant)
local M = {}

local function init_lualine()
	require('lualine').setup({
		options = {
			theme = 'tokyonight',
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
	local util = require('tokyonight.util')
	vim.opt.background = 'dark'

	require('tokyonight').setup({
		style = 'moon',

		on_colors = function(colors)
			colors.fg_gutter = util.lighten(colors.fg_gutter, 0.7)
		end,

		on_highlights = function(highlights, colors)
			highlights.Whitespace = { fg = util.lighten(colors.bg, 0.85) }
			highlights.CopilotSuggestion = { fg = util.lighten(colors.purple, 0.4) }
		end,
	})
	vim.cmd.colorscheme('tokyonight')

	init_lualine()

	local colors = require('tokyonight.colors').setup()
	vim.cmd('highlight ColorColumn ctermbg=0 guibg=' .. util.darken(colors.comment, 0.3))
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
