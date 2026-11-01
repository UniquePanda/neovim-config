-- # LANGUAGE SERVERS
-- Every server listed here is installed via Mason and enabled automatically (see lua/plugins/lsp.lua).

local mason_packages = vim.fn.stdpath('data') .. '/mason/packages'
local volar_path = mason_packages .. '/vue-language-server/node_modules/@vue/language-server'

return {
	ansiblels = { -- ansible
		filetypes = { 'yaml', 'yaml.ansible' },
		settings = {
			ansible = {
				-- Use the venv of Mason's ansible-lint, which also contains ansible-core (ansible-config etc.)
				python = {
					interpreterPath = mason_packages .. '/ansible-lint/venv/bin/python',
				},
			},
		},
	},
	bashls = {}, -- bash
	clangd = {}, -- c++
	eslint = {}, -- linting for javascript/typescript
	html = {}, -- html
	intelephense = {}, -- php
	jsonls = {}, -- json
	lua_ls = { -- lua
		settings = {
			Lua = {
				completion = {
					callSnippet = 'Replace',
				},
				diagnostics = {
					globals = { 'vim' },
				},
			},
		},
	},
	marksman = {}, -- markdown
	oxlint = {}, -- linting for javascript/typescript
	ts_ls = { -- typescript + some stuff for Vue support
		filetypes = { 'javascript', 'typescript', 'vue' },
		init_options = {
			plugins = {
				{
					name = '@vue/typescript-plugin',
					location = volar_path,
					languages = { 'vue' },
				},
			},
		},
		settings = {
			typescript = {
				tsserver = {
					useSyntaxServer = false,
				},
				inlayHints = {
					includeInlayParameterNameHints = 'all',
					includeInlayParameterNameHintsWhenArgumentMatchesName = true,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayVariableTypeHintsWhenTypeMatchesName = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
		},
	},
	vue_ls = { -- vuejs
		init_options = {
			vue = {
				hybridMode = true,
			},
		},
	},
	-- roslyn_ls = {},
	stylua = {},
	tailwindcss = {
		root_dir = function(bufnr, on_dir)
			-- Tailwind v3 has its own config file
			local root = vim.fs.root(bufnr, {
				'tailwind.config.js', 'tailwind.config.cjs', 'tailwind.config.mjs', 'tailwind.config.ts',
			})
			if root then
				return on_dir(root)
			end

			-- Tailwind v4 doesn't have its own config file, so we need to check the package.json
			local pkg = vim.fs.find('package.json', {
				upward = true,
				path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
			})[1]
			if pkg and table.concat(vim.fn.readfile(pkg), '\n'):find('"tailwindcss"', 1, true) then
				on_dir(vim.fs.dirname(pkg))
			end
		end,
	},
}
