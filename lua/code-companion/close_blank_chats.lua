-- Automatically close blank CodeCompanion chats when another chat is created (new or restored from history),
-- so they don't pile up and show up when cycling chats.
-- A chat counts as blank when it has no user message with content, no running request and nothing typed
-- into its input.
local M = {}

---@param chat CodeCompanion.Chat
---@return boolean
local function is_blank(chat)
	if chat.current_request then
		return false
	end
	for _, msg in ipairs(chat.messages or {}) do
		if msg.role == 'user' and type(msg.content) == 'string' and vim.trim(msg.content) ~= '' then
			return false
		end
	end
	local input = chat.ui and chat.ui.input
	if input and input.bufnr and vim.api.nvim_buf_is_valid(input.bufnr) then
		local ok, prompt = pcall(input.get_prompt, input)
		if ok and prompt ~= '' then
			return false
		end
	end
	return true
end

function M.setup()
	local group = vim.api.nvim_create_augroup('CodeCompanionCloseBlankChats', { clear = true })
	vim.api.nvim_create_autocmd('User', {
		group = group,
		pattern = 'CodeCompanionChatCreated',
		-- Scheduled so the new chat (and a history restore) has finished setting itself up
		callback = vim.schedule_wrap(function(args)
			local new_bufnr = args.data and args.data.bufnr
			local chat_module = require('codecompanion.interactions.chat')
			for _, data in ipairs(chat_module.buf_get_chat()) do
				local chat = data.chat
				if chat.bufnr ~= new_bufnr and not chat.hidden and is_blank(chat) then
					pcall(chat.close, chat)
				end
			end
		end),
	})
end

return M
