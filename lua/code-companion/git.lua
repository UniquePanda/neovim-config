local M = {}

---The branch checked out in the current working directory, or nil outside a git repo or on a detached HEAD
---@return string|nil
function M.current_branch()
	local result = vim.system({ 'git', 'branch', '--show-current' }, { cwd = vim.fn.getcwd(), text = true }):wait()
	local branch = result.code == 0 and vim.trim(result.stdout or '') or ''
	return branch ~= '' and branch or nil
end

---The title with the current branch appended, unless the title already mentions it
---@param title string
---@return string
function M.title_with_branch(title)
	local branch = M.current_branch()
	if not branch or title:find(branch, 1, true) then
		return title
	end
	return string.format('%s · %s', title, branch)
end

return M
