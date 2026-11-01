-- # Debugging (Debug Adapter Protocol: breakpoints etc.)
return {
	{
		'mfussenegger/nvim-dap',
		config = function()
			local dap = require('dap')
			local dap_widgets = require('dap.ui.widgets')

			-- C++
			dap.adapters.cppdbg = {
				id = 'cppdbg',
				type = 'executable',
				command = '/opt/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
			}
			dap.configurations.cpp = {
				{
					name = 'Launch file',
					type = 'cppdbg',
					request = 'launch',
					program = function()
						vim.fn.system('cmake --build ./build')
						return vim.fn.input('Executable: ', '${workspaceFolder}/build/', 'file')
					end,
					args = function()
						return vim.fn.split(vim.fn.input('Program arguments: '))
					end,
					cwd = function()
						return vim.fn.input('Working directory: ', '${workspaceFolder}/build', 'file')
					end,
					stopAtEntry = false,
				},
			}

			-- Keybinds
			vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
			vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Start/Continue execution (debugging)' })
			vim.keymap.set('n', '<leader><F5>', dap.run_last, { desc = 'Start execution of last debug session' })
			vim.keymap.set('n', '<F6>', dap.step_into, { desc = 'Step into function' })
			vim.keymap.set('n', '<F7>', dap.step_over, { desc = 'Step over function' })
			vim.keymap.set('n', '<F8>', dap_widgets.hover, { desc = 'Hover debug info' })
			vim.keymap.set('n', '<F9>', function() dap_widgets.centered_float(dap_widgets.frames) end, { desc = 'Show current stack frames' })
			vim.keymap.set('n', '<F10>', function() dap_widgets.centered_float(dap_widgets.scopes) end, { desc = 'Show variables in current scopes' })
			vim.keymap.set('n', '<F12>', dap.repl.open, { desc = 'Open debug REPL' })
		end,
	},
}
