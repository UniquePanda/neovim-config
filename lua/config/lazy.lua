-- # PLUGIN MANAGER (lazy.nvim)
-- Every file in lua/plugins/ returns a list of plugin specs and is imported automatically.

local lazy_path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazy_path) then
	print('Installing lazy.nvim...')
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable',
		lazy_path,
	})
	print('Installed lazy.nvim')
end

vim.opt.rtp:prepend(lazy_path)

require('lazy').setup({
	spec = {
		{ import = 'plugins' },
	},
})
