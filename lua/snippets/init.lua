-- # SNIPPETS (via LuaSnip)
-- Loaded from the nvim-cmp config in lua/plugins/completion.lua
local ls = require('luasnip')
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

-- C# Snippets
ls.add_snippets('cs', {
	s('log', { t('Debug.Log('), i(1), t(');') }),
})

-- C++ Snippets
ls.add_snippets('cpp', {
	s('log', { t('std::cout << '), i(1), t(' << std::endl;') }),
})

-- JS Snippets (also used in TypeScript and Vue files)
ls.add_snippets('javascript', {
	s('log', { t('console.log('), i(1), t(');') }),
})

-- PHP Snippets
ls.add_snippets('php', {
	s('log', { t('\\Log::info('), i(1), t(');') }),
	s('logj', { t('\\Log::info(json_encode('), i(1), t(', JSON_PRETTY_PRINT));') }),
})
