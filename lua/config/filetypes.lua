-- # CUSTOM FILETYPES

vim.filetype.add({
	pattern = {
		['.*%.blade%.php'] = 'blade',
		-- File type for my own programming language 'blast'
		['.*%.bla'] = 'bla',
	},
})

-- Cyberpunk 2077 Redscript files (Swift syntax highlighting is close enough)
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
	group = vim.api.nvim_create_augroup('RedscriptFile', { clear = true }),
	pattern = '*.reds',
	callback = function()
		vim.bo.filetype = 'reds'
		vim.bo.syntax = 'swift'
	end,
})
