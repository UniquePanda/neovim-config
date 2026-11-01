-- # Auto completion + snippets
-- Custom snippets: lua/snippets/init.lua
return {
	{
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			-- Auto completion parameter name hints while typing function
			'hrsh7th/cmp-nvim-lsp-signature-help',
			{
				'L3MON4D3/LuaSnip', -- Snippet engine for snippets in different programming languages
				build = 'make install_jsregexp',
			},
			'saadparwaiz1/cmp_luasnip',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-path',
		},
		config = function()
			local cmp = require('cmp')
			local luasnip = require('luasnip')
			luasnip.config.setup({})
			-- Use Javascript snippets in Typescript files
			luasnip.filetype_extend('typescript', { 'javascript' })
			-- Use Javascript snippets in Vue files
			luasnip.filetype_extend('vue', { 'javascript' })

			require('snippets')

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = 'menu,menuone,noinsert' },
				mapping = cmp.mapping.preset.insert({
					['<Tab>'] = cmp.mapping.select_next_item(),
					['<S-Tab>'] = cmp.mapping.select_prev_item(),
					['<CR>'] = function(fallback)
						if luasnip.expandable() then
							luasnip.expand()
						elseif not cmp.visible() or not cmp.get_selected_entry() or cmp.get_selected_entry().source.name == 'nvim_lsp_signature_help' then
							fallback() -- normal enter (probably just adds a line break in current buffer)
						else
							cmp.confirm({ select = true })
						end
					end,

					['<PageUp>'] = cmp.mapping.scroll_docs(-4),
					['<PageDown>'] = cmp.mapping.scroll_docs(4),

					['<C-Space>'] = cmp.mapping.complete({}),

					-- Move to next snippet expansion location
					['<C-l>'] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { 'i', 's' }),

					-- Move to previous snippet expansion location
					['<C-h>'] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { 'i', 's' }),
				}),
				sources = {
					{ name = 'luasnip' },
					{ name = 'nvim_lsp' },
					{ name = 'path' },
					{ name = 'nvim_lsp_signature_help' },
				},
			})
		end,
	},
}
