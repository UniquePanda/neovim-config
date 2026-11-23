-- Local workarounds for codecompanion-history.nvim (upstream is inactive).
--
-- 1. Restored chats fell back to Copilot's "Auto" model: the extension passes only the adapter *name* to
--    `Chat.new`, so the adapter is resolved with its schema default (`auto`). Copilot then strips the model
--    from the request, even though `settings.model` holds the saved one. We resolve the adapter with the
--    saved model up front.
-- 2. A restore that errors half-way leaves a broken chat registered under the saved `save_id`. Re-selecting
--    it just re-opens that broken instance (blank window) until Neovim restarts. We catch restore errors,
--    clean up the half-built chat, and also drop stale chats (wiped buffers) before looking up open chats.
local M = {}

---@param save_id string|nil
local function close_chats_with_save_id(save_id)
	if not save_id then
		return
	end
	for _, data in ipairs(require('codecompanion.interactions.chat').buf_get_chat()) do
		if data.chat.opts and data.chat.opts.save_id == save_id then
			pcall(data.chat.close, data.chat)
		end
	end
end

--- Close chats whose buffer no longer exists, so they can't be "re-opened" as a blank window
local function close_stale_chats()
	for _, data in ipairs(require('codecompanion.interactions.chat').buf_get_chat()) do
		local chat = data.chat
		if not (chat.bufnr and vim.api.nvim_buf_is_valid(chat.bufnr)) or not chat.ui then
			pcall(chat.close, chat)
		end
	end
end

function M.setup()
	local ok, UI = pcall(require, 'codecompanion._extensions.history.ui')
	if not ok or UI._local_fixes_applied then
		return
	end
	UI._local_fixes_applied = true

	local original_create_chat = UI.create_chat
	local original_handle_on_select = UI._handle_on_select

	function UI:create_chat(chat_data)
		chat_data = chat_data or {}
		local adapter = chat_data.adapter
		local model = chat_data.settings and chat_data.settings.model

		-- Fix 1: hand over an adapter already resolved with the saved model
		if type(adapter) == 'string' and type(model) == 'string' and model ~= '' then
			local adapters = require('codecompanion.adapters')
			local resolved_ok, resolved = pcall(adapters.resolve, adapter, { model = model })
			if resolved_ok and resolved and resolved.type == 'http' then
				chat_data.adapter = resolved
			end
		end

		-- Fix 2: never leave a half-initialised chat behind
		local success, result = xpcall(original_create_chat, debug.traceback, self, chat_data)
		if not success then
			close_chats_with_save_id(chat_data.save_id)
			vim.notify('[codecompanion-history] Failed to restore chat:\n' .. tostring(result), vim.log.levels.ERROR)
			return nil
		end
		return result
	end

	function UI:_handle_on_select(save_id)
		close_stale_chats()
		return original_handle_on_select(self, save_id)
	end
end

return M
