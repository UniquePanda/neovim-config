-- One chat slash command per skill found in `skills.dirs` (e.g. `/tdd`, `/code-review`).
-- The list is rebuilt whenever a chat is created or opened, so each project only shows its own skills.
-- Running a command adds that skill to the chat's context, plus every skill it hands off to
-- ("call the Skill tool with `X`"), since CodeCompanion has no Skill tool to follow those itself.
-- Relies on CodeCompanion internals: `codecompanion.skills` and the live config table.
local M = {}

---Names of the slash commands this module registered, so a refresh can remove them again
---@type table<string, boolean>
local registered = {}

---Names of the skills a SKILL.md hands off to
---@param path string
---@return string[]
local function find_handoffs(path)
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok then
		return {}
	end

	local names = {}
	for name in table.concat(lines, '\n'):gmatch('Skill tool with ["`]([%w%-]+)["`]') do
		table.insert(names, name)
	end
	return names
end

---The skill and, recursively, every skill it hands off to
---@param skill CodeCompanion.Skill
---@param skills_by_name table<string, CodeCompanion.Skill>
---@param result? CodeCompanion.Skill[]
---@param seen? table<string, boolean>
---@return CodeCompanion.Skill[]
local function with_handoffs(skill, skills_by_name, result, seen)
	result = result or {}
	seen = seen or {}
	if seen[skill.name] then
		return result
	end

	seen[skill.name] = true
	table.insert(result, skill)
	for _, name in ipairs(find_handoffs(skill.path)) do
		if skills_by_name[name] then
			with_handoffs(skills_by_name[name], skills_by_name, result, seen)
		end
	end
	return result
end

function M.refresh()
	local skills = require('codecompanion.skills')
	local slash_commands = require('codecompanion.config').interactions.chat.slash_commands

	for name in pairs(registered) do
		slash_commands[name] = nil
	end
	registered = {}

	local skills_by_name = {}
	for _, skill in ipairs(skills.list()) do
		skills_by_name[skill.name] = skill
	end

	for name, skill in pairs(skills_by_name) do
		-- Never replace a built-in or user-defined slash command of the same name
		if slash_commands[name] == nil then
			slash_commands[name] = {
				description = 'Skill: ' .. skill.description,
				---@param chat CodeCompanion.Chat
				callback = function(chat)
					if not skills.available_for(chat) then
						return vim.notify(
							'Skills need an HTTP adapter with tools enabled',
							vim.log.levels.WARN,
							{ title = 'CodeCompanion' }
						)
					end
					skills.add_to_chat(chat, with_handoffs(skill, skills_by_name))
				end,
				opts = {
					contains_code = false,
				},
			}
			registered[name] = true
		end
	end
end

function M.setup()
	M.refresh()
	vim.api.nvim_create_autocmd('User', {
		pattern = { 'CodeCompanionChatCreated', 'CodeCompanionChatOpened' },
		group = vim.api.nvim_create_augroup('CodeCompanionSkillSlashCommands', { clear = true }),
		callback = M.refresh,
	})
end

return M
