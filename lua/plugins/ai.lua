-- # AI (Copilot + CodeCompanion)
-- Custom CodeCompanion context: lua/code-companion/, prompts: code-companion/prompts/
return {
	{
		'zbirenbaum/copilot.lua',
		cmd = 'Copilot',
		build = ':Copilot auth',
		event = 'InsertEnter',
		opts = {
			server = {
				type = 'nodejs',
			},
			suggestion = {
				auto_trigger = true,
				keymap = {
					accept = '<M-l>',
					accept_word = '<M-S-l>',
					dismiss = '<M-h>',
					next = '<M-k>',
					prev = '<M-j>',
				},
			},
			nes = {
				enabled = false,
			},
			server_opts_override = {
				settings = {
					advanced = {
						inlineSuggestCount = 5,
					},
				},
			},
		},
	},
	{
		'olimorris/codecompanion.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-treesitter/nvim-treesitter',
			'ravitemer/codecompanion-history.nvim',
		},
		config = function()
			local config_dir = vim.fn.stdpath('config')

			require('codecompanion').setup({
				adapters = {
					http = {
						tavily = function()
							return require('codecompanion.adapters').extend('tavily', {
								env = {
									api_key = 'cmd:echo -n "$(cat ~/.apis/tavily.md)"',
								},
							})
						end,
					},
				},
				interactions = {
					chat = {
						adapter = {
							name = 'copilot',
							model = 'claude-opus-5.5',
						},
						editor_context = {
							['diff_to_develop'] = {
								path = 'code-companion.editor_context.diff_to_develop',
								description = 'Add the current git diff (compared to origin/develop) to the chat.',
								opts = {
									contains_code = true,
								},
							},
						},
						tools = {
							['file_search'] = {
								opts = {
									max_results = 3000,
								},
							},
						},
					},
				},
				prompt_library = {
					markdown = {
						dirs = {
							config_dir .. '/code-companion/prompts/',
						},
					},
				},
				extensions = {
					history = {
						enabled = true,
						opts = {
							chat_filter = function(chat_data)
								return chat_data.cwd == vim.fn.getcwd()
							end,
							title_generation_opts = {
								adapter = 'copilot',
								model = 'claude-opus-5.5',
								refresh_every_n_prompts = 2,
								max_refreshes = 3,
							},
							keymap = '<leader>chb',
							summary = {
								create_summary_keymap = '<leader>csc',
								browse_summaries_keymap = '<leader>csb',
							},
						},
					},
				},
			})

			vim.keymap.set('n', '<leader>cc', '<cmd>CodeCompanionChat<cr>', { desc = 'Open Code Companion Chat' })
		end,
	},
	{
		-- Used to add images to LLM context in CodeCompanion.
		'HakonHarnes/img-clip.nvim',
		opts = {
			default = {
				drag_and_drop = { enabled = false },
			},
			filetypes = {
				codecompanion = {
					prompt_for_file_name = false,
					template = '[Image]($FILE_PATH)',
					use_absolute_path = true,
				},
			},
		},
	},
}
