-- # Parsing / Syntax Highlighting
return {
	{
		'nvim-treesitter/nvim-treesitter',
		branch = 'main',
		lazy = false,
		build = ':TSUpdate',
		config = function()
			local ts = require('nvim-treesitter')

			-- Own parser for Blade (must be registered before install())
			vim.api.nvim_create_autocmd('User', {
				pattern = 'TSUpdate',
				callback = function()
					require('nvim-treesitter.parsers').blade = {
						install_info = {
							url = 'https://github.com/EmranMR/tree-sitter-blade',
							branch = 'main',
						},
					}
				end,
			})

			ts.install({
				'bash', 'blade', 'c', 'cpp', 'diff', 'gitcommit', 'html', 'java',
				'javascript', 'json', 'lua', 'luadoc', 'markdown', 'markdown_inline',
				'php', 'typescript', 'vim', 'vimdoc', 'vue', 'yaml',
			})

			-- Temporary use JS highlighting for bla files as it is similar enough
			vim.treesitter.language.register('javascript', 'bla')

			-- Highlighting + Indent for every filetype for which a parser exists
			vim.api.nvim_create_autocmd('FileType', {
				callback = function(args)
					if pcall(vim.treesitter.start, args.buf) then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
}
