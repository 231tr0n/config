-- Globals declaration
-- luacheck: globals vim
-- luacheck: globals G Unmap Map Vscode Tmap Cmap Nmap Vmap Imap Smap Xmap Hi
-- luacheck: globals MiniPick MiniBracketed MiniIcons MiniMisc MiniCompletion MiniTrailspace
-- luacheck: globals MiniDeps MiniMap MiniStatusline MiniVisits MiniSnippets MiniExtra MiniFiles

-- Vim pack setup
if not vim.pack then
	local path_package = vim.fn.stdpath("data") .. "/site/"
	local mini_path = path_package .. "pack/deps/opt/mini.nvim"
	if not vim.uv.fs_stat(mini_path) then
		vim.cmd('echo "Installing `mini.nvim`" | redraw')
		local clone_cmd = {
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/nvim-mini/mini.nvim",
			mini_path,
		}
		vim.fn.system(clone_cmd)
		vim.cmd('echo "Installed `mini.nvim`" | redraw')
	end
	vim.cmd("packadd mini.nvim | helptags ALL")
	require("mini.deps").setup({ path = { package = path_package } })
	vim.pack = {
		add = function(args)
			for _, arg in ipairs(args) do
				MiniDeps.add(arg)
			end
		end,
	}
end
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })
require("mini.misc").setup()

-- Helper functions
Unmap = function(modes, suffix, opts)
	vim.keymap.del(modes, suffix, opts or {})
end
Map = function(modes, suffix, rhs, desc, opts)
	opts = opts or {}
	if not opts.silent then
		opts.silent = true
	end
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

-- Global variables and functions declared and used
MiniMisc.safely("now", function()
	G = {
		keys = {},
		te_win = nil,
		te_float_win = nil,
		offset_encoding = "utf-16",
		languages = {
			angular = true,
			awk = true,
			bash = true,
			bibtex = true,
			c = true,
			cmake = true,
			cpp = true,
			css = true,
			csv = true,
			diff = true,
			dockerfile = true,
			doxygen = true,
			fish = true,
			git_config = true,
			git_rebase = true,
			gitcommit = true,
			gitignore = true,
			go = true,
			gomod = true,
			gosum = true,
			gowork = true,
			graphql = true,
			groovy = true,
			html = true,
			http = true,
			hurl = true,
			ini = true,
			java = true,
			javascript = true,
			jq = true,
			jsdoc = true,
			json = true,
			json5 = true,
			latex = true,
			lua = true,
			luadoc = true,
			make = true,
			markdown = true,
			markdown_inline = true,
			meson = true,
			ninja = true,
			nix = true,
			perl = true,
			php = true,
			pug = true,
			python = true,
			query = true,
			regex = true,
			requirements = true,
			ruby = true,
			rust = true,
			scala = true,
			scss = true,
			sql = true,
			ssh_config = true,
			starlark = true,
			svelte = true,
			toml = true,
			typescript = true,
			vim = true,
			vimdoc = true,
			vue = true,
			xml = true,
			yaml = true,
			yuck = true,
			zig = true,
		},
		lsp_get_client = function(name, bufnr, all)
			local buf = nil
			local opts = {}
			if name then
				opts.name = name
			end
			if bufnr then
				opts.bufnr = buf
			end
			local clients = vim.lsp.get_clients(opts)
			if #clients == 0 then
				vim.notify("No " .. name .. " client found", vim.log.levels.WARN)
				return
			end
			if all then
				return clients
			end
			return clients[1]
		end,
		coroutine_wrap = function(fn)
			local co, is_main = coroutine.running()
			if co and not is_main then
				fn()
			else
				coroutine.wrap(function()
					xpcall(fn, function(err)
						local msg = debug.traceback(err, 2)
						vim.notify(msg, vim.log.levels.ERROR)
					end)
				end)()
			end
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
			local context = nil
			if bufnr then
				context = { bufnr = bufnr }
			end
			client:exec_cmd(command, context, handler)
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
			local selected_items = {}
			for _, value in pairs(options) do
				table.insert(choices, format(value))
			end
			MiniPick.start({
				source = {
					items = choices,
					name = prompt,
					choose_marked = function(items)
						for _, choice in pairs(items) do
							for _, value in pairs(options) do
								if format(value) == choice then
									table.insert(selected_items, value)
									break
								end
							end
						end
						return false
					end,
					choose = function(choice)
						for _, value in pairs(options) do
							if format(value) == choice then
								selected_items = { value }
							end
						end
						return false
					end,
				},
			})
			return selected_items
		end,
		select = function(prompt, options, format)
			local choices = {}
			local selected = {}
			for _, value in pairs(options) do
				table.insert(choices, format(value))
			end
			vim.ui.select(choices, { prompt = prompt }, function(choice)
				for _, value in pairs(options) do
					if format(value) == choice then
						selected = value
					end
				end
			end)
			return selected
		end,
		get_table_keys = function(t)
			local ret = {}
			for key, _ in pairs(t) do
				table.insert(ret, key)
			end
			return ret
		end,
	}
end)

-- Default settings
MiniMisc.safely("now", function()
	-- vim.cmd("let g:python_recommended_style=0")
	-- vim.o.colorcolumn = "150"
	-- vim.o.expandtab = true
	-- vim.o.relativenumber = true
	if vim.fn.has("nvim-0.12") == 1 then
		vim.cmd("packadd cfilter")
		vim.cmd("packadd justify")
		vim.cmd("packadd nohlsearch")
		vim.cmd("packadd nvim.difftool")
		vim.cmd("packadd nvim.undotree")
	end
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
	vim.o.statuscolumn = "%s%l%C "
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
	if vim.fn.has("nvim-0.12") == 1 then
		vim.o.pumborder = "rounded"
		require("vim._core.ui2").enable({
			msg = {
				targets = "cmd",
			},
		})
	end
end)

-- Mini plugins setup
MiniMisc.safely("now", function()
	require("mini.ai").setup({
		custom_textobjects = {
			B = require("mini.extra").gen_ai_spec.buffer(),
			D = require("mini.extra").gen_ai_spec.diagnostic(),
			I = require("mini.extra").gen_ai_spec.indent(),
			L = require("mini.extra").gen_ai_spec.line(),
			N = require("mini.extra").gen_ai_spec.number(),
		},
	})
	require("mini.align").setup()
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
			{ mode = "n", keys = "<Leader>" },
			{ mode = "n", keys = "[" },
			{ mode = "n", keys = "\\" },
			{ mode = "n", keys = "]" },
			{ mode = "n", keys = "`" },
			{ mode = "n", keys = "g" },
			{ mode = "n", keys = "z" },
			{ mode = "n", keys = '"' },
			{ mode = "x", keys = "'" },
			{ mode = "x", keys = "<Leader>" },
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
	require("mini.jump").setup()
	require("mini.jump2d").setup({
		labels = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
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
	-- MiniMisc.setup_termbg_sync()
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
	require("mini.operators").setup({
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
							#G.keys > 0 and "▕" or "",
							table.concat(G.keys, " ▏"),
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

-- Plugin installation hooks setup
MiniMisc.safely("now", function()
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(args)
			if args.data.spec.name == "nvim-treesitter" and args.data.kind == "update" then
				if not args.data.active then
					vim.cmd.packadd("nvim-treesitter")
				end
				vim.cmd("TSUpdate")
			end
		end,
	})
end)

-- Plugins setup
MiniMisc.safely("now", function()
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "everforest",
		callback = function()
			Hi("Pmenu", { link = "NormalFloat" })
			Hi("PmenuKind", { link = "Green" })
			Hi("PmenuExtra", { link = "Blue" })
		end,
	})
	vim.g.everforest_background = "medium"
	vim.g.everforest_transparent_background = 0
	vim.g.everforest_dim_inactive_windows = 0
	vim.g.everforest_float_style = "blend"
	vim.g.everforest_diagnostic_virtual_text = "colored"
	vim.g.everforest_current_word = "underline"
	vim.g.everforest_better_performance = 1
	vim.g.everforest_sign_column_background = "none"
	vim.pack.add({ "https://github.com/sainnhe/everforest" })
	vim.cmd.colorscheme("everforest")
	vim.pack.add({
		"https://github.com/nvim-treesitter/nvim-treesitter",
		"https://codeberg.org/mfussenegger/nvim-dap",
		"https://github.com/igorlfs/nvim-dap-view",
		"https://codeberg.org/mfussenegger/nluarepl",
		"https://github.com/nvim-treesitter/nvim-treesitter-context",
		"https://github.com/MeanderingProgrammer/render-markdown.nvim",
		"https://github.com/BlinkResearchLabs/blink-edit.nvim",
		"https://github.com/nickjvandyke/opencode.nvim",
		"https://github.com/neovim/nvim-lspconfig",
		"https://codeberg.org/mfussenegger/nvim-lint",
		"https://github.com/stevearc/conform.nvim",
		"https://github.com/Jezda1337/nvim-html-css",
	})
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
	require("nvim-treesitter").setup()
	require("nvim-treesitter").install(G.get_table_keys(G.languages)):wait(5 * 60 * 1000)
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
				return G.te_win
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
	require("blink-edit").setup({
		llm = {
			provider = "generic",
			backend = "ollama",
			url = "http://localhost:11434",
			model = "granite4:350m-h",
			temperature = 0.0,
			max_tokens = 256,
			timeout_ms = 5000,
		},
		context = {
			enabled = true,
			lines_before = nil,
			lines_after = nil,
			max_tokens = 512,
			selection = {
				enabled = true,
				max_lines = 10,
			},
			lsp = {
				enabled = true,
				max_definitions = 2,
				max_references = 2,
				timeout_ms = 100,
			},
			same_file = {
				enabled = true,
				max_lines_before = 20,
				max_lines_after = 20,
			},
			history = {
				enabled = false,
				max_items = 5,
				max_tokens = 512,
				max_files = 2,
				global = true,
			},
		},
		ui = {
			progress = false,
			suppress_lsp_floats = true,
		},
		prefetch = {
			enabled = false,
			strategy = "n-1",
		},
		normal_mode = {
			enabled = false,
			debounce_ms = 200,
		},
		debounce_ms = 100,
		keymaps = {
			insert = {
				accept = "<Tab>",
				accept_line = "<S-Tab>",
				clear = "<C-y>",
				reject = "<Esc>",
			},
			normal = {
				accept = "<Tab>",
				accept_line = "<S-Tab>",
			},
		},
	})
end)

-- Keymaps registration
MiniMisc.safely("now", function()
	local map_multistep = require("mini.keymap").map_multistep
	local map_combo = require("mini.keymap").map_combo
	local te_buf = nil
	local function open_terminal()
		if vim.fn.bufexists(te_buf) ~= 1 then
			vim.cmd("split | wincmd J | resize 10 | terminal")
			G.te_win = vim.fn.win_getid()
			te_buf = vim.fn.bufnr("%")
		elseif vim.fn.win_gotoid(G.te_win) ~= 1 then
			vim.cmd("sbuffer " .. te_buf .. "| wincmd J | resize 10")
			G.te_win = vim.fn.win_getid()
		end
		vim.cmd("startinsert")
	end
	local function hide_terminal()
		if vim.fn.win_gotoid(G.te_win) == 1 then
			vim.cmd("hide")
		end
	end
	local function toggle_terminal()
		if vim.fn.win_gotoid(G.te_win) == 1 then
			hide_terminal()
		else
			open_terminal()
		end
	end
	local te_float_buf = nil
	local previous_buf = nil
	local function open_float_terminal()
		previous_buf = vim.api.nvim_get_current_buf()
		local height = math.floor(0.6 * vim.o.lines)
		local width = math.floor(0.6 * vim.o.columns)
		G.te_float_win = vim.api.nvim_open_win(vim.api.nvim_get_current_buf(), true, {
			relative = "editor",
			row = math.floor(0.5 * (vim.o.lines - height)),
			col = math.floor(0.5 * (vim.o.columns - width)),
			width = math.floor(0.6 * vim.o.columns),
			height = math.floor(0.6 * vim.o.lines),
			focusable = true,
			title = " Float Term ",
			footer = " " .. vim.o.shell .. " ",
			footer_pos = "right",
		})
		vim.api.nvim_set_current_win(G.te_float_win)
		if vim.fn.bufexists(te_float_buf) ~= 1 then
			vim.cmd("terminal")
			te_float_buf = vim.api.nvim_get_current_buf()
		else
			vim.cmd("buffer " .. te_float_buf)
		end
		vim.cmd("startinsert")
	end
	local function hide_float_terminal()
		if vim.fn.win_gotoid(G.te_float_win) == 1 then
			vim.cmd("hide")
		end
		if previous_buf then
			vim.cmd("buffer " .. previous_buf)
			previous_buf = nil
		end
	end
	local function toggle_float_terminal()
		if vim.fn.win_gotoid(G.te_float_win) == 1 then
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
	local function toggle_quickfix()
		for _, win in ipairs(vim.fn.getwininfo()) do
			if win["quickfix"] == 1 then
				vim.cmd("cclose")
				return
			end
			vim.cmd("copen")
		end
	end
	local function toggle_loclist()
		for _, win in ipairs(vim.fn.getwininfo()) do
			if win["loclist"] == 1 then
				vim.cmd("lclose")
				return
			end
			vim.cmd("lopen")
		end
	end
	Imap("<C-\\>", "<cmd>lua vim.lsp.inline_completion.get()<CR>", "Accept inline completion")
	Map({ "x", "n" }, "<leader>as", require("opencode").select, "Send selected to opencode")
	Map({ "x", "n" }, "<leader>at", require("opencode").toggle, "Toggle opencode")
	Map({ "x", "v" }, "gx", '"+d', "Cut selection to clipboard")
	Map({ "x", "v", "n" }, "<leader>lf", require("conform").format, "Format code")
	Nmap("<C-Space><Space>", toggle_spaces, "Expand tabs")
	Nmap("<C-Space><Tab>", toggle_tabs, "Contract tabs")
	Nmap("<F2>", ":lua require('treesitter-context').go_to_context()<CR>", "Go to context")
	Nmap("<F3>", vim.pack.update, "Update vim plugins")
	Nmap("<F4>", ":Inspect<CR>", "Echo syntax group")
	Nmap("<F5>", ":TSContext toggle<CR>", "Toggle treesitter context")
	Nmap("<F6>", ":RenderMarkdown toggle<CR>", "Toggle markdown preview")
	Nmap("<Space><Space>", toggle_terminal, "Toggle terminal")
	Nmap("<Space><Tab>", toggle_float_terminal, "Toggle float terminal")
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
	Nmap("<leader>fM", ':Pick marks scope="all"<CR>', "Search workspace marks")
	Nmap("<leader>fS", ":Pick grep_live<CR>", "Search content live")
	Nmap("<leader>fT", ":Pick treesitter<CR>", "Search treesitter tree")
	Nmap("<leader>fX", ':Pick diagnostic scope="all"<CR>', "Search workspace diagnostics")
	Nmap("<leader>fY", ':Pick lsp scope="workspace_symbol"<CR>', "Search workspace symbols")
	Nmap("<leader>fb", ":Pick buffers<CR>", "Search buffers")
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
	Nmap("<leader>fx", ':Pick diagnostic scope="current"<CR>', "Search document diagnostics")
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
	Nmap("<leader>lgs", ":lua G.super_implementation()<CR>", "Goto super implementation")
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
	Nmap("gxx", '"+dd', "Cut line to clipboard")
	Nmap("gz", ":lua MiniDiff.toggle_overlay()<CR>", "Show diff")
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
	local special_file_types = {
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
	local html_file_types = {
		svelte = true,
		vue = true,
		jsx = true,
		tsx = true,
		html = true,
		xml = true,
		xsl = true,
		htmlangular = true,
	}
	local special_buftypes = {
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
			if G.languages[args.match] or html_file_types[args.match] then
				vim.treesitter.start()
				vim.wo.foldmethod = "expr"
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
			if html_file_types[vim.bo[args.buf].filetype] then
				vim.bo[args.buf].omnifunc = "htmlcomplete#CompleteTags"
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
			if special_file_types[vim.bo[args.buf].filetype] then
				vim.b[args.buf].minicursorword_disable = true
				vim.b[args.buf].miniindentscope_disable = true
				vim.b[args.buf].minitrailspace_disable = true
				vim.wo.listchars = "leadmultispace:  ,tab:  "
				MiniTrailspace.unhighlight()
				if vim.bo[args.buf].filetype == "dap-repl" then
					require("dap.ext.autocompl").attach()
				end
				if vim.bo[args.buf].filetype == "git" or vim.bo[args.buf].filetype == "diff" then
					vim.wo.signcolumn = "no"
					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.MiniGit.diff_foldexpr()"
				elseif vim.bo[args.buf].filetype == "query" and vim.bo[args.buf].buftype == "nofile" then
					vim.wo.signcolumn = "no"
				else
					vim.wo.foldcolumn = "0"
					vim.wo.signcolumn = "no"
					vim.wo.statuscolumn = ""
				end
			end
			local buftype = vim.bo[args.buf].buftype
			local filetype = vim.bo[args.buf].filetype
			if (buftype ~= "" or filetype ~= "") and not special_buftypes[buftype] then
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
			local b = args.data.buf_id
			Nmap("~", function()
				local path = (MiniFiles.get_fs_entry() or {}).path
				if path == nil then
					return vim.notify("Cursor is not on valid entry")
				end
				vim.fn.chdir(vim.fs.dirname(path))
			end, "Set cwd", { buffer = b })
			Nmap("yy", function()
				local path = (MiniFiles.get_fs_entry() or {}).path
				if path == nil then
					return vim.notify("Cursor is not on valid entry")
				end
				vim.fn.setreg("", path)
			end, "Yank path", { buffer = b })
			Nmap("gy", function()
				local path = (MiniFiles.get_fs_entry() or {}).path
				if path == nil then
					return vim.notify("Cursor is not on valid entry")
				end
				vim.fn.setreg("+", path)
			end, "Yank path", { buffer = b })
			local show_dotfiles = true
			Nmap(".", function()
				show_dotfiles = not show_dotfiles
				local new_filter = function(fs_entry)
					return show_dotfiles and true or not vim.startswith(fs_entry.name, ".")
				end
				MiniFiles.refresh({ content = { filter = new_filter } })
			end, "Toggle dotfiles", { buffer = b })
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
	vim.api.nvim_create_autocmd("CmdwinEnter", {
		callback = function()
			vim.wo.number = false
			vim.wo.foldcolumn = "0"
			vim.wo.signcolumn = "no"
		end,
	})
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			vim.hl.on_yank({
				timeout = 1000,
				on_macro = true,
			})
		end,
	})
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = { "*.scala" },
		callback = function()
			---@diagnostic disable-next-line: param-type-mismatch
			vim.lsp.buf_notify(0, "metals/didFocusTextDocument", vim.uri_from_bufnr(0))
		end,
	})
	vim.api.nvim_create_autocmd("BufReadCmd", {
		pattern = { "jdt://*", "*.class" },
		callback = function(args)
			local fname = args.match
			local uri
			local use_cmd
			if vim.startswith(fname, "jdt://") then
				uri = fname
				use_cmd = false
			else
				uri = vim.uri_from_fname(fname)
				use_cmd = true
				if not vim.startswith(uri, "file://") then
					return
				end
			end
			local buf = vim.api.nvim_get_current_buf()
			vim.bo[buf].modifiable = true
			vim.bo[buf].swapfile = false
			vim.bo[buf].buftype = "nofile"
			local class_fn = uri:match("contents/[^/]+/[%a%d._-]+/([^?]+)") or ""
			local class_ext = vim.fn.fnamemodify(class_fn, ":e")
			local filetype = "java"
			if class_ext ~= "class" and vim.filetype and vim.filetype.match then
				local ok, ft = pcall(vim.filetype.match, { filename = class_fn })
				if ok and ft then
					filetype = ft
				end
			end
			vim.bo[buf].filetype = filetype
			local timeout_ms = 5000
			local alt_buf = vim.fn.bufnr("#", -1)
			local client = G.lsp_get_client("jdtls", alt_buf)
			if not client then
				client = G.lsp_get_client("jdtls")
			end
			if not client then
				vim.wait(timeout_ms, function()
					return G.lsp_get_client("jdtls", buf) ~= nil
				end)
				client = G.lsp_get_client("jdtls", buf)
			else
				vim.lsp.buf_attach_client(buf, client.id)
			end
			if not client then
				vim.notify("Jdtls client not active", vim.log.levels.WARN)
				return
			end
			local content
			local function handler(err, result)
				if err then
					vim.notify("Error decompiling class files: " .. vim.inspect(err), vim.log.levels.ERROR)
					return
				end
				if not result then
					vim.notify("Jdtls did not return class file contents", vim.log.levels.ERROR)
					return
				end
				content = result
				local normalized = string.gsub(result, "\r\n", "\n")
				local source_lines = vim.split(normalized, "\n", { plain = true })
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, source_lines)
				vim.bo[buf].modifiable = false
			end
			if use_cmd then
				local command = {
					command = "java.decompile",
					arguments = { uri },
				}
				client:exec_cmd(command, nil, handler)
			else
				local params = {
					uri = uri,
				}
				---@diagnostic disable-next-line: param-type-mismatch
				client:request("java/classFileContents", params, handler, buf)
			end
			vim.wait(timeout_ms, function()
				return content ~= nil
			end)
		end,
	})
	vim.api.nvim_create_autocmd("BufWritePost", {
		callback = function()
			require("lint").try_lint()
		end,
	})
end)

-- Lsp configurations setup
MiniMisc.safely("now", function()
	local lsp_capabilities =
		vim.tbl_extend("force", vim.lsp.protocol.make_client_capabilities(), MiniCompletion.get_lsp_capabilities())
	lsp_capabilities.general.positionEncodings = { G.offset_encoding }
	local lua_runtime_files = vim.api.nvim_get_runtime_file("", true)
	for k, v in ipairs(lua_runtime_files) do
		if v == vim.fn.stdpath("config") then
			table.remove(lua_runtime_files, k)
		end
	end
	table.insert(lua_runtime_files, "${3rd}/luv/library")
	-- table.insert(lua_runtime_files, "$${3rd}/busted/library")
	local extra_code_action_literals = {
		"source.generate.toString",
		"source.generate.hashCodeEquals",
		"source.organizeImports",
	}
	local code_action_literals = vim.tbl_get(
		lsp_capabilities,
		"textDocument",
		"codeAction",
		"codeActionLiteralSupport",
		"codeActionKind",
		"valueSet"
	) or {}
	for _, extra_literal in ipairs(extra_code_action_literals) do
		if not vim.tbl_contains(code_action_literals, extra_literal) then
			table.insert(code_action_literals, extra_literal)
		end
	end
	local extra_capabilities = {
		textDocument = {
			codeAction = {
				codeActionLiteralSupport = {
					codeActionKind = {
						valueSet = code_action_literals,
					},
				},
			},
		},
	}
	local jdtls_capabilities = vim.tbl_deep_extend("force", lsp_capabilities, extra_capabilities)
	local bundles = {}
	vim.list_extend(bundles, vim.split(vim.fn.glob("/usr/share/java-debug/*.jar", true), "\n"))
	-- vim.list_extend(bundles, vim.split(vim.fn.glob("/usr/share/java-test/*.jar", true), "\n"))
	local function get_jdtls_cache_dir()
		return vim.fn.stdpath("cache") .. "/jdtls"
	end
	local function get_jdtls_workspace_dir()
		return get_jdtls_cache_dir() .. "/workspace"
	end
	local function get_jdtls_jvm_args()
		local env = os.getenv("JDTLS_JVM_ARGS")
		local args = {}
		for a in string.gmatch((env or ""), "%S+") do
			local arg = string.format("--jvm-arg=%s", a)
			table.insert(args, arg)
		end
		local lombok_path = "/usr/share/java/lombok/lombok.jar"
		if vim.uv.fs_stat(lombok_path) then
			table.insert(args, string.format("--jvm-arg=-javaagent:%s", lombok_path))
		end
		return unpack(args)
	end
	local function get_jdtls_java_executable()
		return "/usr/lib/jvm/java-21-openjdk/bin/java"
	end
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
		metals = {
			---@type lspconfig.settings.metals
			settings = {
				metals = {
					-- mavenScript = "/usr/local/bin/mvn",
					-- gradleScript = "/usr/local/bin/gradle",
					-- javaHome = "/usr/lib/jvm/default",
					-- scalaCliLauncher = "/usr/local/bin/scala-cli",
					-- bloopJvmProperties = "",
					-- autoImportBuild = "all",
					-- enableBestEffort = true, -- scala 3 only
					inlayHints = {
						hintsInPatternMatch = { enable = true },
						implicitArguments = { enable = true },
						implicitConversions = { enable = true },
						inferredTypes = { enable = true },
						typeParameters = { enable = true },
						namedParameters = { enable = true },
						byNameParameters = { enable = true },
					},
					defaultBspToBuildTool = true, -- when using sbt or mill
				},
			},
			init_options = {
				debuggingProvider = true,
				executeClientCommandProvider = true,
				inputBoxProvider = true,
				quickPickProvider = true,
				doctorProvider = "json",
				doctorVisibilityProvider = true,
				disableColorOutput = true,
				statusBarProvider = "off",
			},
			handlers = {
				["metals/quickPick"] = function(_, result)
					local ids = {}
					local labels = {}
					local selected
					for _, item in pairs(result.items) do
						table.insert(ids, item.id)
						table.insert(labels, item.label)
					end
					selected = G.select("Pick", labels, function(x)
						return x
					end)
					if not selected then
						return { cancelled = true }
					else
						for i, item in pairs(labels) do
							if selected == item then
								return { itemId = ids[i] }
							end
						end
					end
				end,
				["metals/inputBox"] = function(_, result)
					local args = { prompt = result.prompt .. ": " }
					if result.value then
						args.default = result.value
					end
					local name = vim.fn.input(args)
					if name == "" then
						return { cancelled = true }
					else
						return { value = name }
					end
				end,
			},
		},
		jdtls = {
			filetypes = { "java", "jproperties" },
			cmd = function(dispatchers, config)
				local data_dir = get_jdtls_workspace_dir()
				if config.root_dir then
					data_dir = data_dir .. "/" .. vim.fn.fnamemodify(config.root_dir, ":p:h:t")
				end
				local config_cmd = {
					"jdtls",
					"--java-executable",
					get_jdtls_java_executable(),
					"-data",
					data_dir,
					get_jdtls_jvm_args(),
				}
				return vim.lsp.rpc.start(config_cmd, dispatchers, {
					cwd = config.cmd_cwd,
					env = config.cmd_env,
					detached = config.detached,
				})
			end,
			capabilities = jdtls_capabilities,
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
				bundles = bundles,
				extendedClientCapabilities = {
					classFileContentsSupport = true,
					snippetEditSupport = true,
					executeClientCommandSupport = true,
					overrideMethodsPromptSupport = true,
					hashCodeEqualsPromptSupport = true,
					generateToStringPromptSupport = true,
					generateDelegateMethodsPromptSupport = true,
					generateConstructorsPromptSupport = true,
					advancedOrganizeImportsSupport = true,
				},
			},
			handlers = {
				["workspace/executeClientCommand"] = function(_, params, ctx)
					local client = vim.lsp.get_client_by_id(ctx.client_id) or {}
					local commands = client.commands or {}
					local global_commands = vim.lsp.commands or {}
					local fn = commands[params.command] or global_commands[params.command]
					if fn then
						local ok, result = pcall(fn, params.arguments, ctx)
						if ok then
							return result
						else
							return vim.lsp.rpc_response_error(vim.lsp.protocol.ErrorCodes.InternalError, result)
						end
					else
						return vim.lsp.rpc_response_error(
							vim.lsp.protocol.ErrorCodes.MethodNotFound,
							"Command " .. params.command .. " not supported on client"
						)
					end
				end,
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
	local commands = {
		["java.apply.workspaceEdit"] = function(command)
			for _, argument in ipairs(command.arguments) do
				vim.lsp.util.apply_workspace_edit(argument, G.offset_encoding)
			end
		end,
		["java.show.references"] = function(args)
			local arguments = args.arguments
			local locations = arguments[3]
			local items = vim.lsp.util.locations_to_items(locations, G.offset_encoding)
			local list = {
				title = "References",
				items = items,
			}
			vim.fn.setqflist({}, " ", list)
			vim.cmd("botright copen")
		end,
		["java.action.generateToStringPrompt"] = function(_, ctx)
			local params = ctx.params
			if not ctx.bufnr then
				vim.notify("'ctx' does not have a buffer", vim.log.levels.WARN)
				return
			end
			local bufnr = ctx.bufnr
			local client = G.lsp_get_client("jdtls", bufnr)
			if not client then
				return
			end
			G.coroutine_wrap(function()
				local err, result = G.lsp_client_request(client, "java/checkToStringStatus", params, bufnr)
				if err then
					vim.notify("Could not execute java/checkToStringStatus: " .. err.message, vim.log.levels.WARN)
					return
				end
				if not result then
					return
				end
				if result.exists then
					local prompt = string.format(
						"Method toString() already exists in '%s'. Do you want to replace it?",
						result.type
					)
					local choice = G.select(prompt, { "Yes", "No" }, function(x)
						return x
					end)
					if choice == "No" then
						return
					end
				end
				local items = G.multi_select("Generate toString for which items?", result.fields, function(x)
					return string.format("%s: %s", x.name, x.type)
				end)
				local err1, edit =
					G.lsp_client_request(client, "java/generateToString", { context = params, fields = items }, bufnr)
				if err1 then
					vim.notify("Could not execute java/generateToString: " .. err1.message, vim.log.levels.WARN)
				elseif edit then
					vim.lsp.util.apply_workspace_edit(edit, G.offset_encoding)
				end
			end)
		end,
		["java.action.hashCodeEqualsPrompt"] = function(_, ctx)
			if not ctx.bufnr then
				vim.notify("'ctx' does not have a buffer", vim.log.levels.WARN)
				return
			end
			local bufnr = ctx.bufnr
			local params = ctx.params
			local client = G.lsp_get_client("jdtls", bufnr)
			if not client then
				return
			end
			G.coroutine_wrap(function()
				local _, result = G.lsp_client_request(client, "java/checkHashCodeEqualsStatus", params, bufnr)
				if not result then
					vim.notify("No result for java/checkHashCodeEqualsStatus", vim.log.levels.INFO)
					return
				elseif not result.fields or #result.fields == 0 then
					vim.notify(
						string.format("The operation is not applicable to the type %", result.type),
						vim.log.levels.WARN
					)
					return
				end
				local items = G.multi_select("Generate hashCodeEquals for which items?", result.fields, function(x)
					return string.format("%s: %s", x.name, x.type)
				end)
				local err1, edit = G.lsp_client_request(
					client,
					"java/generateHashCodeEquals",
					{ context = params, fields = items },
					bufnr
				)
				if err1 then
					vim.notify("Could not execute java/generateHashCodeEquals: " .. err1.message, vim.log.levels.WARN)
				elseif edit then
					vim.lsp.util.apply_workspace_edit(edit, G.offset_encoding)
				end
			end)
		end,
		["java.action.rename"] = function(command, ctx)
			local target = command.arguments[1]
			local win = vim.api.nvim_get_current_win()
			local bufnr = vim.api.nvim_win_get_buf(win)
			if bufnr ~= ctx.bufnr then
				return
			end
			local lines = vim.api.nvim_buf_get_lines(ctx.bufnr, 0, -1, true)
			local content = table.concat(lines, "\n")
			local byteidx = vim.fn.byteidx(content, target.offset)
			local line = vim.fn.byte2line(byteidx)
			local col = byteidx - vim.fn.line2byte(line)
			vim.api.nvim_win_set_cursor(win, { line, col + 1 })
		end,
		["java.action.organizeImports"] = function(_, ctx)
			if not ctx.bufnr then
				vim.notify("'ctx' does not have a buffer", vim.log.levels.WARN)
				return
			end
			local bufnr = ctx.bufnr
			local client = G.lsp_get_client("jdtls", bufnr)
			if not client then
				return
			end
			G.coroutine_wrap(function()
				local err, result = G.lsp_client_request(client, "java/organizeImports", ctx.params, bufnr)
				if err then
					vim.notify("Error on organize imports: " .. err.message, vim.log.levels.WARN)
					return
				end
				if result then
					vim.lsp.util.apply_workspace_edit(result, G.offset_encoding)
				end
			end)
		end,
		["java.action.generateConstructorsPrompt"] = function(_, ctx)
			if not ctx.bufnr then
				vim.notify("'ctx' does not have a buffer", vim.log.levels.WARN)
				return
			end
			local bufnr = ctx.bufnr
			local client = G.lsp_get_client("jdtls", bufnr)
			if not client then
				return
			end
			G.coroutine_wrap(function()
				local err, result = G.lsp_client_request(client, "java/checkConstructorsStatus", ctx.params, bufnr)
				if err then
					vim.notify("Could not execute java/checkConstructorsStatus: " .. err.message, vim.log.levels.WARN)
					return
				end
				if not result or not result.constructors or #result.constructors == 0 then
					return
				end
				local constructors = result.constructors
				if #result.constructors > 1 then
					constructors = G.multi_select(
						"Include what super class constructor?",
						result.constructors,
						function(x)
							return string.format("%s(%s)", x.name, table.concat(x.parameters, ","))
						end
					)
					if not constructors or #constructors == 0 then
						return
					end
				end
				local fields = result.fields
				if fields then
					fields = G.multi_select("Include what fields in constructor?", fields, function(x)
						return string.format("%s: %s", x.name, x.type)
					end)
				end
				local params = {
					context = ctx.params,
					constructors = constructors,
					fields = fields,
				}
				local err1, edit = G.lsp_client_request(client, "java/generateConstructors", params, bufnr)
				if err1 then
					vim.notify("Could not execute java/generateConstructors: " .. err1.message, vim.log.levels.WARN)
				elseif edit then
					vim.lsp.util.apply_workspace_edit(edit, G.offset_encoding)
				end
			end)
		end,
		["java.action.generateDelegateMethodsPrompt"] = function(_, ctx)
			if not ctx.bufnr then
				vim.notify("'ctx' does not have a buffer", vim.log.levels.WARN)
				return
			end
			local bufnr = ctx.bufnr
			local client = G.lsp_get_client("jdtls", bufnr)
			if not client then
				return
			end
			G.coroutine_wrap(function()
				local err, status = G.lsp_client_request(client, "java/checkDelegateMethodsStatus", ctx.params, bufnr)
				if err then
					vim.notify(
						"Could not execute java/checkDelegateMethodsStatus: " .. err.message,
						vim.log.levels.WARN
					)
					return
				end
				if not status or not status.delegateFields or #status.delegateFields == 0 then
					vim.notify("All delegatable fields are already implemented", vim.log.levels.INFO)
					return
				end
				local field = #status.delegateFields == 1 and status.delegateFields[1]
					or G.select("Select target to generate delegates for?", status.delegateFields, function(x)
						return string.format("%s: %s", x.field.name, x.field.type)
					end)
				if not field then
					return
				end
				if #field.delegateMethods == 0 then
					vim.notify("All delegatable methods are already implemented", vim.log.levels.INFO)
					return
				end
				local methods = G.multi_select(
					"Generate delegate for which methods?",
					field.delegateMethods,
					function(x)
						return string.format("%s(%s)", x.name, table.concat(x.parameters, ","))
					end
				)
				if not methods or #methods == 0 then
					return
				end
				local params = {
					context = ctx.params,
					delegateEntries = vim.tbl_map(function(x)
						return {
							field = field.field,
							delegateMethod = x,
						}
					end, methods),
				}
				local err1, workspace_edit = G.lsp_client_request(client, "java/generateDelegateMethods", params, bufnr)
				if err1 then
					vim.notify("Could not execute java/generateDelegateMethods: " .. err1.message, vim.log.levels.WARN)
				elseif workspace_edit then
					vim.lsp.util.apply_workspace_edit(workspace_edit, G.offset_encoding)
				end
			end)
		end,
		["java.action.overrideMethodsPrompt"] = function(_, ctx)
			if not ctx.bufnr then
				vim.notify("'ctx' does not have a buffer", vim.log.levels.WARN)
				return
			end
			local bufnr = ctx.bufnr
			local client = G.lsp_get_client("jdtls", bufnr)
			if not client then
				return
			end
			G.coroutine_wrap(function()
				local err, result = G.lsp_client_request(client, "java/listOverridableMethods", ctx.params, bufnr)
				if err then
					vim.notify("Error getting overridable methods: " .. err.message, vim.log.levels.WARN)
					return
				end
				if not result or not result.methods then
					vim.notify("No methods to override", vim.log.levels.INFO)
					return
				end
				local items = G.multi_select("Methods to override?", result.methods, function(x)
					return string.format("%s(%s) class: %s", x.name, table.concat(x.parameters, ", "), x.declaringClass)
				end)
				if #items < 1 then
					return
				end
				local params = {
					context = ctx.params,
					overridableMethods = items,
				}
				local err1, edit = G.lsp_client_request(client, "java/addOverridableMethods", params, bufnr)
				if err1 then
					print("Error getting workspace edits: " .. err1.message)
					return
				end
				if edit then
					vim.lsp.util.apply_workspace_edit(edit, G.offset_encoding)
				end
			end)
		end,
	}
	if vim.lsp.commands then
		for k, v in pairs(commands) do
			vim.lsp.commands[k] = v
		end
	end
	G.super_implementation = function()
		if vim.bo.filetype == "java" then
			G.coroutine_wrap(function()
				local params = {
					type = "superImplementation",
					position = vim.lsp.util.make_position_params(vim.api.nvim_get_current_win(), G.offset_encoding),
				}
				local bufnr = vim.api.nvim_get_current_buf()
				local err, result =
					G.lsp_client_request(G.lsp_get_client("jdtls", bufnr), "java/findLinks", params, bufnr)
				if err then
					vim.notify("Error getting super implementation: " .. err.message, vim.log.levels.WARN)
					return
				end
				if result and #result == 1 then
					vim.lsp.util.show_document(result[1], G.offset_encoding, { focus = true })
				end
			end)
		elseif vim.bo.filetype == "scala" then
			G.coroutine_wrap(function()
				local params = vim.lsp.util.make_position_params(vim.api.nvim_get_current_win(), G.offset_encoding)
				local bufnr = vim.api.nvim_get_current_buf()
				G.lsp_client_exec_cmd(G.lsp_get_client("metals", bufnr), {
					command = "goto-super-method",
					arguments = { params },
				}, bufnr)
			end)
		else
			vim.notify("Super implementation not supported for this language", vim.log.levels.INFO)
		end
	end
end)

-- Linting and formatting setup
MiniMisc.safely("later", function()
	require("lint").linters_by_ft = {
		-- astro = { "eslint" },
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
		-- tsx = { "eslint" },
		-- typescript = { "eslint" },
		-- vue = { "eslint" },
	}
	require("conform").setup({
		formatters_by_ft = {
			c = { "clang-format" },
			css = { "prettier" },
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
			python = { "black" },
			scala = { "scalafmt" },
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
	dap.adapters["metals-scala-debug"] = function(callback, config)
		local bufnr = vim.api.nvim_get_current_buf()
		local client = G.lsp_get_client("metals", bufnr)
		if not client then
			return
		end
		client:exec_cmd({
			title = "debug-metals-scala",
			command = "debug-adapter-start",
			arguments = {
				hostName = config.hostName,
				port = config.port,
				buildTarget = config.buildTarget,
			},
		}, { bufnr = bufnr }, function(_, res)
			if res and res.uri then
				callback({
					type = "server",
					hostName = "127.0.0.1",
					port = vim.split(res.uri, ":", { trimempty = true })[3],
					options = {
						initialize_timeout_sec = 10,
					},
				})
			else
				vim.notify("Could not get uri to parse", vim.log.levels.ERROR)
			end
		end)
	end
	dap.adapters["jdtls-java-debug"] = function(callback, _)
		local bufnr = vim.api.nvim_get_current_buf()
		local client = G.lsp_get_client("jdtls", bufnr)
		if not client then
			return
		end
		client:exec_cmd(
			{ title = "debug-jdtls-java", command = "vscode.java.startDebugSession" },
			{ bufnr = bufnr },
			function(err, res_port)
				if err then
					vim.notify("Error starting jdtls debug adapter: " .. err.message, vim.log.levels.WARN)
					return
				end
				callback({
					type = "server",
					hostName = "127.0.0.1",
					port = res_port,
				})
			end
		)
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
			type = "jdtls-java-debug",
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
	-- java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005 -jar scala.jar
	-- TODO mvnDebug scala:run -Dexec.mainClass="com.mycompany.app.App"
	dap.configurations.scala = {
		{
			type = "metals-scala-debug",
			name = "Attach remote",
			mode = "remote",
			request = "attach",
			hostName = function()
				return vim.fn.input("Enter host: ", "127.0.0.1")
			end,
			port = function()
				return vim.fn.input("Enter port: ", tostring(5005))
			end,
			buildTarget = function()
				return vim.fn.input(
					"Enter build target[artifact id in pom.xml or name of the json file in .bloop folder]: ",
					"example"
				)
			end,
		},
	}
	-- node --inspect-brk=127.0.0.1:9229 main.js
	for _, language in ipairs({ "typescript", "javascript" }) do
		dap.configurations[language] = {
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
		local has_ts, _ = pcall(require, "nvim-treesitter")
		if not has_ts then
			vim.notify("Treesitter_symbols picker requires nvim-treesitter.", vim.log.levels.ERROR)
			return
		end
		local buf = vim.api.nvim_get_current_buf()
		if not vim.bo[buf].filetype then
			vim.notify("Cannot determine filetype for current buffer.", vim.log.levels.ERROR)
			return
		end
		local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
		if not lang then
			vim.notify("Cannot determine treesitter language for current buffer.", vim.log.levels.ERROR)
			return
		end
		local parser = vim.treesitter.get_parser(buf)
		if not parser then
			vim.notify("Cannot get parser for current buffer.", vim.log.levels.ERROR)
			return
		end
		parser:parse()
		local root = parser:trees()[1]:root()
		if not root then
			vim.notify("Cannot get tree root for current buffer.", vim.log.levels.ERROR)
			return
		end
		local locals_query = (vim.treesitter.query.get(lang, "locals"))
		if not locals_query then
			vim.notify("Cannot get locals queries for current buffer.", vim.log.levels.ERROR)
			return
		end
		local get = function(bufnr)
			local definitions = {}
			local scopes = {}
			local references = {}
			for id, node, metadata in locals_query:iter_captures(root, bufnr) do
				local kind = locals_query.captures[id]
				local scope = "local"
				for k, v in pairs(metadata) do
					if type(k) == "string" and vim.endswith(k, "local.scope") then
						scope = v
					end
				end
				if node and vim.startswith(kind, "local.definition") then
					table.insert(definitions, { kind = kind, node = node, scope = scope })
				end
				if node and kind == "local.scope" then
					table.insert(scopes, node)
				end
				if node and kind == "local.reference" then
					table.insert(references, { kind = kind, node = node, scope = scope })
				end
			end
			return definitions, references, scopes
		end
		local function recurse_local_nodes(local_def, accumulator, full_match, last_match)
			if type(local_def) ~= "table" then
				return
			end
			if local_def.node then
				accumulator(local_def, local_def.node, full_match, last_match)
			else
				for match_key, def in pairs(local_def) do
					recurse_local_nodes(
						def,
						accumulator,
						full_match and (full_match .. "." .. match_key) or match_key,
						match_key
					)
				end
			end
		end
		local get_local_nodes = function(local_def)
			local result = {}
			recurse_local_nodes(local_def, function(def, _, kind)
				table.insert(result, vim.tbl_extend("keep", { kind = kind }, def))
			end)
			return result
		end
		local kind_map = {
			var = "variable",
			parameter = "constant",
			associated = "object",
		}
		local entries = {}
		for _, definition in ipairs(get(buf)) do
			local nodes = get_local_nodes(definition)
			for _, node in ipairs(nodes) do
				if node.node then
					node.kind = node.kind and node.kind:gsub(".*%.", "")
					local lnum, col, end_lnum, end_col = vim.treesitter.get_node_range(node.node)
					local node_text = vim.treesitter.get_node_text(node.node, buf)
					local node_kind = node.kind or ""
					node_kind = kind_map[node_kind] or node_kind
					local icon, hl, _ = MiniIcons.get("lsp", node_kind)
					entries[#entries + 1] = {
						text = string.format("[%s %s] %s", icon, node_kind, node_text),
						hl = hl,
						bufnr = buf,
						lnum = lnum + 1,
						col = col + 1,
						end_lnum = end_lnum + 1,
						end_col = end_col + 1,
					}
				end
			end
		end
		local mini_extra_namespace = vim.api.nvim_get_namespaces()["MiniExtraPickers"]
		MiniPick.start(vim.tbl_deep_extend("force", opts or {}, {
			source = {
				items = entries,
				name = "Tree-sitter symbols",
				show = function(buf_id, items_to_show, query)
					MiniPick.default_show(buf_id, items_to_show, query)
					vim.api.nvim_buf_clear_namespace(buf_id, mini_extra_namespace, 0, -1)
					for i, item in ipairs(items_to_show) do
						vim.api.nvim_buf_set_extmark(
							buf_id,
							mini_extra_namespace,
							i - 1,
							0,
							{ end_row = i, end_col = 0, hl_mode = "blend", hl_group = item.hl, priority = 100 }
						)
					end
				end,
			},
		}))
	end
	vim.on_key(function(_, typed)
		if typed ~= "" then
			local typed_key = vim.fn.keytrans(typed)
			if #G.keys == 0 then
				table.insert(G.keys, typed_key)
			else
				local key_string = vim.split(G.keys[#G.keys], " ", { plain = true })
				local last_key = #key_string == 2 and key_string[2] or key_string[1]
				if last_key == typed_key then
					G.keys[#G.keys] = #key_string == 2 and tostring(tonumber(key_string[1]) + 1) .. " " .. typed_key
						or "2" .. " " .. typed_key
				else
					if #G.keys >= 5 then
						table.remove(G.keys, 1)
					end
					table.insert(G.keys, typed_key)
				end
			end
			vim.api.nvim__redraw({ statusline = true })
		end
	end)
	local diff_highlight_namespace = vim.api.nvim_create_namespace("DiffHighlight")
	local function diff_highlight()
		if vim.bo.filetype ~= "diff" and vim.bo.filetype ~= "patch" then
			return
		end
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
		table.insert(lines, " ")
		local function apply_partial_hunk_ext_marks(changes, diff_start, diff_lines, highlight, priority, hl_mode)
			if diff_lines ~= 0 then
				for _, change in ipairs(changes) do
					if change.char_count_post >= diff_start then
						local cur_line = change.line
						local col = diff_start - change.char_count_pre - 1
						local remaining = diff_lines
						while remaining > 0 and cur_line <= #lines do
							local line_len = #lines[cur_line]
							local end_col = col + remaining
							if end_col > line_len then
								vim.api.nvim_buf_set_extmark(0, diff_highlight_namespace, cur_line - 1, col, {
									end_row = cur_line - 1,
									end_col = line_len,
									hl_mode = hl_mode,
									hl_group = highlight,
									priority = priority,
								})
								remaining = remaining - (line_len - col)
								col = 0
								cur_line = cur_line + 1
							else
								vim.api.nvim_buf_set_extmark(0, diff_highlight_namespace, cur_line - 1, col, {
									end_row = cur_line - 1,
									end_col = end_col,
									hl_mode = hl_mode,
									hl_group = highlight,
									priority = priority,
								})
								remaining = 0
							end
						end
						break
					end
				end
			end
		end
		local function apply_hunk_ext_marks(changes)
			local minus_string = ""
			local plus_string = ""
			for _, minus_change in ipairs(changes.minus) do
				for char in minus_change.content:gmatch(".") do
					minus_string = minus_string .. char .. "\n"
				end
			end
			for _, plus_change in ipairs(changes.plus) do
				for char in plus_change.content:gmatch(".") do
					plus_string = plus_string .. char .. "\n"
				end
			end
			local hunk = vim.text.diff(minus_string, plus_string, { result_type = "indices" })
			if type(hunk) == "table" then
				for _, diff in ipairs(hunk) do
					apply_partial_hunk_ext_marks(changes.minus, diff[1], diff[2], "DiffDelete", 100, "blend")
					apply_partial_hunk_ext_marks(changes.plus, diff[3], diff[4], "DiffAdd", 100, "blend")
				end
			end
		end
		local minus = {}
		local plus = {}
		local i = 1
		while i <= #lines do
			if lines[i]:sub(1, 1) == "@" then
				local minus_content_char_count = 0
				local plus_content_char_count = 0
				while i <= #lines and lines[i]:sub(1, 5) ~= "index" do
					if lines[i]:sub(1, 1) == "-" then
						local content = "@" .. lines[i]:sub(2)
						local minus_change = {
							line = i,
							content = content,
							char_count_pre = minus_content_char_count,
							char_count_post = minus_content_char_count + #content,
						}
						table.insert(minus, minus_change)
						minus_content_char_count = minus_change.char_count_post
					elseif lines[i]:sub(1, 1) == "+" then
						local content = "@" .. lines[i]:sub(2)
						local plus_change = {
							line = i,
							content = content,
							char_count_pre = plus_content_char_count,
							char_count_post = plus_content_char_count + #content,
						}
						table.insert(plus, plus_change)
						plus_content_char_count = plus_change.char_count_post
					else
						if #minus ~= 0 and #plus ~= 0 then
							apply_hunk_ext_marks({
								minus = minus,
								plus = plus,
							})
						end
						minus = {}
						plus = {}
						minus_content_char_count = 0
						plus_content_char_count = 0
					end
					i = i + 1
				end
				i = i + 2
			end
			i = i + 1
		end
	end
	Nmap("gZ", diff_highlight, "Highlight word diff in diff files")
end)
