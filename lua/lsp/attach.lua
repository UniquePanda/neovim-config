-- # LSP ATTACH
-- Called everytime an LSP is attached to a file (everytime a file with a recognized extension is opened)

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(event)
		local keymap = function(keys, func, desc)
			vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
		end

		local telescope = require('telescope.builtin')
		keymap('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
		keymap('gr', telescope.lsp_references, '[G]oto [R]eferences')
		keymap('gm', telescope.lsp_implementations, '[G]oto I[m]plementation')
		keymap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
		keymap('<leader><cr>', vim.lsp.buf.code_action, 'Code Action (suggestions etc.)')
		keymap('<leader>h', vim.lsp.buf.hover, 'Show documentation (hover)')
		keymap('<leader>dh', vim.diagnostic.open_float, 'Show diagnostics [h]int')
		keymap('<leader>dS', '<cmd>LspStop<cr>', 'Kill (stop) LSP')
		keymap('<leader>ds', '<cmd>LspStart<cr>', 'Start LSP')
		keymap('<leader>dk', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Go to previous diagnostics location')
		keymap('<leader>dj', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Go to next diagnostics location')

		-- Autocommands to highlight the word under the cursor (and clear highlight on cursor move)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.server_capabilities.documentHighlightProvider then
			local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
			vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
				group = highlight_augroup,
				buffer = event.buf,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
				group = highlight_augroup,
				buffer = event.buf,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd('LspDetach', {
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event2.buf })
				end,
			})
		end

		-- Disable inlay hints by default and add toggle
		if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
			vim.lsp.inlay_hint.enable(false)
			keymap(
				'<leader>di',
				function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
				end,
				'Toggle [I]nlay Hints'
			)
		end
	end,
})
