-- Keep CodeCompanion chat windows from being taken over by other buffers.
-- If a file/buffer is opened inside a chat window (e.g. via Oil or a buffer picker), the chat is put back
-- into its window and the new buffer is moved to a regular editor window instead (created if necessary).
local M = {}

local chat_filetypes = {
	codecompanion = true,
	codecompanion_chat_input = true,
}

local function is_float(win)
	return vim.api.nvim_win_get_config(win).relative ~= ''
end

---Whether a buffer belongs to CodeCompanion (chat or its input), even if its filetype isn't set yet
---@param buf integer
---@return boolean
local function is_chat_buf(buf)
	if chat_filetypes[vim.bo[buf].filetype] then
		return true
	end
	if vim.tbl_contains(_G.codecompanion_buffers or {}, buf) then
		return true
	end
	local ok, chat = pcall(function()
		return require('codecompanion.interactions.chat').buf_get_chat(buf)
	end)
	return ok and chat ~= nil
end

local function is_chat_win(win)
	return vim.w[win].codecompanion_bufnr ~= nil
end

---Find a regular window to show the "stray" buffer in, preferring the previously active one
---@param chat_win integer
---@return integer|nil
local function find_target_win(chat_win)
	local prev = vim.fn.win_getid(vim.fn.winnr('#'))
	if prev ~= 0 and prev ~= chat_win and not is_float(prev) and not is_chat_win(prev) then
		return prev
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if win ~= chat_win and not is_float(win) and not is_chat_win(win) then
			return win
		end
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup('CodeCompanionStickyChatWindow', { clear = true })
	local busy = false

	-- The chat buffer may get its filetype only after it is shown in its window
	vim.api.nvim_create_autocmd('FileType', {
		group = group,
		pattern = vim.tbl_keys(chat_filetypes),
		callback = function(args)
			for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
				if not is_float(win) then
					vim.w[win].codecompanion_bufnr = args.buf
				end
			end
		end,
	})

	vim.api.nvim_create_autocmd('BufWinEnter', {
		group = group,
		callback = function(args)
			if busy then
				return
			end
			local win = vim.api.nvim_get_current_win()
			if vim.api.nvim_win_get_buf(win) ~= args.buf or is_float(win) then
				return
			end

			-- Remember which chat buffer belongs to this window
			if is_chat_buf(args.buf) then
				vim.w[win].codecompanion_bufnr = args.buf
				return
			end

			local chat_buf = vim.w[win].codecompanion_bufnr
			if not chat_buf then
				return
			end
			if not vim.api.nvim_buf_is_valid(chat_buf) then
				vim.w[win].codecompanion_bufnr = nil
				return
			end

			local stray_buf = args.buf
			vim.schedule(function()
				if busy or not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= stray_buf then
					return
				end
				-- A chat (e.g. restored from history) may only be recognisable once it's fully set up
				if is_chat_buf(stray_buf) then
					vim.w[win].codecompanion_bufnr = stray_buf
					return
				end
				busy = true
				local ok, err = pcall(function()
					local view = vim.fn.winsaveview()
					local target = find_target_win(win)
					-- Put the chat back where it was
					vim.api.nvim_win_set_buf(win, chat_buf)
					pcall(vim.fn.winrestview, view)
					-- Show the opened buffer in a regular window
					if target then
						vim.api.nvim_win_set_buf(target, stray_buf)
						vim.api.nvim_set_current_win(target)
					else
						vim.api.nvim_open_win(stray_buf, true, { split = 'left', win = win })
					end
				end)
				busy = false
				if not ok then
					vim.notify('[codecompanion] Could not restore chat window: ' .. tostring(err), vim.log.levels.WARN)
				end
			end)
		end,
	})
end

return M
