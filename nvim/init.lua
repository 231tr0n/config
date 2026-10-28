-- Globals declaration
-- luacheck: globals vim
-- luacheck: globals G Unmap Map Tmap Cmap Nmap Vmap Imap Smap Xmap Hi
-- luacheck: globals MiniPick MiniBracketed MiniIcons MiniMisc MiniCompletion MiniTrailspace
-- luacheck: globals MiniMap MiniStatusline MiniSnippets MiniExtra MiniFiles

-- Vim pack mini.misc setup
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })
require("mini.misc").setup()

-- Helper functions
Unmap = function(modes, suffix, opts)
	vim.keymap.del(modes, suffix, opts or {})
end
Map = function(modes, suffix, rhs, desc, opts)
	opts = opts or {}
	opts.silent = opts.silent ~= false
	opts.desc = desc
	vim.keymap.set(modes, suffix, rhs, opts)
end
Tmap = function(suffix, rhs, desc, opts)
	Map("t", suffix, rhs, desc, opts)
end
Cmap = function(suffix, rhs, desc, opts)
	Map("c", suffix, rhs, desc, opts)
end
Nmap = function(suffix, rhs, desc, opts)
	Map("n", suffix, rhs, desc, opts)
end
Vmap = function(suffix, rhs, desc, opts)
	Map("v", suffix, rhs, desc, opts)
end
Imap = function(suffix, rhs, desc, opts)
	Map("i", suffix, rhs, desc, opts)
end
Smap = function(suffix, rhs, desc, opts)
	Map("s", suffix, rhs, desc, opts)
end
Xmap = function(suffix, rhs, desc, opts)
	Map("x", suffix, rhs, desc, opts)
end
Hi = function(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

-- Global state
MiniMisc.safely("now", function()
	G = {
		recent_keys = {},
		terminal_win = nil,
		float_terminal_win = nil,
		offset_encoding = "utf-16",
		case_style = "snake",
		lsp_get_client = function(name, bufnr, all)
			local clients = vim.lsp.get_clients({ name = name, bufnr = bufnr })
			if #clients == 0 then
				vim.notify(("%s client not found"):format(name or "LSP"), vim.log.levels.WARN)
				return
			end
			return all and clients or clients[1]
		end,
		coroutine_wrap = function(fn)
			local _, is_main = coroutine.running()
			if not is_main then
				fn()
				return
			end
			coroutine.wrap(function()
				xpcall(fn, function(err)
					vim.notify(debug.traceback(err, 2), vim.log.levels.ERROR)
				end)
			end)()
		end,
		lsp_client_exec_cmd = function(client, command, bufnr, handler)
			local co
			if not handler then
				co = coroutine.running()
				if co then
					handler = function(err, result, ctx)
						coroutine.resume(co, err, result, ctx)
					end
				end
			end
			client:exec_cmd(command, bufnr and { bufnr = bufnr } or nil, handler)
			if co then
				return coroutine.yield()
			end
		end,
		lsp_client_request = function(client, method, params, bufnr, handler)
			local co
			if not handler then
				co = coroutine.running()
				if co then
					handler = function(err, result, ctx)
						coroutine.resume(co, err, result, ctx)
					end
				end
			end
			client:request(method, params, handler, bufnr)
			if co then
				return coroutine.yield()
			end
		end,
		multi_select = function(prompt, options, format)
			local choices = {}
			local value_by_choice = {}
			for _, value in pairs(options) do
				local choice = format(value)
				choices[#choices + 1] = choice
				value_by_choice[choice] = value
			end
			local selected = {}
			MiniPick.start({
				source = {
					items = choices,
					name = prompt,
					choose_marked = function(items)
						selected = vim.tbl_map(function(choice)
							return value_by_choice[choice]
						end, items)
						return false
					end,
					choose = function(choice)
						selected = { value_by_choice[choice] }
						return false
					end,
				},
			})
			return selected
		end,
	}
end)

-- Default settings
MiniMisc.safely("now", function()
	vim.cmd("packadd cfilter")
	vim.cmd("packadd justify")
	vim.cmd("packadd nohlsearch")
	vim.cmd("packadd nvim.difftool")
	vim.cmd("packadd nvim.undotree")
	vim.g.loaded_gzip = 1
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
	vim.g.loaded_spellfile_plugin = 1
	vim.g.loaded_tar = 1
	vim.g.loaded_tarPlugin = 1
	vim.g.loaded_zip = 1
	vim.g.loaded_zipPlugin = 1
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "
	vim.o.background = "dark"
	vim.o.breakindent = true
	vim.o.cmdheight = 0
	vim.o.completeopt = "menuone,noselect,fuzzy"
	vim.o.conceallevel = 2
	vim.o.cursorcolumn = false
	vim.o.cursorline = true
	vim.o.fillchars = "eob: ,foldinner: ,foldsep: ,foldopen:,foldclose:"
	vim.o.foldcolumn = "1"
	vim.o.foldenable = true
	vim.o.foldlevel = 99
	vim.o.foldlevelstart = 99
	vim.o.foldmethod = "indent"
	vim.o.hlsearch = true
	vim.o.ignorecase = true
	vim.o.incsearch = true
	vim.o.laststatus = 3
	vim.o.list = true
	vim.o.listchars = "tab:󰮺 ,leadmultispace:· ,trail:·,nbsp:⦸,eol:¬"
	vim.o.matchpairs = vim.o.matchpairs .. ",<:>"
	vim.o.maxmempattern = 10000
	vim.o.number = true
	vim.o.path = "**"
	vim.o.pumblend = 0
	vim.o.scrolloff = 999
	vim.o.shiftwidth = 2
	vim.o.shortmess = "aoOtTcCF"
	vim.o.showcmd = true
	vim.o.showcmdloc = "statusline"
	vim.o.showmatch = true
	vim.o.showmode = true
	vim.o.signcolumn = "yes:1"
	vim.o.smartcase = true
	vim.o.synmaxcol = 10000
	vim.o.tabstop = 2
	vim.o.termguicolors = true
	vim.o.textwidth = 0
	vim.o.undofile = false
	vim.o.wildignore = "*/.git/*"
	vim.o.wildmenu = true
	vim.o.wildmode = "noselect,full"
	vim.o.wildoptions = "pum,fuzzy"
	vim.o.winblend = 0
	vim.o.winborder = "rounded"
	vim.o.wrap = false
	vim.lsp.inline_completion.enable(true)
	-- vim.lsp.codelens.enable(true)
	vim.diagnostic.config({
		virtual_text = true,
		virtual_lines = false,
		float = false,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "",
				[vim.diagnostic.severity.HINT] = "",
				[vim.diagnostic.severity.INFO] = "",
				[vim.diagnostic.severity.WARN] = "",
			},
		},
		underline = false,
		severity_sort = true,
	})
	vim.o.pumborder = "rounded"
	require("vim._core.ui2").enable({
		msg = {
			targets = "cmd",
		},
	})
end)

-- Mini plugins setup
MiniMisc.safely("now", function()
	local subword_patterns = {
		"%f[%a]%l+%d*",
		"%f[%w]%d+",
		"%u%l+%d*",
		"%f[%a]%u+%f[^%a]",
		"%f[%u]()()%u+()()%u%l",
	}
	require("mini.ai").setup({
		custom_textobjects = {
			B = require("mini.extra").gen_ai_spec.buffer(),
			D = require("mini.extra").gen_ai_spec.diagnostic(),
			e = { subword_patterns },
			I = require("mini.extra").gen_ai_spec.indent(),
			L = require("mini.extra").gen_ai_spec.line(),
			N = require("mini.extra").gen_ai_spec.number(),
			t = { "<([%p%w]-)%f[^%w][^<>]->.-</%1%s->", "^<.->().*()</.->$" },
		},
	})
	require("mini.align").setup()
	require("mini.animate").setup()
	require("mini.basics").setup({
		options = {
			extra_ui = true,
		},
		mappings = {
			windows = true,
			move_with_alt = true,
		},
		autocommands = {
			relnum_in_visual_mode = true,
		},
	})
	require("mini.bracketed").setup()
	require("mini.bufremove").setup()
	require("mini.clue").setup({
		triggers = {
			{ mode = "c", keys = "<C-r>" },
			{ mode = "i", keys = "<C-r>" },
			{ mode = "i", keys = "<C-x>" },
			{ mode = "n", keys = "'" },
			{ mode = "n", keys = "<C-w>" },
			{ mode = "n", keys = "<leader>" },
			{ mode = "n", keys = "[" },
			{ mode = "n", keys = "\\" },
			{ mode = "n", keys = "]" },
			{ mode = "n", keys = "`" },
			{ mode = "n", keys = "g" },
			{ mode = "n", keys = "z" },
			{ mode = "n", keys = '"' },
			{ mode = "x", keys = "'" },
			{ mode = "x", keys = "<leader>" },
			{ mode = "x", keys = "[" },
			{ mode = "x", keys = "]" },
			{ mode = "x", keys = "`" },
			{ mode = "x", keys = "g" },
			{ mode = "x", keys = "z" },
			{ mode = "x", keys = '"' },
		},
		clues = {
			{
				{ mode = "n", keys = "<leader>a", desc = "+Ai" },
				{ mode = "n", keys = "<leader>b", desc = "+Buffer" },
				{ mode = "n", keys = "<leader>d", desc = "+Debug" },
				{ mode = "n", keys = "<leader>e", desc = "+Explorer" },
				{ mode = "n", keys = "<leader>f", desc = "+Find" },
				{ mode = "n", keys = "<leader>l", desc = "+Lsp" },
				{ mode = "n", keys = "<leader>m", desc = "+Map" },
				{ mode = "n", keys = "<leader>q", desc = "+QuickFix" },
				{ mode = "n", keys = "<leader>w", desc = "+Window" },
			},
			require("mini.clue").gen_clues.builtin_completion(),
			require("mini.clue").gen_clues.g(),
			require("mini.clue").gen_clues.marks(),
			require("mini.clue").gen_clues.registers(),
			require("mini.clue").gen_clues.square_brackets(),
			require("mini.clue").gen_clues.windows(),
			require("mini.clue").gen_clues.z(),
		},
		window = {
			delay = 0,
		},
	})
	require("mini.cmdline").setup()
	require("mini.comment").setup()
	require("mini.completion").setup()
	require("mini.cursorword").setup()
	require("mini.diff").setup()
	require("mini.extra").setup()
	require("mini.files").setup({
		mappings = {
			go_in = "L",
			go_in_plus = "l",
			go_out = "H",
			go_out_plus = "h",
		},
		options = {
			permanent_delete = true,
			use_as_default_explorer = true,
		},
	})
	require("mini.git").setup()
	require("mini.hipatterns").setup({
		highlighters = {
			fixme = require("mini.extra").gen_highlighter.words({ "FIXME" }, "MiniHipatternsFixme"),
			hack = require("mini.extra").gen_highlighter.words({ "HACK" }, "MiniHipatternsHack"),
			todo = require("mini.extra").gen_highlighter.words({ "TODO" }, "MiniHipatternsTodo"),
			note = require("mini.extra").gen_highlighter.words({ "NOTE" }, "MiniHipatternsNote"),
			test = require("mini.extra").gen_highlighter.words({ "TEST" }, "MiniHipatternsNote"),
			hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
		},
	})
	require("mini.icons").setup()
	MiniIcons.mock_nvim_web_devicons()
	MiniIcons.tweak_lsp_kind()
	require("mini.indentscope").setup({
		options = {
			try_as_border = true,
		},
	})
	require("mini.input").setup({
		handlers = {
			view = require("mini.input").gen_view.floatwin({ scope = "tabpage", style = "MM" }),
		},
	})
	require("mini.jump").setup()
	local jump2d = require("mini.jump2d")
	local subword_spotters = vim.tbl_map(function(pattern)
		return jump2d.gen_spotter.pattern(pattern, "start")
	end, subword_patterns)
	require("mini.jump2d").setup({
		labels = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
		spotter = jump2d.gen_spotter.union(table.unpack(subword_spotters)),
		view = {
			dim = true,
			n_steps_ahead = 2,
		},
		mappings = {
			start_jumping = "",
		},
	})
	require("mini.keymap").setup()
	require("mini.map").setup({
		integrations = {
			require("mini.map").gen_integration.builtin_search(),
			require("mini.map").gen_integration.diff(),
			require("mini.map").gen_integration.diagnostic(),
		},
		symbols = {
			encode = require("mini.map").gen_encode_symbols.dot("4x2"),
		},
		window = {
			focusable = true,
			show_integration_count = true,
			width = 30,
			zindex = 100,
		},
	})
	MiniMisc.setup_restore_cursor()
	MiniMisc.setup_termbg_sync()
	MiniMisc.setup_auto_root({
		"meson.build",
		"CMakeLists.txt",
		"Makefile",
		"go.mod",
		"package.json",
		"pom.xml",
		"build.gradle",
		".git",
	})
	require("mini.move").setup({
		options = {
			reindent_linewise = true,
		},
	})
	local convert_case = function(token)
		local words = vim.split(
			token:gsub("([%l%d])(%u)", "%1 %2"):gsub("(%u)(%u%l)", "%1 %2"):gsub("[^%w]+", " "),
			" ",
			{ trimempty = true }
		)
		for index, word in ipairs(words) do
			word = word:lower()
			if G.case_style == "camel" and index > 1 then
				word = word:sub(1, 1):upper() .. word:sub(2)
			end
			words[index] = word
		end
		return table.concat(words, ({ snake = "_", kebab = "-" })[G.case_style] or "")
	end
	require("mini.operators").setup({
		evaluate = {
			func = function(content)
				for index, line in ipairs(content.lines) do
					content.lines[index] = line:gsub("[%w_%-]+", convert_case)
				end
				return content.lines
			end,
		},
		exchange = { prefix = "ge" },
	})
	require("mini.pairs").setup()
	require("mini.pick").setup({
		mappings = {
			choose_marked = "<C-O>",
			refine_marked = "<C-K>",
		},
		window = {
			config = function()
				local height = math.floor(0.6 * vim.o.lines)
				local width = math.floor(0.6 * vim.o.columns)
				return {
					anchor = "NW",
					height = height,
					width = width,
					row = math.floor(0.5 * (vim.o.lines - height)),
					col = math.floor(0.5 * (vim.o.columns - width)),
				}
			end,
		},
	})
	require("mini.sessions").setup()
	require("mini.snippets").setup({
		snippets = {
			function(ctx)
				local langs = {
					lua = {
						{
							prefix = "if",
							body = { "if ${1:true} then", "\t$0", "end" },
							description = "If statement",
						},
						{
							prefix = "for",
							body = { "for $1 do", "\t$0", "end" },
							description = "For statement",
						},
						{
							prefix = "forn",
							body = { "for ${1:i} = ${2:1}, ${3:10} do", "\t$0", "end" },
							description = "For numeric range statement",
						},
						{
							prefix = "fori",
							body = { "for ${1:i}, ${2:x} in ipairs(${3:t}) do", "\t$0", "end" },
							description = "For loop using ipairs",
						},
						{
							prefix = "forp",
							body = { "for ${1:k}, ${2:v} in pairs(${3:t}) do", "\t$0", "end" },
							description = "For loop using pairs",
						},
						{
							prefix = "fu",
							body = { "function ${1:name}($2)", "\t${0}", "end" },
							description = "Define a function",
						},
						{
							prefix = "f=",
							body = { "${1:name} = function($2)", "\t${0}", "end" },
							description = "Assign a function to a variable",
						},
						{
							prefix = "lfu",
							body = { "local function ${1:name}($2)", "\t${0}", "end" },
							description = "Define a local function",
						},
						{
							prefix = "lf=",
							body = { "local ${1:name} = function($2)", "\t${0}", "end" },
							description = "Assign a function to a local variable",
						},
						{
							prefix = "f)",
							body = { "function($1)", "\t${0}", "end" },
							description = "Create an anonymous function",
						},
						{
							prefix = "f,",
							body = { "${1:name} = function($2)", "\t${0}", "end," },
							description = "Assign a function to a table key",
						},
						{
							prefix = "p",
							body = { "print(${0})" },
							description = "Print statement",
						},
						{
							prefix = "while",
							body = { "while ${1:true} do", "\t$0", "end" },
							description = "While statement",
						},
					},
					svelte = {
						{
							prefix = "if",
							body = "{#if ${1:expression}}\n\t${0}\n{/if}",
							description = "If statement",
						},
						{
							prefix = "each",
							body = "{#each ${1:name} as ${2:name}, ${3:index} (${4:_})}\n\t${0}\n{/each}",
							description = "If statement",
						},
						{
							prefix = "key",
							body = "{#key ${1:expression}}\n\t${0}\n{/key}",
							description = "Key statement",
						},
						{
							prefix = "await",
							body = "{#await ${1:expression}}\n\t${0}\n{/await}",
							description = "Key statement",
						},
						{
							prefix = "snippet",
							body = "{#snippet ${1:expression}}\n\t${0}\n{/snippet}",
							description = "Key statement",
						},
					},
					bash = {
						{
							prefix = "if",
							body = "if [[ ${1:condition} ]]; then\n\t${0}\nfi",
							description = "If statement",
						},
						{
							prefix = "forin",
							body = "for ${1:VAR} in ${2:LIST}\ndo\n\t${0}\ndone\n",
							description = "For loop in list",
						},
						{
							prefix = "fori",
							body = "for ((${1:i} = 0; ${1:i} < ${2:10}; ${1:i}++)); do\n\t${0}\ndone\n",
							description = "An index-based iteration for loop",
						},
						{
							prefix = "while",
							body = "while [[ ${1:condition} ]]; do\n\t${0}\ndone\n",
							description = "While loop by condition",
						},
						{
							prefix = "until",
							body = "until [[ ${1:condition} ]]; do\n\t${0}\ndone\n",
							description = "Until loop by condition",
						},
						{
							prefix = "case",
							body = {
								'case "\\$${1:VAR}" in',
								"\t${2:1}) $\n\t;;\n\t${3:2|3}) ${4}\n\t;;\n\t*) ${0}\n\t;;\nesac\n",
							},
							description = "A case command first expands word, and tries to match it against each pattern in turn.",
						},
					},
				}
				return langs[ctx.lang]
			end,
			require("mini.snippets").gen_loader.from_lang(),
		},
	})
	MiniSnippets.start_lsp_server()
	require("mini.splitjoin").setup()
	require("mini.starter").setup({
		query_updaters = "abcdefghijklmnopqrstuvwxyz0123456789_-.+",
		items = {
			require("mini.starter").sections.builtin_actions(),
			require("mini.starter").sections.recent_files(3, false),
			require("mini.starter").sections.recent_files(3, true),
			require("mini.starter").sections.sessions(3, true),
			require("mini.starter").sections.pick(),
		},
	})
	require("mini.statuscolumn").setup()
	require("mini.statusline").setup({
		content = {
			active = function()
				local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
				local git = MiniStatusline.section_git({ trunc_width = 40 })
				local diff = MiniStatusline.section_diff({ trunc_width = 75 })
				local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
				local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
				local filename = MiniStatusline.section_filename({ trunc_width = 140 })
				local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
				local location = MiniStatusline.section_location({ trunc_width = 75 })
				local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
				local macro = #vim.fn.reg_recording() > 0 and "@" .. vim.fn.reg_recording() or ""
				return MiniStatusline.combine_groups({
					{ hl = mode_hl, strings = { mode } },
					{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp, fileinfo } },
					"%<",
					{ hl = "MiniStatuslineFilename", strings = { filename } },
					"%=",
					{
						hl = "MiniStatuslineFileinfo",
						strings = {
							vim.trim(table.concat({ "%S", macro, search }, " ")),
							#G.recent_keys > 0 and "▕" or "",
							table.concat(G.recent_keys, " ▏"),
						},
					},
					{ hl = mode_hl, strings = { location } },
				})
			end,
		},
	})
	require("mini.surround").setup()
	require("mini.tabline").setup({
		tabpage_section = "right",
	})
	require("mini.trailspace").setup()
	require("mini.visits").setup()
end)

-- Plugins setup
MiniMisc.safely("now", function()
	vim.g.everforest_background = "medium"
	vim.g.everforest_transparent_background = 0
	vim.g.everforest_dim_inactive_windows = 0
	vim.g.everforest_pmenu_style = "blend"
	vim.g.everforest_float_style = "blend"
	vim.g.everforest_diagnostic_virtual_text = "colored"
	vim.g.everforest_current_word = "underline"
	vim.g.everforest_better_performance = 1
	vim.g.everforest_sign_column_background = "none"
	vim.pack.add({ "https://github.com/sainnhe/everforest" })
	vim.cmd.colorscheme("everforest")
	vim.g.rainbow_delimiters = {
		strategy = {
			[""] = "rainbow-delimiters.strategy.global",
			vim = "rainbow-delimiters.strategy.local",
		},
		query = {
			[""] = "rainbow-delimiters",
			lua = "rainbow-blocks",
		},
		priority = {
			[""] = 110,
			lua = 210,
		},
		highlight = {
			"RainbowDelimiterRed",
			"RainbowDelimiterYellow",
			"RainbowDelimiterBlue",
			"RainbowDelimiterOrange",
			"RainbowDelimiterGreen",
			"RainbowDelimiterViolet",
			"RainbowDelimiterCyan",
		},
	}
	vim.pack.add({
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
		"https://codeberg.org/mfussenegger/nvim-dap",
		"https://github.com/igorlfs/nvim-dap-view",
		"https://codeberg.org/mfussenegger/nvim-jdtls",
		"https://codeberg.org/mfussenegger/nluarepl",
		"https://github.com/nvim-treesitter/nvim-treesitter-context",
		"https://github.com/MeanderingProgrammer/render-markdown.nvim",
		"https://github.com/milanglacier/minuet-ai.nvim",
		"https://github.com/neovim/nvim-lspconfig",
		"https://codeberg.org/mfussenegger/nvim-lint",
		"https://github.com/stevearc/conform.nvim",
		"https://github.com/Jezda1337/nvim-html-css",
		"https://github.com/carlos-algms/agentic.nvim",
		"https://github.com/Wansmer/symbol-usage.nvim",
		"https://github.com/romus204/go-tagger.nvim",
		"https://github.com/stevearc/quicker.nvim",
		"https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
		"https://github.com/nvimdev/visualizer.nvim",
	})
	vim.api.nvim_create_autocmd("User", {
		pattern = "TSUpdate",
		callback = function()
			local go = require("nvim-treesitter.parsers").go
			go.install_info.url = "https://github.com/alienvspredator/tree-sitter-go"
			go.install_info.revision = nil
		end,
	})
	require("nvim-treesitter").install({
		"bash",
		"c",
		"cpp",
		"css",
		"diff",
		"dockerfile",
		"fish",
		"go",
		"html",
		"ini",
		"java",
		"javascript",
		"json",
		"latex",
		"lua",
		"make",
		"markdown",
		"markdown_inline",
		"python",
		"query",
		"regex",
		"ruby",
		"rust",
		"svelte",
		"toml",
		"tsx",
		"typescript",
		"vim",
		"vimdoc",
		"xml",
		"yaml",
	})
	vim.api.nvim_create_autocmd("FileType", {
		callback = function(args)
			local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
			if
				lang
				and not pcall(vim.treesitter.start, args.buf, lang)
				and require("nvim-treesitter.parsers")[lang]
			then
				require("nvim-treesitter").install(lang)
			end
		end,
	})
	require("quicker").setup({
		keys = {
			{
				">",
				function()
					require("quicker").expand({ before = 5, after = 5, add_to_existing = true })
				end,
				desc = "Expand quickfix context",
			},
			{
				"<",
				function()
					require("quicker").collapse()
				end,
				desc = "Collapse quickfix context",
			},
		},
		follow = {
			enabled = true,
		},
		trim_leading_whitespace = "all",
	})
	---@diagnostic disable-next-line: missing-fields
	require("symbol-usage").setup({
		kinds = {
			vim.lsp.protocol.SymbolKind.Function,
			vim.lsp.protocol.SymbolKind.Method,
			vim.lsp.protocol.SymbolKind.Constant,
		},
		request_pending_text = " loading...",
		vt_position = "end_of_line",
		text_format = function(symbol)
			local fragments = {}
			local stacked_functions = symbol.stacked_count > 0 and (" | +%s"):format(symbol.stacked_count) or ""
			if symbol.references then
				table.insert(fragments, symbol.references .. " refs")
			end
			if symbol.definition then
				table.insert(fragments, symbol.definition .. " defs")
			end
			if symbol.implementation then
				table.insert(fragments, symbol.implementation .. " impls")
			end
			return " " .. table.concat(fragments, ", ") .. stacked_functions
		end,
	})
	require("go-tagger").setup()
	require("html-css").setup({
		enable_on = {
			"html",
			"htmldjango",
			"tsx",
			"jsx",
			"erb",
			"svelte",
			"vue",
			"blade",
			"php",
			"templ",
			"astro",
		},
		handlers = {
			definition = nil,
			hover = nil,
		},
		documentation = {
			auto_show = true,
		},
		style_sheets = {
			"https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css",
		},
	})
	vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignOk" })
	vim.fn.sign_define("DapBreakpointCondition", { text = "󰯳", texthl = "DiagnosticSignWarn" })
	vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticSignError" })
	vim.fn.sign_define("DapLogPoint", { text = "󰰎", texthl = "DiagnosticSignInfo" })
	vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticSignHint" })
	require("dap-view").setup({
		winbar = {
			default_section = "breakpoints",
			controls = {
				enabled = true,
			},
		},
		windows = {
			terminal = {
				hide = { "go", "delve" },
			},
			anchor = function()
				return G.terminal_win
			end,
		},
	})
	local dap, dv = require("dap"), require("dap-view")
	-- dap.defaults.fallback.force_external_terminal = true
	-- dap.defaults.fallback.terminal_win_cmd = "belowright new | resize 15"
	dap.listeners.before.attach["dap-view-config"] = function()
		dv.open()
	end
	dap.listeners.before.launch["dap-view-config"] = function()
		dv.open()
	end
	dap.listeners.before.event_terminated["dap-view-config"] = function()
		dv.close()
	end
	dap.listeners.before.event_exited["dap-view-config"] = function()
		dv.close()
	end
	require("treesitter-context").setup({
		max_lines = 6,
	})
	require("render-markdown").setup({
		completions = { lsp = { enabled = true } },
		code = {
			border = "thin",
		},
	})
	require("agentic").setup({
		provider = "opencode-acp",
	})
	require("minuet").setup({
		virtualtext = {
			auto_trigger_ft = { "*" },
			keymap = {
				accept = "<A-a>",
				accept_line = "<A-A>",
				accept_n_lines = "<A-z>",
				prev = "<A-[>",
				next = "<A-]>",
				dismiss = "<A-e>",
			},
		},
		provider = "openai_fim_compatible",
		provider_options = {
			-- openai_fim_compatible = {
			-- 	api_key = "TERM",
			-- 	name = "Ollama",
			-- 	end_point = "http://localhost:11434/v1/completions",
			-- 	model = "qwen3.5:0.8b",
			-- 	optional = {
			-- 		max_tokens = 128,
			-- 		top_p = 0.9,
			-- 	},
			-- },
			openai_fim_compatible = {
				model = "mercury-coder",
				end_point = "https://api.inceptionlabs.ai/v1/fim/completions",
				api_key = "INCEPTION_API_KEY", -- environment variable name
				stream = true,
			},
		},
	})
end)

-- Keymaps registration
MiniMisc.safely("now", function()
	local map_multistep = require("mini.keymap").map_multistep
	local map_combo = require("mini.keymap").map_combo
	local terminal_buf = nil
	local function open_terminal()
		if vim.fn.bufexists(terminal_buf) ~= 1 then
			vim.cmd("split | wincmd J | resize 10 | terminal")
			G.terminal_win = vim.fn.win_getid()
			terminal_buf = vim.fn.bufnr("%")
		elseif vim.fn.win_gotoid(G.terminal_win) ~= 1 then
			vim.cmd("sbuffer " .. terminal_buf .. "| wincmd J | resize 10")
			G.terminal_win = vim.fn.win_getid()
		end
		vim.cmd("startinsert")
	end
	local function hide_terminal()
		if vim.fn.win_gotoid(G.terminal_win) == 1 then
			vim.cmd("hide")
		end
	end
	local function toggle_terminal()
		if vim.fn.win_gotoid(G.terminal_win) == 1 then
			hide_terminal()
		else
			open_terminal()
		end
	end
	local float_terminal_buf = nil
	local previous_buf = nil
	local function open_float_terminal()
		previous_buf = vim.api.nvim_get_current_buf()
		local height = math.floor(0.6 * vim.o.lines)
		local width = math.floor(0.6 * vim.o.columns)
		G.float_terminal_win = vim.api.nvim_open_win(vim.api.nvim_get_current_buf(), true, {
			relative = "editor",
			row = math.floor(0.5 * (vim.o.lines - height)),
			col = math.floor(0.5 * (vim.o.columns - width)),
			width = width,
			height = height,
			focusable = true,
			title = " Float Term ",
			footer = " " .. vim.o.shell .. " ",
			footer_pos = "right",
		})
		vim.api.nvim_set_current_win(G.float_terminal_win)
		if vim.fn.bufexists(float_terminal_buf) ~= 1 then
			vim.cmd("terminal")
			float_terminal_buf = vim.api.nvim_get_current_buf()
		else
			vim.cmd("buffer " .. float_terminal_buf)
		end
		vim.cmd("startinsert")
	end
	local function hide_float_terminal()
		if vim.fn.win_gotoid(G.float_terminal_win) == 1 then
			vim.cmd("hide")
		end
		if previous_buf then
			vim.cmd("buffer " .. previous_buf)
			previous_buf = nil
		end
	end
	local function toggle_float_terminal()
		if vim.fn.win_gotoid(G.float_terminal_win) == 1 then
			hide_float_terminal()
		else
			open_float_terminal()
		end
	end
	local function toggle_tabs()
		vim.o.expandtab = false
		vim.cmd("retab!")
	end
	local function toggle_spaces()
		vim.o.expandtab = true
		vim.cmd("retab!")
	end
	local function diagnostic_virtual_text_toggle()
		vim.diagnostic.config({
			virtual_text = not vim.diagnostic.config().virtual_text,
		})
	end
	local function diagnostic_virtual_lines_toggle()
		vim.diagnostic.config({
			virtual_lines = not vim.diagnostic.config().virtual_lines,
		})
	end
	local function window_type_open(field)
		for _, win in ipairs(vim.fn.getwininfo()) do
			if win[field] == 1 then
				return true
			end
		end
		return false
	end
	local function toggle_quickfix()
		vim.cmd(window_type_open("quickfix") and "cclose" or "copen")
	end
	local function toggle_loclist()
		vim.cmd(window_type_open("loclist") and "lclose" or "lopen")
	end
	local make_ai_jump = function(search_method)
		return function()
			require("mini.ai").move_cursor("left", "a", "e", { n_times = vim.v.count1, search_method = search_method })
		end
	end
	local make_case = function(style)
		return function()
			G.case_style = style
			if vim.fn.mode():match("^[vV\22]") then
				require("mini.operators").evaluate("visual")
				return
			end
			local line, col = vim.fn.getline("."), vim.fn.col(".") - 1
			if not line:sub(col + 1, col + 1):match("[%w_%-]") then
				return
			end
			local from, to = col, col
			while from > 0 and line:sub(from, from):match("[%w_%-]") do
				from = from - 1
			end
			while to < #line and line:sub(to + 1, to + 1):match("[%w_%-]") do
				to = to + 1
			end
			vim.fn.setpos("'[", { 0, vim.fn.line("."), from + 1, 0 })
			vim.fn.setpos("']", { 0, vim.fn.line("."), to, 0 })
			require("mini.operators").evaluate("char")
		end
	end
	Imap("<C-\\>", "<cmd>lua vim.lsp.inline_completion.get()<CR>", "Accept inline completion")
	Map({ "n", "x" }, "<leader>aa", require("agentic").add_selection_or_file_to_context, "Add selection or file")
	Map({ "n", "x" }, "<leader>cc", make_case("camel"), "Convert to camelCase")
	Map({ "n", "x" }, "<leader>ck", make_case("kebab"), "Convert to kebab-case")
	Map({ "n", "x" }, "<leader>cn", make_ai_jump("next"), "Next case word")
	Map({ "n", "x" }, "<leader>cp", make_ai_jump("cover_or_prev"), "Previous case word")
	Map({ "n", "x" }, "<leader>cs", make_case("snake"), "Convert to snake_case")
	Map({ "x", "v" }, "gx", '"+d', "Cut selection to clipboard")
	Map({ "x", "v", "n" }, "<leader>lf", require("conform").format, "Format code")
	Nmap("<C-Space><Space>", toggle_spaces, "Expand tabs")
	Nmap("<C-Space><Tab>", toggle_tabs, "Contract tabs")
	Nmap("<F2>", ":lua require('treesitter-context').go_to_context()<CR>", "Go to context")
	Nmap("<F3>", vim.pack.update, "Update vim plugins")
	Nmap("<F4>", require("symbol-usage").toggle, "Toggle symbol usage")
	Nmap("<F5>", require("symbol-usage").refresh, "Refresh symbol usage")
	Nmap("<F6>", ":Inspect<CR>", "Echo syntax group")
	Nmap("<F7>", ":TSContext toggle<CR>", "Toggle treesitter context")
	Nmap("<F8>", ":RenderMarkdown toggle<CR>", "Toggle markdown preview")
	Nmap("<Space><Space>", toggle_terminal, "Toggle terminal")
	Nmap("<Space><Tab>", toggle_float_terminal, "Toggle float terminal")
	Nmap("<leader>aD", require("agentic").add_buffer_diagnostics, "Add buffer diagnostics")
	Nmap("<leader>ad", require("agentic").add_current_line_diagnostics, "Add line diagnostics")
	Nmap("<leader>an", require("agentic").new_session, "New session")
	Nmap("<leader>ar", require("agentic").restore_session, "Restore session")
	Nmap("<leader>at", require("agentic").toggle, "Toggle agent")
	Nmap("<leader>bD", ":lua MiniBufremove.delete(0, true)<CR>", "Delete!")
	Nmap("<leader>bW", ":lua MiniBufremove.wipeout(0, true)<CR>", "Wipeout!")
	Nmap("<leader>ba", ":b#<CR>", "Alternate")
	Nmap("<leader>bd", ":lua MiniBufremove.delete()<CR>", "Delete")
	Nmap("<leader>bn", ":tabnew %<CR>", "Open current buffer in full screen")
	Nmap("<leader>bw", ":lua MiniBufremove.wipeout()<CR>", "Wipeout")
	Nmap("<leader>bz", MiniMisc.zoom, "Open current buffer in zoomed manner")
	Nmap("<leader>dB", ":lua require('dap').list_breakpoints()<CR>", "List breakpoints")
	Nmap("<leader>dC", ":lua require('dap').clear_breakpoints()<CR>", "Clear breakpoints")
	Nmap("<leader>dR", ":DapNew nluarepl<CR>", "Open lua Repl")
	Nmap("<leader>dS", ":lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').scopes)<CR>", "Scopes")
	Nmap("<leader>dT", ":DapViewToggle!<CR>", "Toggle dap view")
	Nmap("<leader>db", ":lua require('dap').toggle_breakpoint()<CR>", "Toggle breakpoint")
	Nmap("<leader>dc", ":lua require('dap').continue()<CR>", "Continue")
	Nmap("<leader>df", ":lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').frames)<CR>", "Frames")
	Nmap("<leader>dh", ":lua require('dap.ui.widgets').hover()<CR>", "Hover value")
	Nmap("<leader>dl", ":lua require('dap').run_last()<CR>", "Run Last")
	Nmap("<leader>dlp", ":lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log: '))<CR>", "Log point")
	Nmap("<leader>dp", ":lua require('dap.ui.widgets').preview()<CR>", "Preview")
	Nmap("<leader>dr", ":lua require('dap').repl.open({}, 'vsplit new')<CR>", "Open Repl")
	Nmap("<leader>dsO", ":lua require('dap').step_over()<CR>", "Step over")
	Nmap("<leader>dsi", ":lua require('dap').step_into()<CR>", "Step into")
	Nmap("<leader>dso", ":lua require('dap').step_out()<CR>", "Step out")
	Nmap("<leader>dt", ":DapViewToggle<CR>", "Toggle dap view")
	Nmap("<leader>dw", ":DapViewWatch<CR>", "Add a new expression watcher")
	Nmap("<leader>ef", ":lua if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0)) end<CR>", "Buf")
	Nmap("<leader>et", ":lua if not MiniFiles.close() then MiniFiles.open() end<CR>", "Toggle file explorer")
	Nmap("<leader>fD", ':Pick diagnostic scope="all"<CR>', "Search workspace diagnostics")
	Nmap("<leader>fM", ':Pick marks scope="all"<CR>', "Search workspace marks")
	Nmap("<leader>fS", ":Pick grep_live<CR>", "Search content live")
	Nmap("<leader>fT", ":Pick treesitter<CR>", "Search treesitter tree")
	Nmap("<leader>fY", ':Pick lsp scope="workspace_symbol"<CR>', "Search workspace symbols")
	Nmap("<leader>fb", ":Pick buffers<CR>", "Search buffers")
	Nmap("<leader>fd", ':Pick diagnostic scope="current"<CR>', "Search document diagnostics")
	Nmap("<leader>ff", ":Pick files<CR>", "Search files")
	Nmap("<leader>fgC", ":Pick git_commits<CR>", "Search commits")
	Nmap("<leader>fgb", ":Pick git_branches<CR>", "Search branches")
	Nmap("<leader>fgc", ':Pick git_commits path="%"<CR>', "Search buffer commits")
	Nmap("<leader>fgf", ":Pick git_files<CR>", "Search git files")
	Nmap("<leader>fgs", ':Pick git_hunks scope="staged"<CR>', "Search git hunks staged")
	Nmap("<leader>fgu", ':Pick git_hunks scope="unstaged"<CR>', "Search git hunks unstaged")
	Nmap("<leader>fh", ":Pick hl_groups<CR>", "Search highlight groups")
	Nmap("<leader>fk", ":Pick keymaps<CR>", "Search keymaps")
	Nmap("<leader>fl", ':Pick buf_lines scope="current"<CR>', "Search buffer lines")
	Nmap("<leader>fm", ':Pick marks scope="buf"<CR>', "Search document marks")
	Nmap("<leader>fo", ':Pick list scope="location"<CR>', "Search loclist")
	Nmap("<leader>fq", ':Pick list scope="quickfix"<CR>', "Search quickfix")
	Nmap("<leader>fr", ":Pick resume<CR>", "Resume latest picker")
	Nmap("<leader>fs", ":Pick grep<CR>", "Search content")
	Nmap("<leader>ft", ":Pick treesitter_symbols<CR>", "Search treesitter symbols")
	Nmap("<leader>fy", ':Pick lsp scope="document_symbol"<CR>', "Search document symbols")
	Nmap("<leader>lC", ":lua vim.lsp.codelens.run()<CR>", "Code lens run")
	Nmap("<leader>lF", ":lua vim.lsp.buf.format()<CR>", "Lsp Format")
	Nmap("<leader>lI", ":lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>", "Inlay hints toggle")
	Nmap("<leader>lc", ":lua vim.lsp.buf.code_action()<CR>", "Code action")
	Nmap("<leader>ldT", diagnostic_virtual_lines_toggle, "Virtual lines toggle")
	Nmap("<leader>ldh", ":lua vim.diagnostic.open_float({title=' Hover ',title_pos='left'})<CR>", "Hover diagnostics")
	Nmap("<leader>ldt", diagnostic_virtual_text_toggle, "Virtual text toggle")
	Nmap("<leader>lgD", ":lua vim.lsp.buf.declaration()<CR>", "Goto declaration")
	Nmap("<leader>lgd", ":lua vim.lsp.buf.definition()<CR>", "Goto definition")
	Nmap("<leader>lgi", ":lua vim.lsp.buf.implementation()<CR>", "Goto implementation")
	Nmap("<leader>lgr", ":lua vim.lsp.buf.references()<CR>", "Goto references")
	Nmap("<leader>lgtd", ":lua vim.lsp.buf.type_definition()<CR>", "Goto type definition")
	Nmap("<leader>lh", ":lua vim.lsp.buf.hover({title=' Hover ',title_pos='left'})<CR>", "Hover symbol")
	Nmap("<leader>li", ":lua vim.lsp.buf.incoming_calls()<CR>", "Lsp incoming calls")
	Nmap("<leader>lo", ":lua vim.lsp.buf.outgoing_calls()<CR>", "Lsp outgoing calls")
	Nmap("<leader>lr", ":lua vim.lsp.buf.rename()<CR>", "Rename")
	Nmap("<leader>ls", ":lua vim.lsp.buf.signature_help()<CR>", "Signature help")
	Nmap("<leader>mT", ":lua MiniMap.toggle_focus(true)<CR>", "Toggle map focus")
	Nmap("<leader>mt", ":lua MiniMap.toggle()<CR>", "Toggle map")
	Nmap("<leader>ql", toggle_loclist, "Toggle loclist")
	Nmap("<leader>qq", toggle_quickfix, "Toggle quickfix")
	Nmap("<leader>wo", ":only<CR>", "Close other windows")
	Nmap("<leader>wq", ":close<CR>", "Close window")
	Nmap("<leader>ws", ":split<CR>", "Horizontal split")
	Nmap("<leader>wv", ":vsplit<CR>", "Vertical split")
	Nmap("[a", ":norm gxiagxila<CR>", "Move arg left")
	Nmap("[e", ":lua MiniBracketed.diagnostic('backward',{severity=vim.diagnostic.severity.ERROR})<CR>", "Error last")
	Nmap("]a", ":norm gxiagxina<CR>", "Move arg right")
	Nmap("]e", ":lua MiniBracketed.diagnostic('forward',{severity=vim.diagnostic.severity.ERROR})<CR>", "Error forward")
	Nmap("gC", ":lua MiniGit.show_at_cursor()<CR>", "Git line history")
	Nmap("gd", ":lua MiniDiff.toggle_overlay()<CR>", "Show diff")
	Nmap("gxx", '"+dd', "Cut line to clipboard")
	Tmap("<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode")
	map_combo("t", "kj", "<BS><BS><C-\\><C-n>")
	map_combo({ "i", "c", "x", "s" }, "kj", "<BS><BS><Esc>")
	map_multistep("i", "<BS>", { "minipairs_bs" })
	map_multistep("i", "<C-h>", { "jump_before_open" })
	map_multistep("i", "<C-l>", { "jump_after_close" })
	map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
	map_multistep({ "n", "v" }, "<C-n>", { "jump_after_tsnode" })
	map_multistep({ "n", "v" }, "<C-p>", { "jump_before_tsnode" })
end)

-- Autocommands registration
MiniMisc.safely("now", function()
	local non_text_filetypes = {
		netrw = true,
		help = true,
		nofile = true,
		qf = true,
		git = true,
		diff = true,
		msg = true,
		pager = true,
		cmd = true,
		dialog = true,
		query = true,
		["dap-repl"] = true,
		["dap-view"] = true,
		["dap-view-term"] = true,
		["dap-float"] = true,
		ministarter = true,
	}
	local html_like_filetypes = {
		svelte = true,
		vue = true,
		jsx = true,
		tsx = true,
		html = true,
		xml = true,
		xsl = true,
		htmlangular = true,
	}
	local non_file_buftypes = {
		nofile = true,
		terminal = true,
		quickfix = true,
		prompt = true,
		help = true,
		acwrite = true,
		nowrite = true,
	}
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "*",
		callback = function(args)
			local buf = args.buf
			local filetype = vim.bo[buf].filetype
			local buftype = vim.bo[buf].buftype
			if html_like_filetypes[filetype] then
				vim.bo[buf].omnifunc = "htmlcomplete#CompleteTags"
				Imap("><Space>", ">", "Cancel html pairs", { buffer = true })
				Imap("><CR>", "><Esc>yyppk^Dj^Da</<C-x><C-o><C-x><C-o><C-p><C-p><Esc>ka<Tab>", "Newline html pairs", {
					buffer = true,
				})
				Imap(">", "><Esc>F<f>a</<C-x><C-o><C-x><C-o><C-p><C-p><Esc>vit<Esc>i", "Sameline html pairs", {
					buffer = true,
				})
				Imap(">>", "><Esc>F<f>a</<C-x><C-o><C-x><C-o><C-p><C-p><Space><BS>", "Sameline cursor end html pairs", {
					buffer = true,
				})
			end
			if non_text_filetypes[filetype] then
				vim.b[buf].minicursorword_disable = true
				vim.b[buf].miniindentscope_disable = true
				vim.b[buf].minitrailspace_disable = true
				vim.wo.listchars = "leadmultispace:  ,tab:  "
				MiniTrailspace.unhighlight()
				if filetype == "dap-repl" then
					require("dap.ext.autocompl").attach()
				end
				if filetype == "git" or filetype == "diff" then
					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.MiniGit.diff_foldexpr()"
				end
			end
			if (buftype ~= "" or filetype ~= "") and not non_file_buftypes[buftype] then
				vim.wo.winbar = "⠀⠀󰁔 %F"
				Map(
					{ "n", "x", "o" },
					"<CR>",
					":lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character)<CR>",
					"Start jump",
					{ buffer = true }
				)
			end
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "diff", "patch" },
		callback = function(args)
			local bufnr = args.buf
			local diff_highlight_namespace = vim.api.nvim_create_namespace("DiffHighlight")
			vim.api.nvim_buf_clear_namespace(bufnr, diff_highlight_namespace, 0, -1)
			local function highlight_range(change, start_byte, end_byte, highlight, priority)
				vim.api.nvim_buf_set_extmark(bufnr, diff_highlight_namespace, change.line - 1, start_byte + 1, {
					end_row = change.line - 1,
					end_col = end_byte + 1,
					hl_mode = "blend",
					hl_group = highlight,
					priority = priority,
				})
			end
			local function highlight_hunk(changes, diff_start, diff_lines, highlight, priority)
				if diff_lines == 0 then
					return
				end
				for index = 1, #changes do
					local change = changes[index]
					if change.char_count >= diff_start then
						local offset = diff_start - (change.char_count - change.content_chars) - 1
						local remaining = diff_lines
						local cursor = index
						while remaining > 0 and cursor <= #changes do
							local current = changes[cursor]
							local available = current.content_chars - offset
							local start_byte = vim.fn.byteidx(current.content, offset)
							if available <= remaining then
								highlight_range(current, start_byte, #current.content, highlight, priority)
								remaining = remaining - available
								offset = 0
								cursor = cursor + 1
							else
								local end_byte = vim.fn.byteidx(current.content, offset + remaining)
								highlight_range(current, start_byte, end_byte, highlight, priority)
								remaining = 0
							end
						end
						break
					end
				end
			end
			local function joined_text(changes)
				local chars = {}
				for _, change in ipairs(changes) do
					vim.list_extend(chars, vim.fn.split(change.content, "\\zs"))
				end
				return #chars > 0 and table.concat(chars, "\n") .. "\n" or ""
			end
			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
			table.insert(lines, " ")
			local removed, added = {}, {}
			local line_nr = 1
			while line_nr <= #lines do
				if lines[line_nr]:sub(1, 1) == "@" then
					local removed_chars, added_chars = 0, 0
					while line_nr <= #lines and lines[line_nr]:sub(1, 5) ~= "index" do
						local line = lines[line_nr]
						local marker = line:sub(1, 1)
						if marker == "-" then
							local content = line:sub(2)
							local content_chars = vim.fn.strchars(content)
							removed_chars = removed_chars + content_chars
							table.insert(removed, {
								line = line_nr,
								content = content,
								char_count = removed_chars,
								content_chars = content_chars,
							})
						elseif marker == "+" then
							local content = line:sub(2)
							local content_chars = vim.fn.strchars(content)
							added_chars = added_chars + content_chars
							table.insert(added, {
								line = line_nr,
								content = content,
								char_count = added_chars,
								content_chars = content_chars,
							})
						else
							if #removed ~= 0 and #added ~= 0 then
								vim.text.diff(joined_text(removed), joined_text(added), {
									result_type = "indices",
									algorithm = "minimal",
									-- ignore_whitespace = true,
									-- ignore_whitespace_change = true,
									-- ignore_whitespace_change_at_eol = true,
									-- ignore_cr_at_eol = true,
									-- ignore_blank_lines = true,
									indent_heuristic = true,
									on_hunk = function(start_removed, count_removed, start_added, count_added)
										highlight_hunk(removed, start_removed, count_removed, "DiffDelete", 100)
										highlight_hunk(added, start_added, count_added, "DiffAdd", 100)
									end,
								})
							end
							removed, added = {}, {}
							removed_chars, added_chars = 0, 0
						end
						line_nr = line_nr + 1
					end
					line_nr = line_nr + 2
				end
				line_nr = line_nr + 1
			end
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		pattern = "MiniFilesBufferCreate,MiniFilesWindowOpen,MiniFilesWindowUpdate",
		callback = function(args)
			if args.match == "MiniFilesWindowOpen" or args.match == "MiniFilesWindowUpdate" then
				local win_id = args.data.win_id
				local win_config = vim.api.nvim_win_get_config(win_id)
				win_config.anchor = "SW"
				win_config.row = vim.o.lines - 1
				local height = math.floor(0.6 * vim.o.lines)
				win_config.height = win_config.height < height and win_config.height or height
				vim.api.nvim_win_set_config(win_id, win_config)
				return
			end
			local bufnr = args.data.buf_id
			Nmap("~", function()
				local path = (MiniFiles.get_fs_entry() or {}).path
				if path == nil then
					return vim.notify("Cursor is not on valid entry")
				end
				vim.fn.chdir(vim.fs.dirname(path))
			end, "Set cwd", { buffer = bufnr })
			Nmap("yy", function()
				local path = (MiniFiles.get_fs_entry() or {}).path
				if path == nil then
					return vim.notify("Cursor is not on valid entry")
				end
				vim.fn.setreg("", path)
			end, "Yank path", { buffer = bufnr })
			Nmap("gy", function()
				local path = (MiniFiles.get_fs_entry() or {}).path
				if path == nil then
					return vim.notify("Cursor is not on valid entry")
				end
				vim.fn.setreg("+", path)
			end, "Yank path to clipboard", { buffer = bufnr })
			local show_dotfiles = true
			Nmap(".", function()
				show_dotfiles = not show_dotfiles
				local dotfile_filter = function(fs_entry)
					return show_dotfiles and true or not vim.startswith(fs_entry.name, ".")
				end
				MiniFiles.refresh({ content = { filter = dotfile_filter } })
			end, "Toggle dotfiles", { buffer = bufnr })
		end,
	})
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client then
				client.server_capabilities.semanticTokensProvider = nil
			end
			-- vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
		end,
	})
	vim.api.nvim_create_autocmd("BufWrite", {
		pattern = "*",
		callback = function()
			MiniTrailspace.trim()
			MiniTrailspace.trim_last_lines()
		end,
	})
	vim.api.nvim_create_autocmd("BufWritePost", {
		callback = function()
			local ok, err = pcall(require("lint").try_lint)
			if not ok then
				vim.notify("Lint error: " .. tostring(err), vim.log.levels.WARN)
			end
		end,
	})
end)

-- Lsp configurations setup
MiniMisc.safely("now", function()
	local lsp_capabilities =
		vim.tbl_extend("force", vim.lsp.protocol.make_client_capabilities(), MiniCompletion.get_lsp_capabilities())
	lsp_capabilities.general.positionEncodings = { G.offset_encoding }
	local lua_runtime_files = vim.tbl_filter(function(path)
		return path ~= vim.fn.stdpath("config")
	end, vim.api.nvim_get_runtime_file("", true))
	table.insert(lua_runtime_files, "${3rd}/luv/library")
	local jdtls_bundles = vim.split(vim.fn.glob("/usr/share/java-debug/*.jar", true), "\n")
	local lsp_servers = {
		lua_ls = {
			---@type lspconfig.settings.lua_ls
			settings = {
				Lua = {
					hint = {
						enable = true,
					},
					runtime = {
						version = "LuaJIT",
					},
					completion = {
						callSnippet = "Replace",
					},
					workspace = {
						-- library = {
						--	vim.env.VIMRUNTIME,
						-- },
						library = lua_runtime_files,
					},
				},
			},
		},
		marksman = {},
		texlab = {},
		html = {},
		eslint = {
			filetypes = {
				"astro",
				"css",
				"html",
				"htmlangular",
				"javascript",
				"jsx",
				"svelte",
				"typescript",
				"tsx",
				"vue",
			},
		},
		cssls = {},
		bashls = {},
		gopls = {
			---@type lspconfig.settings.gopls
			settings = {
				gopls = {
					hints = {
						rangeVariableTypes = true,
						parameterNames = true,
						constantValues = true,
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						functionTypeParameters = true,
					},
				},
			},
		},
		pyright = {},
		-- basedpyright = {
		-- 	---@type lspconfig.settings.basedpyright
		-- 	settings = {
		-- 		basedpyright = {
		-- 			analysis = {
		-- 				autoSearchPaths = true,
		-- 				diagnosticMode = "openFilesOnly",
		-- 				useLibraryCodeForTypes = true,
		-- 			},
		-- 		},
		-- 	},
		-- },
		vtsls = {
			---@type lspconfig.settings.vtsls
			settings = {
				typescript = {
					inlayHints = {
						parameterNames = { enabled = "all" },
						parameterTypes = { enabled = true },
						variableTypes = { enabled = true },
						propertyDeclarationTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						enumMemberValues = { enabled = true },
					},
				},
			},
		},
		-- ts_ls = {
		-- 	---@type lspconfig.settings.ts_ls
		-- 	settings = {
		-- 		typescript = {
		-- 			inlayHints = {
		-- 				includeInlayParameterNameHints = "all",
		-- 				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
		-- 				includeInlayFunctionParameterTypeHints = true,
		-- 				includeInlayVariableTypeHints = true,
		-- 				includeInlayVariableTypeHintsWhenTypeMatchesName = true,
		-- 				includeInlayPropertyDeclarationTypeHints = true,
		-- 				includeInlayFunctionLikeReturnTypeHints = true,
		-- 				includeInlayEnumMemberValueHints = true,
		-- 			},
		-- 		},
		-- 		javascript = {
		-- 			inlayHints = {
		-- 				includeInlayParameterNameHints = "all",
		-- 				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
		-- 				includeInlayFunctionParameterTypeHints = true,
		-- 				includeInlayVariableTypeHints = true,
		-- 				includeInlayVariableTypeHintsWhenTypeMatchesName = true,
		-- 				includeInlayPropertyDeclarationTypeHints = true,
		-- 				includeInlayFunctionLikeReturnTypeHints = true,
		-- 				includeInlayEnumMemberValueHints = true,
		-- 			},
		-- 		},
		-- 	},
		-- },
		svelte = {
			---@type lspconfig.settings.svelte
			settings = {
				typescript = {
					inlayHints = {
						parameterNames = { enabled = "all" },
						parameterTypes = { enabled = true },
						variableTypes = { enabled = true },
						propertyDeclarationTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						enumMemberValues = { enabled = true },
					},
				},
			},
		},
		yamlls = {},
		jsonls = {},
		lemminx = {},
		angularls = {},
		jdtls = {
			filetypes = { "java", "jproperties" },
			cmd = {
				"jdtls",
				-- "--java-executable",
				-- "/usr/lib/jvm/java-21-openjdk/bin/java",
				"--jvm-arg=-javaagent:/usr/share/java/lombok/lombok.jar",
			},
			---@type lspconfig.settings.jdtls
			settings = {
				java = {
					references = {
						includeDecompiledSources = true,
					},
					eclipse = {
						downloadSources = true,
					},
					maven = {
						downloadSources = true,
					},
					format = {
						enabled = true,
					},
					inlayHints = {
						parameterNames = {
							enabled = "all",
							exclusions = { "this" },
						},
					},
					signatureHelp = { enabled = true, description = { enabled = true } },
					contentProvider = { preferred = "fernflower" },
					configuration = {
						runtimes = {
							{
								name = "JavaSE-11",
								path = "/usr/lib/jvm/java-11-openjdk/",
							},
							{
								name = "JavaSE-17",
								path = "/usr/lib/jvm/java-17-openjdk/",
							},
							{
								name = "JavaSE-21",
								path = "/usr/lib/jvm/java-21-openjdk/",
							},
						},
					},
				},
			},
			init_options = {
				bundles = jdtls_bundles,
			},
		},
	}
	vim.lsp.config("*", {
		capabilities = lsp_capabilities,
		root_markers = { ".git" },
	})
	for server, config in pairs(lsp_servers) do
		vim.lsp.config(server, config)
		vim.lsp.enable(server)
	end
end)

-- Linting and formatting setup
MiniMisc.safely("later", function()
	require("lint").linters_by_ft = {
		c = { "clangtidy" },
		-- css = { "eslint" },
		go = { "golangcilint" },
		-- html = { "eslint" },
		-- htmlangular = { "eslint" },
		java = { "checkstyle" },
		-- javascript = { "eslint" },
		-- jsx = { "eslint" },
		lua = { "luacheck" },
		python = { "pylint" },
		sh = { "shellcheck" },
		sql = { "sqlfluff" },
		-- svelte = { "eslint" },
		tex = { "chktex" },
		-- tsx = { "eslint" },
		-- typescript = { "eslint" },
	}
	require("conform").setup({
		formatters_by_ft = {
			c = { "clang-format" },
			css = { "prettier" },
			dockerfile = { "dockerfmt" },
			fish = { "fish_indent" },
			go = { "gofmt", "gofumpt" },
			groovy = { "npm-groovy-lint" },
			html = { "prettier" },
			htmlangular = { "prettier" },
			java = { "google-java-format" },
			javascript = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
			jsx = { "prettier" },
			lua = { "stylua" },
			make = { "bake" },
			markdown = { "prettier" },
			python = { "black" },
			scss = { "prettier" },
			sh = { "shfmt" },
			sql = { "sqlfluff" },
			svelte = { "prettier" },
			svg = { "xmllint" },
			tex = { "latexindent" },
			tsx = { "prettier" },
			typescript = { "prettier" },
			xml = { "xmllint" },
			yaml = { "prettier" },
		},
		format_on_save = {
			timeout_ms = 1000,
			lsp_format = "fallback",
		},
	})
	vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
end)

-- Dap configurations setup
MiniMisc.safely("later", function()
	local dap = require("dap")
	-- Adapter definitions
	dap.adapters.debugpy = function(callback, config)
		callback({
			type = "server",
			hostName = config.hostName,
			port = config.port,
			options = {
				source_filetype = "python",
			},
		})
	end
	dap.adapters["pwa-node"] = {
		type = "server",
		hostName = "localhost",
		port = "${port}",
		executable = {
			command = "node",
			args = { "/usr/share/js-debug/src/dapDebugServer.js", "${port}" },
		},
	}
	dap.adapters.delve = function(callback, config)
		callback({
			type = "server",
			hostName = config.hostName,
			port = config.port,
		})
	end
	-- Debug configurations
	-- debugpy --listen 127.0.0.1:5678 --wait-for-client main.py
	dap.configurations.python = {
		{
			type = "debugpy",
			name = "Attach remote",
			mode = "remote",
			request = "attach",
			hostName = function()
				return vim.fn.input("Enter host: ", "127.0.0.1")
			end,
			port = function()
				return vim.fn.input("Enter port: ", tostring(5678))
			end,
		},
	}
	-- dlv debug --headless -l 127.0.0.1:38697 main.go
	dap.configurations.go = {
		{
			type = "delve",
			name = "Attach remote",
			mode = "remote",
			request = "attach",
			outputMode = "remote",
			hostName = function()
				return vim.fn.input("Enter host: ", "127.0.0.1")
			end,
			port = function()
				return vim.fn.input("Enter port: ", tostring(38697))
			end,
		},
	}
	-- java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=8000 Main.java
	-- mvnDebug exec:java -Dexec.mainClass="com.mycompany.app.App"
	dap.configurations.java = {
		{
			type = "java",
			name = "Attach remote",
			mode = "remote",
			request = "attach",
			hostName = function()
				return vim.fn.input("Enter host: ", "127.0.0.1")
			end,
			port = function()
				return vim.fn.input("Enter port: ", tostring(8000))
			end,
		},
	}
	-- node --inspect-brk=127.0.0.1:9229 main.js
	for _, filetype in ipairs({ "typescript", "javascript" }) do
		dap.configurations[filetype] = {
			{
				type = "pwa-node",
				name = "Attach remote",
				mode = "remote",
				request = "attach",
				hostName = function()
					return vim.fn.input("Enter host: ", "127.0.0.1")
				end,
				port = function()
					return vim.fn.input("Enter port: ", tostring(9229))
				end,
			},
		}
	end
end)

-- Lazy loaded custom configuration
MiniMisc.safely("later", function()
	MiniPick.registry.git_hunks = function(local_opts)
		local_opts = local_opts or {}
		MiniExtra.pickers.git_hunks(local_opts, {
			source = {
				choose_marked = function(items_marked)
					vim.tbl_map(function(item)
						local patch = vim.deepcopy(item.header)
						vim.list_extend(patch, item.hunk)
						local cmd
						if local_opts.scope == "staged" then
							cmd = { "git", "apply", "--cached", "--reverse", "-" }
						else
							cmd = { "git", "apply", "--cached", "-" }
						end
						vim.system(cmd, { stdin = patch }):wait()
					end, items_marked)
				end,
			},
		})
	end
	MiniPick.registry.treesitter_symbols = function(opts)
		opts = opts or {}
		local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
		local filetype = vim.bo[bufnr].filetype
		local lang = vim.treesitter.language.get_lang(filetype) or filetype
		if not pcall(vim.treesitter.language.add, lang) or #vim.treesitter.query.get_files(lang, "locals") == 0 then
			vim.notify(("No treesitter parser or no 'locals.scm' found for '%s'"):format(filetype), vim.log.levels.WARN)
			return
		end
		local parser = vim.treesitter.get_parser(bufnr, lang)
		local query = vim.treesitter.query.get(lang, "locals")
		if not (parser and query) then
			vim.notify(("Cannot get treesitter symbols for '%s'"):format(filetype), vim.log.levels.ERROR)
			return
		end
		parser:parse(true)
		local root = parser:trees()[1]:root()
		if not root then
			vim.notify(("Cannot parse treesitter symbols for '%s'"):format(filetype), vim.log.levels.ERROR)
			return
		end
		local kind_aliases = {
			var = "variable",
			parameter = "constant",
			associated = "object",
		}
		local entries = {}
		for id, node in query:iter_captures(root, bufnr) do
			local capture = query.captures[id]
			if node and capture and vim.startswith(capture, "local.definition") then
				local kind = capture:gsub(".*%.", "")
				if not opts.node_filter or opts.node_filter({ kind = kind, node = node }, kind) then
					local display_kind = kind_aliases[kind] or kind
					local lnum, col, end_lnum, end_col = vim.treesitter.get_node_range(node)
					local text = vim.treesitter.get_node_text(node, bufnr)
					local icon, hl = MiniIcons.get("lsp", display_kind)
					entries[#entries + 1] = {
						text = string.format("[%s %s] %s", icon, display_kind, text),
						hl = hl,
						bufnr = bufnr,
						lnum = lnum + 1,
						col = col + 1,
						end_lnum = end_lnum + 1,
						end_col = end_col + 1,
					}
				end
			end
		end
		local highlight_namespace = vim.api.nvim_get_namespaces()["MiniExtraPickers"]
		MiniPick.start(vim.tbl_deep_extend("force", opts, {
			source = {
				items = entries,
				name = "Tree-sitter symbols",
				show = function(buf_id, items_to_show, pick_query)
					MiniPick.default_show(buf_id, items_to_show, pick_query)
					vim.api.nvim_buf_clear_namespace(buf_id, highlight_namespace, 0, -1)
					for i, item in ipairs(items_to_show) do
						vim.api.nvim_buf_set_extmark(
							buf_id,
							highlight_namespace,
							i - 1,
							0,
							{ end_row = i, end_col = 0, hl_mode = "blend", hl_group = item.hl, priority = 100 }
						)
					end
				end,
			},
		}))
	end
	vim.on_key(function(_, key)
		if key == "" then
			return
		end
		local key_name = vim.fn.keytrans(key)
		local count, previous = 0, nil
		if #G.recent_keys > 0 then
			local parts = vim.split(G.recent_keys[#G.recent_keys], " ", { plain = true })
			count = #parts == 2 and tonumber(parts[1]) or 1
			previous = #parts == 2 and parts[2] or parts[1]
		end
		if previous == key_name then
			G.recent_keys[#G.recent_keys] = count + 1 .. " " .. key_name
		else
			if #G.recent_keys >= 5 then
				table.remove(G.recent_keys, 1)
			end
			table.insert(G.recent_keys, key_name)
		end
		vim.api.nvim__redraw({ statusline = true })
	end)
end)
