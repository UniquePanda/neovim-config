return {
  diff_develop = function(args)
	return vim.fn.system('git diff --merge-base origin/develop')
  end,
}
