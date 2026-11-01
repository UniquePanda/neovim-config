-- # LSP
-- Server list: lua/lsp/servers.lua
-- Keymaps + autocommands on attach: lua/lsp/attach.lua
return {
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			'mason-org/mason.nvim', -- Package manager for LSPs
			'mason-org/mason-lspconfig.nvim', -- Connect mason with lspconfig
			'WhoIsSethDaniel/mason-tool-installer.nvim', -- Easier installation/updating of mason tools
			'j-hui/fidget.nvim', -- Status updates for LSP
		},
		config = function()
			require('lsp.attach')

			-- Merge capabilities of plugins into the default neovim capabilities list
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

			local servers = require('lsp.servers')
			local ensure_installed_servers = vim.tbl_keys(servers)

			-- Setup mason to automatically install the servers and tools
			require('mason').setup()
			require('mason-tool-installer').setup({
				ensure_installed = { 'ansible-lint', 'cspell', 'jdtls', 'markdownlint', unpack(ensure_installed_servers) },
			})
			require('mason-lspconfig').setup({
				ensure_installed = ensure_installed_servers,
			})

			for server_name, server in pairs(servers) do
				server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
				vim.lsp.config(server_name, server)
				vim.lsp.enable(server_name)
			end

			-- Cyberpunk 2077 Redscript files (not installed via Mason)
			vim.lsp.config('redscript_ide', {
				cmd = { '/usr/bin/redscript-ide' },
				filetypes = { 'reds', 'script' },
				init_options = {
					game_dir = '/mnt/c/Program Files (x86)/GOG Galaxy/Games/Cyberpunk 2077',
				},
				root_markers = { '.git' },
			})
			vim.lsp.enable('redscript_ide')
		end,
	},
	{
		-- Java LSP (jdtls) integration (setup happens in ftplugin/java.lua)
		'mfussenegger/nvim-jdtls',
		ft = 'java',
	},
}
