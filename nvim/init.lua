-- luacheck global variables declaration
-- luacheck: globals vim
-- luacheck: globals Global Map Vscode Tmap Cmap Nmap Vmap Imap Smap Xmap Hi
-- luacheck: globals MiniPick MiniBracketed MiniIcons MiniMisc MiniNotify MiniCompletion MiniTrailspace
-- luacheck: globals MiniDeps MiniStatusline MiniVisits MiniSnippets MiniExtra MiniFiles

-- MiniDeps auto download setup
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/opt/mini.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.uv.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/echasnovski/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end
-- Add mini.nvim to runtime
vim.cmd("packadd mini.nvim | helptags ALL")

-- Setup MiniDeps
require("mini.deps").setup({ path = { package = path_package } })
-- Export add, now and later functions from MiniDeps
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
-- Track and update self
add("echasnovski/mini.nvim")

-- Vscode neovim settings
if vim.g.vscode then
	local vscode = require("vscode")
	-- Helper functions
	Map = function(modes, suffix, rhs, desc, opts)
		opts = opts or {}
		opts.silent = true
		opts.desc = desc
		vim.keymap.set(modes or { "n" }, suffix, rhs, opts)
	end
	Vscode = function(cmd)
		return function()
			vscode.action(cmd)
		end
	end
	-- Settings
	vim.g.loaded_matchparen = 1
	vim.opt.matchpairs:append("<:>")
	vim.notify = vscode.notify
	-- Plugins installation
	add("vscode-neovim/vscode-multi-cursor.nvim")
	-- Plugins configuration
	require("vscode-multi-cursor").setup({
		default_mappings = true,
	})
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
	require("mini.bracketed").setup()
	require("mini.comment").setup()
	require("mini.extra").setup()
	require("mini.indentscope").setup({
		draw = {
			animation = require("mini.indentscope").gen_animation.none(),
		},
	})
	require("mini.jump").setup()
	require("mini.jump2d").setup()
	require("mini.keymap").setup()
	require("mini.move").setup({
		mappings = {
			left = "H",
			right = "L",
			down = "J",
			up = "K",
			line_left = "H",
			line_right = "L",
			line_down = "J",
			line_up = "K",
		},
		options = {
			reindent_linewise = true,
		},
	})
	require("mini.operators").setup()
	require("mini.splitjoin").setup()
	require("mini.surround").setup()
	-- Keymaps
	local error_diagnostic_cycle = function(direction)
		return function()
			MiniBracketed.diagnostic(direction, { severity = vim.diagnostic.severity.ERROR })
		end
	end
	Map(nil, "[e", error_diagnostic_cycle("backward"), "Error last")
	Map(nil, "]e", error_diagnostic_cycle("forward"), "Error forward")
	Map(nil, "gB", ":norm gxiagxila<CR>", "Move arg left")
	Map(nil, "gb", ":norm gxiagxina<CR>", "Move arg right")
	Map(nil, "<Space>D", Vscode("editor.action.peekDefinition"), "Peek definition")
	Map(nil, "<Space>F", Vscode("editor.action.revealDeclaration"), "Show declaration")
	Map(nil, "<Space>I", Vscode("editor.action.peekImplementation"), "Show implementations")
	Map(nil, "<Space>R", Vscode("editor.action.rename"), "Rename")
	Map(nil, "<Space>d", Vscode("editor.action.revealDefinition"), "Show definition")
	Map(nil, "<Space>f", Vscode("editor.action.peekDeclaration"), "Peek declaration")
	Map(nil, "<Space>h", Vscode("editor.showCallHierarchy"), "Show call hierarchy")
	Map(nil, "<Space>i", Vscode("editor.action.goToImplementation"), "Show implementations")
	Map(nil, "<Space>k", Vscode("editor.action.showHover"), "Show hover")
	Map(nil, "<Space>o", Vscode("workbench.action.gotoSymbol"), "Goto symbol")
	Map(nil, "<Space>r", Vscode("editor.action.referenceSearch.trigger"), "Show references")
	Map(nil, "<Space>t", Vscode("editor.showTypeHierarchy"), "Show type hierarchy")
	Map(nil, "<Space>tD", Vscode("editor.action.peekTypeDefinition"), "Peek type definition")
	Map(nil, "<Space>td", Vscode("editor.action.goToTypeDefinition"), "Goto type definition")
	Map(nil, "zC", Vscode("editor.foldRecursively"), "Fold")
	Map(nil, "zM", Vscode("editor.foldAll"), "Fold")
	Map(nil, "zO", Vscode("editor.unfoldRecursively"), "Unfold")
	Map(nil, "zR", Vscode("editor.unfoldAll"), "Unfold")
	Map(nil, "zc", Vscode("editor.fold"), "Fold")
	Map(nil, "zc", Vscode("editor.fold"), "Fold")
	Map(nil, "zo", Vscode("editor.unfold"), "Unfold")
	Map(nil, "zo", Vscode("editor.unfold"), "Unfold")
	Map({ "n", "v", "x" }, "<Space>F", Vscode("editor.action.formatDocument"), "Format document")
	Map({ "n", "v", "x" }, "zP", '"+P', "Paste to clipboard")
	Map({ "n", "v", "x" }, "zX", '"+X', "Cut to clipboard")
	Map({ "n", "v", "x" }, "zY", '"+Y', "Copy to clipboard")
	Map({ "n", "v", "x" }, "zp", '"+p', "Paste to clipboard")
	Map({ "n", "v", "x" }, "zx", '"+x', "Cut to clipboard")
	Map({ "n", "v", "x" }, "zy", '"+y', "Copy to clipboard")
	-- Goto ending of file
	goto skip_neovim_config
end

-- Globals variables and functions declared and used
now(function()
	Global = {
		-- Space, tab and fold characters to use
		lead_space = "·",
		next_space = " ",
		te_win_id = -1,
		winbar_arrow = "󰁔",
		status_column_separator = "│", -- ▕
		lead_tab_space = "›", -- »
		fold_open = "▾", -- 
		fold_close = "▸", -- 
		float_multiplier = 0.8,
		offset_encoding = "utf-16",
		palette = {
			base00 = "#282C34",
			base01 = "#353B45",
			base02 = "#3E4451",
			base03 = "#545862",
			base04 = "#565C64",
			base05 = "#ABB2BF",
			base06 = "#B6BDCA",
			base07 = "#C8CCD4",
			base08 = "#E06C75",
			base09 = "#D19A66",
			base0A = "#E5C07B",
			base0B = "#98C379",
			base0C = "#56B6C2",
			base0D = "#61AFEF",
			base0E = "#C678DD",
			base0F = "#BE5046",
		},
		languages = {
			"angular",
			"awk",
			"bash",
			"bibtex",
			"c",
			"cmake",
			"cpp",
			"css",
			"csv",
			"diff",
			"dockerfile",
			"doxygen",
			"fish",
			"git_config",
			"git_rebase",
			"gitcommit",
			"gitignore",
			"go",
			"gomod",
			"gosum",
			"gowork",
			"graphql",
			"groovy",
			"html",
			"http",
			"hurl",
			"ini",
			"java",
			"javascript",
			"jq",
			"jsdoc",
			"json",
			"json5",
			"latex",
			"lua",
			"lua_patterns",
			"luadoc",
			"make",
			"markdown",
			"markdown_inline",
			"meson",
			"ninja",
			"nix",
			"perl",
			"php",
			"pug",
			"python",
			"regex",
			"requirements",
			"ruby",
			"rust",
			"scala",
			"scss",
			"sql",
			"ssh_config",
			"starlark",
			"svelte",
			"toml",
			"typescript",
			"vim",
			"vimdoc",
			"vue",
			"xml",
			"yaml",
			"yuck",
			"zig",
		},
		status_column_pad_and_fold = function()
			local space = "⠀" -- The space here is a braille blank space "⠀"
			local lnum = vim.v.lnum
			if vim.v.virtnum == 0 then
				if vim.fn.foldlevel(lnum) and vim.fn.foldlevel(lnum) > vim.fn.foldlevel(lnum - 1) then
					if vim.fn.foldclosed(lnum) == -1 then
						return Global.fold_open .. Global.status_column_separator
					else
						return Global.fold_close .. Global.status_column_separator
					end
				end
				return space .. Global.status_column_separator
			else
				local count = #tostring(vim.fn.line("$"))
				local temp
				if count < vim.wo.numberwidth then
					temp = string.rep(space, vim.wo.numberwidth)
				else
					temp = string.rep(space, count)
				end
				return temp .. space .. Global.status_column_separator
			end
		end,
		customized_hover = function(fn)
			local width = math.floor(vim.o.columns * 0.8)
			local height = math.floor(vim.o.lines * 0.5)
			fn({
				border = "rounded",
				max_width = width,
				max_height = height,
				title = " Hover ",
				title_pos = "left",
			})
		end,
		lsp_get_client = function(name, bufnr)
			local clients
			local buf = nil
			if not bufnr then
				buf = vim.api.nvim_get_current_buf()
			end
			clients = vim.lsp.get_clients({
				bufnr = buf,
				name = name,
			})
			if #clients == 0 then
				vim.notify("No " .. name .. " client found", vim.log.levels.WARN)
				return
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
		input_helper = function(prompt, default)
			return vim.fn.input({ prompt = prompt, default = default })
		end,
	}
	Global.java_compiled_files_winbar = "⠀⠀" .. Global.winbar_arrow .. " JDT URI or Class file"
	Global.winbar = "⠀⠀%{% '"
		.. Global.winbar_arrow
		.. " / "
		.. Global.winbar_arrow
		.. " ' . join(split(expand('%:p'), '/'), ' "
		.. Global.winbar_arrow
		.. " ') %}"
	-- Function to set leadmultispace correctly
	Global.lead_multi_tab_space = Global.lead_tab_space .. Global.next_space
	Global.lead_multi_space = Global.lead_space .. Global.next_space
	-- Mapping functions to map keys
	Tmap = function(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.silent = true
		opts.desc = desc
		vim.keymap.set("t", suffix, rhs, opts)
	end
	Cmap = function(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.silent = true
		opts.desc = desc
		vim.keymap.set("c", suffix, rhs, opts)
	end
	Nmap = function(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.silent = true
		opts.desc = desc
		vim.keymap.set("n", suffix, rhs, opts)
	end
	Vmap = function(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.silent = true
		opts.desc = desc
		vim.keymap.set("v", suffix, rhs, opts)
	end
	Imap = function(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.silent = true
		opts.desc = desc
		vim.keymap.set("i", suffix, rhs, opts)
	end
	Smap = function(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.silent = true
		opts.desc = desc
		vim.keymap.set("s", suffix, rhs, opts)
	end
	Xmap = function(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.silent = true
		opts.desc = desc
		vim.keymap.set("x", suffix, rhs, opts)
	end
	-- Highlight function to define or change highlights
	Hi = function(name, opts)
		vim.api.nvim_set_hl(0, name, opts)
	end
end)

-- Default settings
now(function()
	-- vim.cmd("let g:python_recommended_style=0")
	-- vim.o.colorcolumn = "150"
	-- vim.o.expandtab = true
	-- vim.o.relativenumber = true
	vim.cmd("packadd cfilter")
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "
	vim.g.nerd_font = true
	vim.o.background = "dark"
	vim.o.breakindent = true
	vim.o.completeopt = "menuone,noselect,fuzzy"
	vim.o.conceallevel = 2
	vim.o.cursorcolumn = false
	vim.o.cursorline = true
	vim.o.fillchars = "eob: ,foldopen:" .. Global.fold_open .. ",foldsep: ,foldclose:" .. Global.fold_close
	vim.o.foldcolumn = "1"
	vim.o.foldenable = true
	vim.o.foldlevel = 99
	vim.o.foldlevelstart = 99
	vim.o.hlsearch = true
	vim.o.ignorecase = true
	vim.o.incsearch = true
	vim.o.laststatus = 3
	vim.o.list = true
	vim.o.maxmempattern = 10000
	vim.o.mouse = "a"
	vim.o.mousescroll = "ver:1,hor:1"
	vim.o.number = true
	vim.o.path = "**"
	vim.o.pumblend = 0
	vim.o.scrolloff = 999
	vim.o.shiftwidth = 2
	vim.o.showcmd = true
	vim.o.showmatch = true
	vim.o.showmode = false
	vim.o.signcolumn = "yes:1"
	vim.o.smartcase = true
	vim.o.splitbelow = true
	vim.o.splitright = true
	vim.o.synmaxcol = 10000
	vim.o.tabstop = 2
	vim.o.termguicolors = true
	vim.o.textwidth = 0
	vim.o.undofile = false
	vim.o.updatetime = 500
	vim.o.wildmenu = true
	vim.o.wildmode = "longest:full,full"
	vim.o.wildoptions = "pum,fuzzy"
	vim.o.winblend = 0
	vim.o.winborder = "rounded"
	vim.o.wrap = false
	vim.opt.matchpairs:append("<:>")
	vim.opt.wildignore:append("*.png,*.jpg,*.jpeg,*.gif,*.wav,*.dll,*.so,*.swp,*.zip,*.gz,*.svg,*.cache,*/.git/*")
	vim.o.listchars = "tab:"
		.. Global.lead_multi_tab_space
		.. ",leadmultispace:"
		.. Global.lead_multi_space
		.. ",trail:␣,extends:»,precedes:«,nbsp:⦸,eol:¬"
	vim.o.statuscolumn = "%s%l%{v:lua.Global.status_column_pad_and_fold()}"
	vim.diagnostic.config({
		virtual_text = true,
		virtual_lines = false,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "",
				[vim.diagnostic.severity.WARN] = "",
				[vim.diagnostic.severity.HINT] = "",
				[vim.diagnostic.severity.INFO] = "",
			},
			texthl = {
				[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
				[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
				[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
				[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
			},
		},
		underline = false,
		severity_sort = true,
	})
end)

-- Initial UI setup
now(function()
	require("mini.notify").setup({
		window = {
			config = {
				row = 2,
			},
			max_width_share = 0.5,
			winblend = 0,
		},
	})
	vim.notify = MiniNotify.make_notify()
	-- Function to apply colorscheme
	Global.apply_colorscheme = function()
		require("mini.base16").setup({
			palette = Global.palette,
			plugins = { default = true },
		})
		Hi("@constructor.lua", { link = "Delimiter" })
		Hi("@lsp.type.parameter", { link = "Special" })
		Hi("@markup.link.vimdoc", { link = "Keyword" })
		Hi("@tag.attribute", { link = "Statement" })
		Hi("@tag.delimiter", { link = "Delimiter" })
		Hi("@variable.member", { link = "Identifier" })
		Hi("CursorLineFold", { link = "Normal" })
		Hi("CursorLineNr", { link = "Normal" })
		Hi("CursorLineSign", { link = "Normal" })
		Hi("DiagnosticSignError", { link = "DiagnosticError" })
		Hi("DiagnosticSignHint", { link = "DiagnosticHint" })
		Hi("DiagnosticSignInfo", { link = "DiagnosticInfo" })
		Hi("DiagnosticSignOk", { link = "DiagnosticOk" })
		Hi("DiagnosticSignWarn", { link = "DiagnosticWarn" })
		Hi("FloatFooter", { link = "MiniTablineCurrent" })
		Hi("FloatTitle", { link = "MiniTablineCurrent" })
		Hi("FoldColumn", { link = "Comment" })
		Hi("LineNr", { link = "Comment" })
		Hi("LineNrAbove", { link = "Comment" })
		Hi("LineNrBelow", { link = "Comment" })
		Hi("MiniClueDescGroup", { link = "Keyword" })
		Hi("MiniClueNextKey", { link = "Function" })
		Hi("MiniClueNextKeyWithPostkeys", { link = "Identifier" })
		Hi("MiniClueSeparator", { link = "FloatBorder" })
		Hi("MiniClueTitle", { link = "FloatTitle" })
		Hi("MiniCompletionInfoBorderOutdated", { link = "Conditional" })
		Hi("MiniDiffSignAdd", { link = "DiagnosticOk" })
		Hi("MiniDiffSignChange", { link = "DiagnosticWarn" })
		Hi("MiniDiffSignDelete", { link = "DiagnosticError" })
		Hi("MiniIndentscopeSymbol", { link = "SpecialKey" })
		Hi("MiniPickBorderBusy", { link = "Conditional" })
		Hi("NamuFooter", { link = "FloatFooter" })
		Hi("NormalFloat", { link = "Normal" })
		Hi("Operator", { link = "Delimiter" })
		Hi("QuickFixLineNr", { link = "SpecialKey" })
		Hi("SignColumn", { link = "Comment" })
		Hi("TreesitterContext", { link = "Pmenu" })
		Hi("WinSeparator", { link = "Normal" })
	end
	Global.apply_colorscheme()
end)

-- Mini plugins setup
now(function()
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
	-- require("mini.animate").setup()
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
			{ mode = "n", keys = "]" },
			{ mode = "n", keys = "`" },
			{ mode = "n", keys = "g" },
			{ mode = "n", keys = "z" },
			{ mode = "n", keys = '"' },
			{ mode = "n", keys = [[\]] },
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
				{ mode = "n", keys = "<leader>c", desc = "+Clipboard" },
				{ mode = "n", keys = "<leader>d", desc = "+Debug" },
				{ mode = "n", keys = "<leader>e", desc = "+Explorer" },
				{ mode = "n", keys = "<leader>f", desc = "+Find" },
				{ mode = "n", keys = "<leader>g", desc = "+Generate" },
				{ mode = "n", keys = "<leader>l", desc = "+Lsp" },
				{ mode = "n", keys = "<leader>q", desc = "+QuickFix" },
				{ mode = "n", keys = "<leader>r", desc = "+Regex" },
				{ mode = "n", keys = "<leader>t", desc = "+Tree" },
				{ mode = "n", keys = "<leader>v", desc = "+Visits" },
				{ mode = "n", keys = "<leader>w", desc = "+Window" },
			},
			require("mini.clue").gen_clues.builtin_completion(),
			require("mini.clue").gen_clues.g(),
			require("mini.clue").gen_clues.marks(),
			require("mini.clue").gen_clues.registers(),
			require("mini.clue").gen_clues.windows(),
			require("mini.clue").gen_clues.z(),
		},
		window = {
			delay = 0,
		},
	})
	require("mini.comment").setup()
	require("mini.completion").setup()
	require("mini.cursorword").setup()
	require("mini.diff").setup()
	require("mini.extra").setup()
	require("mini.files").setup({
		windows = {
			preview = true,
			width_preview = 75,
		},
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
			fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
			hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
			todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
			note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
			hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
			test = require("mini.extra").gen_highlighter.words({ "TEST" }, "MiniHipatternsNote"),
		},
	})
	require("mini.icons").setup()
	MiniIcons.mock_nvim_web_devicons()
	MiniIcons.tweak_lsp_kind()
	require("mini.indentscope").setup()
	require("mini.jump").setup()
	require("mini.jump2d").setup()
	require("mini.keymap").setup()
	require("mini.misc").setup()
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
		mappings = {
			left = "<C-S-left>",
			right = "<C-S-right>",
			down = "<C-S-down>",
			up = "<C-S-up>",
			line_left = "<C-S-left>",
			line_right = "<C-S-right>",
			line_down = "<C-S-down>",
			line_up = "<C-S-up>",
		},
		options = {
			reindent_linewise = true,
		},
	})
	require("mini.operators").setup()
	require("mini.pairs").setup()
	require("mini.pick").setup({
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
	vim.ui.select = MiniPick.ui_select
	require("mini.sessions").setup()
	-- Snippets provider plugin
	add("rafamadriz/friendly-snippets")
	require("mini.snippets").setup({
		snippets = {
			require("mini.snippets").gen_loader.from_lang(),
		},
	})
	MiniSnippets.start_lsp_server()
	require("mini.splitjoin").setup()
	require("mini.starter").setup({
		header = table.concat({
			"██████╗░██████╗░░░███╗░░████████╗██████╗░░█████╗░███╗░░██╗",
			"╚════██╗╚════██╗░████║░░╚══██╔══╝██╔══██╗██╔══██╗████╗░██║",
			"░░███╔═╝░█████╔╝██╔██║░░░░░██║░░░██████╔╝██║░░██║██╔██╗██║",
			"██╔══╝░░░╚═══██╗╚═╝██║░░░░░██║░░░██╔══██╗██║░░██║██║╚████║",
			"███████╗██████╔╝███████╗░░░██║░░░██║░░██║╚█████╔╝██║░╚███║",
			"╚══════╝╚═════╝░╚══════╝░░░╚═╝░░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚══╝",
			"",
			"Pwd: " .. vim.fn.getcwd(),
		}, "\n"),
		query_updaters = "abcdefghijklmnopqrstuvwxyz0123456789_-.+",
		items = {
			require("mini.starter").sections.builtin_actions(),
			require("mini.starter").sections.recent_files(3, false),
			require("mini.starter").sections.recent_files(3, true),
			require("mini.starter").sections.sessions(3, true),
		},
		footer = table.concat({
			"███╗░░██╗███████╗░█████╗░██╗░░░██╗██╗███╗░░░███╗",
			"████╗░██║██╔════╝██╔══██╗██║░░░██║██║████╗░████║",
			"██╔██╗██║█████╗░░██║░░██║╚██╗░██╔╝██║██╔████╔██║",
			"██║╚████║██╔══╝░░██║░░██║░╚████╔╝░██║██║╚██╔╝██║",
			"██║░╚███║███████╗╚█████╔╝░░╚██╔╝░░██║██║░╚═╝░██║",
			"╚═╝░░╚══╝╚══════╝░╚════╝░░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝",
		}, "\n"),
	})
	require("mini.statusline").setup({
		content = {
			active = function()
				local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
				local git = MiniStatusline.section_git({ trunc_width = 75 })
				local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
				local filename = MiniStatusline.section_filename({ trunc_width = 1000 })
				local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 1000 })
				local location = MiniStatusline.section_location({ trunc_width = 75 })
				local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
				local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
				return MiniStatusline.combine_groups({
					{ hl = mode_hl, strings = { mode } },
					{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics, lsp } },
					"%<",
					{ hl = "MiniStatuslineFilename", strings = { filename } },
					"%=",
					{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
					{ hl = mode_hl, strings = { search, location } },
				})
			end,
		},
		set_vim_settings = false,
	})
	require("mini.surround").setup()
	require("mini.tabline").setup({
		tabpage_section = "right",
	})
	require("mini.trailspace").setup()
	require("mini.visits").setup()
end)

-- Custom mini.nvim configuration
now(function()
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
end)

-- Non lazy plugins registration
now(function()
	add("nacro90/numb.nvim")
	require("numb").setup()
	add("mfussenegger/nvim-dap")
	add({
		source = "nvim-treesitter/nvim-treesitter",
		checkout = "main",
		monitor = "main",
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})
	require("nvim-treesitter").setup()
	require("nvim-treesitter").install(Global.languages):wait(5 * 60 * 1000)
	add({
		source = "stevearc/quicker.nvim",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
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
	add({
		source = "igorlfs/nvim-dap-view",
		depends = {
			"mfussenegger/nvim-dap",
		},
	})
	require("dap-view").setup({
		winbar = {
			sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
			default_section = "breakpoints",
			base_sections = {
				breakpoints = {
					keymap = "B",
					label = " [B]",
					short_label = "[B]",
					action = function()
						require("dap-view.views").switch_to_view("breakpoints")
					end,
				},
				scopes = {
					keymap = "S",
					label = "󰂥 [S]",
					short_label = "[S]",
					action = function()
						require("dap-view.views").switch_to_view("scopes")
					end,
				},
				exceptions = {
					keymap = "E",
					label = "󰢃 [E]",
					short_label = "[E]",
					action = function()
						require("dap-view.views").switch_to_view("exceptions")
					end,
				},
				watches = {
					keymap = "W",
					label = "󰛐 [W]",
					short_label = "[W]",
					action = function()
						require("dap-view.views").switch_to_view("watches")
					end,
				},
				threads = {
					keymap = "T",
					label = "󱉯 [T]",
					short_label = "[T]",
					action = function()
						require("dap-view.views").switch_to_view("threads")
					end,
				},
				repl = {
					keymap = "R",
					label = "󰯃 [R]",
					short_label = "[R]",
					action = function()
						require("dap-view.repl").show()
					end,
				},
				console = {
					keymap = "C",
					label = "󰆍 [C]",
					short_label = "[C]",
					action = function()
						require("dap-view.term").show()
					end,
				},
			},
			controls = {
				enabled = true,
			},
		},
		windows = {
			terminal = {
				hide = { "go", "delve" },
			},
			anchor = function()
				return Global.te_win_id
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
	add({
		source = "nvim-treesitter/nvim-treesitter-context",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("treesitter-context").setup({
		max_lines = 6,
	})
	add({
		source = "MeanderingProgrammer/render-markdown.nvim",
		depends = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.nvim",
		},
	})
	require("render-markdown").setup({
		completions = { lsp = { enabled = true } },
		code = {
			border = "thin",
		},
	})
	add({
		source = "OXY2DEV/helpview.nvim",
		depends = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.nvim",
		},
	})
	require("helpview").setup()
	add({
		source = "Wansmer/treesj",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("treesj").setup({
		use_default_keymaps = false,
	})
	add({
		source = "Goose97/timber.nvim",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("timber").setup()
	add({
		source = "bassamsdata/namu.nvim",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("namu").setup({
		namu_symbols = {
			options = {
				AllowKinds = {
					default = {
						"Function",
						"Method",
						"Class",
						"Module",
						"Property",
						"Variable",
						"Constant",
						"Enum",
						"Interface",
						"Field",
						"Struct",
					},
				},
				display = {
					format = "tree_guides",
				},
			},
		},
	})
end)

-- Linting and formatting setup
now(function()
	vim.g.guard_config = {
		fmt_on_save = true,
		lsp_as_default_formatter = true,
		save_on_fmt = true,
		auto_lint = true,
		lint_interval = 500,
		refresh_diagnostic = true,
	}
	add("nvimdev/guard.nvim")
	local ft = require("guard.filetype")
	local lint = require("guard.lint")
	ft("c"):fmt({
		cmd = "clang-format",
		stdin = true,
	}):lint({
		cmd = "clang-tidy",
		args = { "--quiet" },
		fname = true,
		parse = lint.from_regex({
			source = "clang-tidy",
			regex = ":(%d+):(%d+):%s+(%w+):%s+(.-)%s+%[(.-)%]",
			groups = { "lnum", "col", "severity", "message", "code" },
			severities = {
				information = lint.severities.info,
				hint = lint.severities.info,
				note = lint.severities.style,
			},
		}),
	})
	ft("javascriptreact,typescriptreact,typescript,javascript,html,css,json,jsonc,yaml,svelte"):fmt({
		health = function()
			if vim.fn.executable("prettier") == 0 then
				vim.health.error("prettier")
			end
			vim.health.ok("prettier")
		end,
		fn = function(buf, _, acc)
			local config_list = vim.fs.find({
				".prettierrc",
				".prettierrc.json",
			}, { upward = true, type = "file", path = vim.fs.dirname(vim.api.nvim_buf_get_name(buf)) })
			local co = assert(coroutine.running())
			local args
			if #config_list > 0 then
				args = { "prettier", "--config", config_list[1], "--stdin-filepath", vim.api.nvim_buf_get_name(buf) }
			else
				args = { "prettier", "--stdin-filepath", vim.api.nvim_buf_get_name(buf) }
			end
			local handle = vim.system(args, { stdin = true, text = true }, function(result)
				if result.code ~= 0 then
					coroutine.resume(co, result)
				else
					coroutine.resume(co, result.stdout)
				end
			end)
			handle:write(acc)
			handle:write(nil)
			return coroutine.yield()
		end,
	}):lint({
		health = function()
			if vim.fn.executable("eslint") == 0 then
				vim.health.error("eslint")
			end
			vim.health.ok("eslint")
		end,
		fn = function()
			local config_list = vim.fs.find({
				"eslint.config.js",
				"eslint.config.ts",
			}, { upward = true, type = "file", path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })
			local co = assert(coroutine.running())
			local args
			if #config_list > 0 then
				args = { "eslint", "--config", config_list[1], "--format", "json", vim.api.nvim_buf_get_name(0) }
			else
				args = { "eslint", "--format", "json", vim.api.nvim_buf_get_name(0) }
			end
			vim.system(args, {
				text = true,
			}, function(result)
				if result.code ~= 0 and #result.stderr > 0 then
					coroutine.resume(co, result)
				else
					coroutine.resume(co, result.stdout)
				end
			end)
			return coroutine.yield()
		end,
		parse = lint.from_json({
			source = "eslint",
			get_diagnostics = function(...)
				return vim.json.decode(...)[1].messages
			end,
			attributes = {
				severity = function(line)
					return tostring(line.severity)
				end,
				lnum = "line",
				col = "column",
				message = "message",
				code = "ruleId",
				lnum_end = "endLine",
				col_end = "endColumn",
			},
			severities = {
				["1"] = lint.severities.warning,
				["2"] = lint.severities.error,
			},
		}),
	})
	ft("lua"):fmt({
		cmd = "stylua",
		args = { "-" },
		stdin = true,
	}):lint({
		cmd = "luacheck",
		args = { "--formatter", "plain", "--codes" },
		fname = true,
		parse = lint.from_regex({
			regex = "(%d+):(%d+):%s%((%a)(%w+)%) (.+)",
			severities = {
				E = lint.severities.error,
				W = lint.severities.warning,
			},
			source = "luacheck",
		}),
	})
	ft("fish"):fmt({
		cmd = "fish_indent",
		stdin = true,
	})
	ft("go")
		:fmt({
			cmd = "gofmt",
			stdin = true,
		})
		:append({
			cmd = "gofumpt",
			stdin = true,
		})
		:lint({
			health = function()
				if vim.fn.executable("golangci-lint") == 0 then
					vim.health.error("golangci-lint")
				end
				vim.health.ok("golangci-lint")
			end,
			fn = function()
				local config_list = vim.fs.find({
					".golangci.yml",
					".golangci.yaml",
				}, { upward = true, type = "file", path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })
				local co = assert(coroutine.running())
				local args
				if #config_list > 0 then
					args = {
						"golangci-lint",
						"run",
						"--show-stats=false",
						"--output.json.path",
						"stdout",
						"--allow-parallel-runners",
						"--config",
						config_list[1],
						vim.api.nvim_buf_get_name(0),
					}
				else
					args = {
						"golangci-lint",
						"run",
						"--show-stats=false",
						"--output.json.path",
						"stdout",
						"--allow-parallel-runners",
						vim.api.nvim_buf_get_name(0),
					}
				end
				vim.system(args, {
					text = true,
				}, function(result)
					if result.code ~= 0 and #result.stderr > 0 then
						coroutine.resume(co, result)
					else
						coroutine.resume(co, result.stdout)
					end
				end)
				return coroutine.yield()
			end,
			parse = lint.from_json({
				source = "golangci-lint",
				get_diagnostics = function(...)
					return vim.json.decode(...).Issues
				end,
				attributes = {
					severity = function(line)
						return line.Severity or "refactor"
					end,
					lnum = function(line)
						return line.Pos.Line
					end,
					col = function(line)
						return line.Pos.Column
					end,
					message = "Text",
					code = "FromLinter",
				},
				severities = {
					error = lint.severities.error,
					warning = lint.severities.warning,
					refactor = lint.severities.info,
					convention = lint.severities.style,
				},
			}),
		})
	ft("tex"):fmt({
		cmd = "latexindent",
		args = { "-" },
		stdin = true,
	})
	ft("xml,svg"):fmt({
		cmd = "xmllint",
		args = { "--format", "-" },
		stdin = true,
	})
	ft("groovy"):fmt({
		cmd = "npm-groovy-lint",
		args = { "--format", "-" },
		stdin = true,
	})
	ft("scala"):fmt({
		health = function()
			if vim.fn.executable("scalafmt") == 0 then
				vim.health.error("scalafmt not found")
			end
			vim.health.ok("scalafmt found")
		end,
		fn = function(buf, _, acc)
			local config_list = vim.fs.find({
				".scalafmt.conf",
			}, { upward = true, type = "file", path = vim.fs.dirname(vim.api.nvim_buf_get_name(buf)) })
			local co = assert(coroutine.running())
			local args
			if #config_list > 0 then
				args = { "scalafmt", "--config", config_list[1], "--stdin" }
			else
				args = { "scalafmt", "--stdin" }
			end
			local handle = vim.system(args, { stdin = true, text = true }, function(result)
				if result.code ~= 0 then
					coroutine.resume(co, result)
				else
					coroutine.resume(co, result.stdout)
				end
			end)
			handle:write(acc)
			handle:write(nil)
			return coroutine.yield()
		end,
	})
	ft("python"):fmt({
		cmd = "black",
		args = { "--quiet", "-" },
		stdin = true,
	}):lint({
		cmd = "pylint",
		args = { "--output-format", "json", "--enable-all-extensions", "--exit-zero" },
		fname = true,
		parse = lint.from_json({
			attributes = {
				severity = "type",
				lnum = "line",
				col = "column",
				message = "message",
				code = "symbol",
				lnum_end = "endLine",
				col_end = "endColumn",
			},
			severities = {
				error = lint.severities.error,
				fatal = lint.severities.error,
				warning = lint.severities.warning,
				refactor = lint.severities.info,
				info = lint.severities.info,
				convention = lint.severities.style,
			},
			source = "pylint",
		}),
	})
	ft("rust"):fmt({
		cmd = "rustfmt",
		args = { "--emit", "stdout" },
		stdin = true,
	})
	ft("sh"):fmt({
		cmd = "shfmt",
		stdin = true,
	}):lint({
		cmd = "shellcheck",
		args = { "--format", "json" },
		fname = true,
		parse = lint.from_json({
			attributes = {
				severity = "level",
				lnum = "line",
				col = "column",
				message = "message",
				code = "code",
				lnum_end = "endLine",
				col_end = "endColumn",
			},
			severities = {
				error = lint.severities.error,
				warning = lint.severities.warning,
				info = lint.severities.info,
				style = lint.severities.style,
			},
			source = "shellcheck",
		}),
	})
	ft("sql"):fmt({
		cmd = "sqlfluff",
		args = { "format", "--dialect", "sparksql", "-" },
		stdin = true,
	}):lint({
		cmd = "sqlfluff",
		args = { "lint", "--dialect", "sparksql", "--format", "json" },
		fname = true,
		parse = lint.from_json({
			get_diagnostics = function(...)
				return vim.json.decode(...)[1].violations
			end,
			attributes = {
				severity = function(line)
					return line.code == "PRS" and "error" or "warning"
				end,
				lnum = "start_line_no",
				col = "start_line_pos",
				message = "description",
				code = "name",
				lnum_end = "end_line_no",
				col_end = "end_line_pos",
			},
			severities = {
				error = lint.severities.error,
				warning = lint.severities.warning,
			},
			source = "sqlfluff",
		}),
	})
	ft("java"):fmt({
		cmd = "google-java-format",
		args = { "-" },
		stdin = true,
	}):lint({
		health = function()
			if vim.fn.executable("checkstyle") == 0 then
				vim.health.error("checkstyle")
			end
			vim.health.ok("checkstyle")
		end,
		fn = function()
			local co = assert(coroutine.running())
			vim.system({ "checkstyle", "-c", "google_checks.xml", vim.api.nvim_buf_get_name(0) }, {
				text = true,
			}, function(result)
				coroutine.resume(co, result.stdout)
			end)
			return coroutine.yield()
		end,
		parse = lint.from_regex({
			source = "checkstyle",
			regex = "%[(%w+)%]%s+.-:(%d+):?(%d*):%s+(.-)%s+%[(.-)%]",
			groups = { "severity", "lnum", "col", "message", "code" },
			severities = {
				ERROR = lint.severities.error,
				WARN = lint.severities.warning,
				INFO = lint.severities.info,
				DEBUG = lint.severities.style,
			},
		}),
	})
end)

-- Non lazy keymaps registration
now(function()
	local map_multistep = require("mini.keymap").map_multistep
	local te_buf = nil
	local function open_terminal()
		if vim.fn.bufexists(te_buf) ~= 1 then
			vim.cmd("split | wincmd J | resize 10 | terminal")
			Global.te_win_id = vim.fn.win_getid()
			te_buf = vim.fn.bufnr("%")
		elseif vim.fn.win_gotoid(Global.te_win_id) ~= 1 then
			vim.cmd("sbuffer " .. te_buf .. "| wincmd J | resize 10")
			Global.te_win_id = vim.fn.win_getid()
		end
		vim.cmd("startinsert")
	end
	local function hide_terminal()
		if vim.fn.win_gotoid(Global.te_win_id) == 1 then
			vim.cmd("hide")
		end
	end
	local function toggle_terminal()
		if vim.fn.win_gotoid(Global.te_win_id) == 1 then
			hide_terminal()
		else
			open_terminal()
		end
	end
	-- Function to convert spaces to tabs
	local function toggle_tabs()
		vim.opt.expandtab = false
		vim.cmd("retab!")
	end
	-- Function to convert tabs to spaces
	local function toggle_spaces()
		vim.opt.expandtab = true
		vim.cmd("retab!")
	end
	-- Function to toggle virtual text for diagnostics
	local function diagnostic_virtual_text_toggle()
		vim.diagnostic.config({
			virtual_text = not vim.diagnostic.config().virtual_text,
		})
	end
	-- Function to toggle virtual lines for diagnostics
	local function diagnostic_virtual_lines_toggle()
		vim.diagnostic.config({
			virtual_lines = not vim.diagnostic.config().virtual_lines,
		})
	end
	local mini_pick_visits = function()
		local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
		MiniExtra.pickers.visit_paths(
			{ cwd = "", filter = "core", sort = sort_latest },
			{ source = { name = "Core visits" } }
		)
	end
	Nmap("<C-Space>", toggle_terminal, "Toggle terminal")
	Nmap("<F2>", ":Inspect<CR>", "Echo syntax group")
	Nmap("<F3>", ":TSContextToggle<CR>", "Toggle treesitter context")
	Nmap("<F4>", MiniNotify.clear, "Clear all notifications")
	Nmap("<F5>", MiniNotify.show_history, "Show notification history")
	Nmap("<F6>", Global.apply_colorscheme, "Apply mini.base16 colorscheme")
	Nmap("<F8>", ":RenderMarkdown toggle<CR>", "Toggle markdown preview")
	Nmap("<Space><Space>", toggle_spaces, "Expand tabs")
	Nmap("<Space><Tab>", toggle_tabs, "Contract tabs")
	Nmap("<leader>F", "<cmd>Guard fmt<CR>", "Format code")
	Nmap("<leader>bD", ":lua MiniBufremove.delete(0, true)<CR>", "Delete!")
	Nmap("<leader>bW", ":lua MiniBufremove.wipeout(0, true)<CR>", "Wipeout!")
	Nmap("<leader>ba", ":b#<CR>", "Alternate")
	Nmap("<leader>bd", ":lua MiniBufremove.delete()<CR>", "Delete")
	Nmap("<leader>bn", ":tabnew %<CR>", "Open current buffer in full screen")
	Nmap("<leader>bw", ":lua MiniBufremove.wipeout()<CR>", "Wipeout")
	Nmap("<leader>bz", MiniMisc.zoom, "Open current buffer in zoomed manner")
	Nmap("<leader>cP", '"+P', "Paste to clipboard")
	Nmap("<leader>cX", '"+X', "Cut to clipboard")
	Nmap("<leader>cY", '"+Y', "Copy to clipboard")
	Nmap("<leader>cp", '"+p', "Paste to clipboard")
	Nmap("<leader>cx", '"+x', "Cut to clipboard")
	Nmap("<leader>cy", '"+y', "Copy to clipboard")
	Nmap("<leader>dB", ":lua require('dap').list_breakpoints()<CR>", "List breakpoints")
	Nmap("<leader>dC", ":lua require('dap').clear_breakpoints()<CR>", "Clear breakpoints")
	Nmap("<leader>dS", ":lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').scopes)<CR>", "Scopes")
	Nmap("<leader>dT", ":DapViewToggle!<CR>", "Toggle dap view")
	Nmap("<leader>db", ":lua require('dap').toggle_breakpoint()<CR>", "Toggle breakpoint")
	Nmap("<leader>dc", ":lua require('dap').continue()<CR>", "Continue")
	Nmap("<leader>df", ":lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').frames)<CR>", "Frames")
	Nmap("<leader>dh", ":lua require('dap.ui.widgets').hover()<CR>", "Hover value")
	Nmap("<leader>dl", ":lua require('dap').run_last()<CR>", "Run Last")
	Nmap("<leader>dlp", ":lua require('dap').set_breakpoint(nil, nil, Global.input_helper('Log: '))<CR>", "Log point")
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
	Nmap("<leader>ft", ":Pick treesitter<CR>", "Search treesitter tree")
	Nmap("<leader>fx", ':Pick diagnostic scope="current"<CR>', "Search document diagnostics")
	Nmap("<leader>fy", ':Pick lsp scope="document_symbol"<CR>', "Search document symbols")
	Nmap("<leader>lF", ":lua vim.lsp.buf.format()<CR>", "Lsp Format")
	Nmap("<leader>lI", ":lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>", "Inlay hints toggle")
	Nmap("<leader>lc", ":lua vim.lsp.buf.code_action()<CR>", "Code action")
	Nmap("<leader>ldT", diagnostic_virtual_lines_toggle, "Virtual lines toggle")
	Nmap("<leader>ldh", ":lua Global.customized_hover(vim.diagnostic.open_float)<CR>", "Hover diagnostics")
	Nmap("<leader>ldt", diagnostic_virtual_text_toggle, "Virtual text toggle")
	Nmap("<leader>lgD", ":lua vim.lsp.buf.declaration()<CR>", "Goto declaration")
	Nmap("<leader>lgd", ":lua vim.lsp.buf.definition()<CR>", "Goto definition")
	Nmap("<leader>lgi", ":lua vim.lsp.buf.implementation()<CR>", "Goto implementation")
	Nmap("<leader>lgr", ":lua vim.lsp.buf.references()<CR>", "Goto references")
	Nmap("<leader>lgs", ":lua Global.super_implementation()<CR>", "Goto super implementation")
	Nmap("<leader>lgtd", ":lua vim.lsp.buf.type_definition()<CR>", "Goto type definition")
	Nmap("<leader>lh", ":lua Global.customized_hover(vim.lsp.buf.hover)<CR>", "Hover symbol")
	Nmap("<leader>li", ":lua vim.lsp.buf.incoming_calls()<CR>", "Lsp incoming calls")
	Nmap("<leader>lo", ":lua vim.lsp.buf.outgoing_calls()<CR>", "Lsp outgoing calls")
	Nmap("<leader>lr", ":lua vim.lsp.buf.rename()<CR>", "Rename")
	Nmap("<leader>ls", ":lua vim.lsp.buf.signature_help()<CR>", "Signature help")
	Nmap("<leader>ql", ":lua require('quicker').toggle({ loclist = true })<CR>", "Toggle loclist")
	Nmap("<leader>qq", require("quicker").toggle, "Toggle quickfix")
	Nmap("<leader>re", ":Patterns explain<CR>", "Explain pattern")
	Nmap("<leader>rh", ":Patterns hover<CR>", "Hover pattern")
	Nmap("<leader>s", ":TSJToggle<CR>", "Split/Join code blocks")
	Nmap("<leader>tb", ":Namu call both<CR>", "Both calls treeview")
	Nmap("<leader>tc", ":Namu ctags<CR>", "Ctags treeview")
	Nmap("<leader>ti", ":Namu call in<CR>", "Incoming calls treeview")
	Nmap("<leader>to", ":Namu call out<CR>", "Outgoing calls treeview")
	Nmap("<leader>ts", ":Namu symbols<CR>", "Symbols treeview")
	Nmap("<leader>ts", ":Namu watchtower<CR>", "Watchtower treeview")
	Nmap("<leader>tt", ":Namu treesitter<CR>", "Treesitter treeview")
	Nmap("<leader>tw", ":Namu watchtower<CR>", "Watchtower treeview")
	Nmap("<leader>tw", ":Namu workspace<CR>", "Workspace treeview")
	Nmap("<leader>vf", mini_pick_visits, "Core visits")
	Nmap("<leader>vr", "<cmd>lua MiniVisits.remove_label('core')<cr>", "Remove core label")
	Nmap("<leader>vv", "<cmd>lua MiniVisits.add_label('core')<cr>", "Add core label")
	Nmap("<leader>wo", ":only<CR>", "Close other windows")
	Nmap("<leader>wq", ":close<CR>", "Close window")
	Nmap("[e", ":lua MiniBracketed.diagnostic('backward',{severity=vim.diagnostic.severity.ERROR})<CR>", "Error last")
	Nmap("]e", ":lua MiniBracketed.diagnostic('forward',{severity=vim.diagnostic.severity.ERROR})<CR>", "Error forward")
	Nmap("gB", ":norm gxiagxila<CR>", "Move arg left")
	Nmap("gC", ":lua MiniGit.show_at_cursor()<CR>", "Git line history")
	Nmap("gb", ":norm gxiagxina<CR>", "Move arg right")
	Nmap("gz", ":lua MiniDiff.toggle_overlay()<CR>", "Show diff")
	Tmap("<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode")
	Vmap("<leader>cP", '"+P', "Paste to clipboard")
	Vmap("<leader>cX", '"+X', "Cut to clipboard")
	Vmap("<leader>cY", '"+Y', "Copy to clipboard")
	Vmap("<leader>cp", '"+p', "Paste to clipboard")
	Vmap("<leader>cx", '"+x', "Cut to clipboard")
	Vmap("<leader>cy", '"+y', "Copy to clipboard")
	Xmap("<leader>lf", "<cmd>Guard fmt<CR>", "Format code")
	map_multistep("i", "<BS>", { "minipairs_bs" })
	map_multistep("i", "<C-u>", { "jump_after_close" })
	map_multistep("i", "<C-y>", { "jump_before_open" })
	map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
	map_multistep("i", "<S-Tab>", { "pmenu_prev" })
	map_multistep("i", "<Tab>", { "pmenu_next" })
	map_multistep("n", "<S-Tab>", { "jump_before_tsnode" })
	map_multistep("n", "<Tab>", { "jump_after_tsnode" })
end)

-- Autocommands registration
now(function()
	-- Start treesitter on the supported language filetypes
	vim.api.nvim_create_autocmd("FileType", {
		pattern = Global.languages,
		callback = function()
			-- Start treesitter
			vim.treesitter.start()
			-- Set foldexpr to treesitter provided folds
			vim.o.foldmethod = "expr"
			vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			-- Set indent expr
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			-- Enable tag closing for html filetypes
			if
				vim.bo.filetype == "svelte"
				or vim.bo.filetype == "vue"
				or vim.bo.filetype == "jsx"
				or vim.bo.filetype == "tsx"
				or vim.bo.filetype == "html"
				or vim.bo.filetype == "xml"
				or vim.bo.filetype == "xsl"
				or vim.bo.filetype == "javascriptreact"
				or vim.bo.filetype == "typescriptreact"
			then
				-- HTML tag completion with >, >> and >>>
				vim.bo.omnifunc = "htmlcomplete#CompleteTags"
				Imap("><Space>", ">", "Cancel html pairs")
				Imap(">", "><Esc>yyppk^Dj^Da</<C-x><C-o><C-x><C-o><C-p><C-p><Esc>ka<Tab>", "Html pairs in newline", {
					buffer = true,
				})
				Imap(">>", "><Esc>F<f>a</<C-x><C-o><C-x><C-o><C-p><C-p><Esc>vit<Esc>i", "Html pairs in same line", {
					buffer = true,
				})
				Imap(
					">>>",
					"><Esc>F<f>a</<C-x><C-o><C-x><C-o><C-p><C-p><Space><BS>",
					"Html pairs in sameline with cursor at end",
					{
						buffer = true,
					}
				)
			end
		end,
	})
	-- Auto command to add keymaps for mini.files and remove extra info added to mini.statusline by mini.git
	vim.api.nvim_create_autocmd("User", {
		pattern = "MiniFilesBufferCreate,MiniGitUpdated",
		callback = function(args)
			if args.match == "MiniGitUpdated" then
				-- Remove additional git information
				local summary = vim.b[args.buf].minigit_summary
				vim.b[args.buf].minigit_summary_string = summary.head_name or ""
			elseif args.match == "MiniFilesBufferCreate" then
				-- Create mapping for setting current dir as pwd for neovim
				local b = args.data.buf_id
				vim.keymap.set("n", "g~", function()
					local path = (MiniFiles.get_fs_entry() or {}).path
					if path == nil then
						return vim.notify("Cursor is not on valid entry")
					end
					vim.fn.chdir(vim.fs.dirname(path))
				end, { buffer = b, desc = "Set cwd" })
				-- Create mapping for yanking path of entry
				vim.keymap.set("n", "gy", function()
					local path = (MiniFiles.get_fs_entry() or {}).path
					if path == nil then
						return vim.notify("Cursor is not on valid entry")
					end
					vim.fn.setreg("", path)
				end, { buffer = b, desc = "Yank path" })
				-- Create mapping for yanking path of entry to clipboard
				vim.keymap.set("n", "gY", function()
					local path = (MiniFiles.get_fs_entry() or {}).path
					if path == nil then
						return vim.notify("Cursor is not on valid entry")
					end
					vim.fn.setreg("+", path)
				end, { buffer = b, desc = "Yank path" })
				-- Toggle dotfiles
				local show_dotfiles = true
				local filter_show = function(_)
					return true
				end
				local filter_hide = function(fs_entry)
					return not vim.startswith(fs_entry.name, ".")
				end
				local toggle_dotfiles = function()
					show_dotfiles = not show_dotfiles
					local new_filter = show_dotfiles and filter_show or filter_hide
					MiniFiles.refresh({ content = { filter = new_filter } })
				end
				vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = b })
				-- Open files in horizontal or vertical pane
				local map_split = function(buf_id, lhs, direction)
					local rhs = function()
						local cur_target = MiniFiles.get_explorer_state().target_window
						local new_target = vim.api.nvim_win_call(cur_target, function()
							vim.cmd(direction .. " split")
							return vim.api.nvim_get_current_win()
						end)
						MiniFiles.set_target_window(new_target)
					end
					local desc = "Split " .. direction
					vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
				end
				map_split(b, "<C-s>", "belowright horizontal")
				map_split(b, "<C-v>", "belowright vertical")
			end
		end,
	})
	-- Run colorscheme and multispace calc functions when respective options are changed
	vim.api.nvim_create_autocmd("OptionSet", {
		pattern = "background",
		callback = function(args)
			if args.match == "background" then
				Global.apply_colorscheme()
			end
		end,
	})
	-- Various settings for plugin filetypes
	vim.api.nvim_create_autocmd("FileType", {
		pattern = {
			"netrw",
			"help",
			"nofile",
			"qf",
			"git",
			"diff",
			"fugitive",
			"floggraph",
			"dap-repl",
			"dap-view",
			"dap-view-term",
			"dap-float",
			"ministarter",
			"copilot_chat",
		},
		callback = function(args)
			-- Disable unwanted mini plugins in above filetypes and remove unwanted listchars
			vim.b.minicursorword_disable = true
			vim.b.miniindentscope_disable = true
			vim.b.minitrailspace_disable = true
			vim.opt_local.listchars:remove("eol")
			vim.opt_local.listchars:remove("nbsp")
			vim.opt_local.listchars:remove("trail")
			vim.opt_local.listchars:remove("leadmultispace")
			vim.opt_local.listchars:remove("tab")
			vim.opt_local.listchars:append({
				leadmultispace = "  ",
				tab = "  ",
			})
			MiniTrailspace.unhighlight()
			if vim.bo.filetype == "git" or vim.bo.filetype == "diff" or vim.bo.filetype == "fugitive" then
				-- Set foldexpr to mini.diff provided folds
				vim.wo.signcolumn = "no"
				vim.wo.foldmethod = "expr"
				vim.wo.foldexpr = "v:lua.MiniGit.diff_foldexpr()"
			elseif
				vim.bo.filetype == "dap-float"
				or vim.bo.filetype == "dap-repl"
				or vim.bo.filetype == "dap-view"
				or vim.bo.filetype == "dap-view-term"
			then
				-- Map q to quit window in dap filetypes
				Nmap("q", "<C-w>q", "Quit window", { buffer = args.buf })
				if vim.bo.filetype == "dap-repl" then
					-- Dap repl autocompletion setup
					require("dap.ext.autocompl").attach()
				end
				vim.wo.foldcolumn = "0"
				vim.wo.signcolumn = "no"
				vim.wo.statuscolumn = ""
			else
				-- Hide statuscolumn
				vim.wo.foldcolumn = "0"
				vim.wo.signcolumn = "no"
				vim.wo.statuscolumn = ""
			end
		end,
	})
	-- Remove statuscolumn for terminal
	vim.api.nvim_create_autocmd("TermOpen", {
		callback = function()
			vim.wo.statuscolumn = ""
		end,
	})
	-- Set winbar for all windows
	vim.api.nvim_create_autocmd("BufWinEnter", {
		pattern = "*",
		callback = function(args)
			local win = vim.fn.bufwinid(args.buf)
			vim.schedule(function()
				if win and not vim.api.nvim_win_is_valid(win) then
					return
				end
				if
					vim.bo.buftype ~= "help"
					and vim.bo.buftype ~= "prompt"
					and vim.bo.buftype ~= "nofile"
					and vim.bo.buftype ~= "acwrite"
					and vim.bo.buftype ~= "nowrite"
					and vim.bo.buftype ~= "terminal"
					and vim.bo.buftype ~= "quickfix"
				then
					if vim.bo.buftype == "" then
						if vim.startswith(args.match, "jdt://") or vim.endswith(args.match, ".class") then
							if vim.bo.filetype ~= "" then
								vim.api.nvim_set_option_value(
									"winbar",
									Global.java_compiled_files_winbar,
									{ win = win }
								)
							end
						else
							if not vim.api.nvim_buf_is_valid(args.buf) then
								return
							end
							if vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf)) then
								vim.api.nvim_set_option_value("winbar", Global.winbar, { win = win })
							end
						end
					end
				end
			end)
		end,
	})
	-- Lsp semanticTokensProvider disabling and foldexpr enabling setup
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			-- Disable semantic highlighting
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client then
				client.server_capabilities.semanticTokensProvider = nil
			end
			-- Set foldexpr to lsp provided folds
			-- vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
		end,
	})
	-- Trim files on save setup
	vim.api.nvim_create_autocmd("BufWrite", {
		pattern = "*",
		callback = function()
			MiniTrailspace.trim()
			MiniTrailspace.trim_last_lines()
		end,
	})
	-- Set winbar if new file is written to the buffer
	vim.api.nvim_create_autocmd("BufWritePost", {
		callback = function(args)
			-- Set winbar if new file is written to the buffer
			if vim.bo.buftype == "" then
				if vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf)) then
					vim.wo.winbar = Global.winbar
				end
			end
		end,
	})
	-- Disable statuscolumn in command window
	vim.api.nvim_create_autocmd("CmdwinEnter", {
		callback = function()
			vim.wo.number = false
			vim.wo.relativenumber = false
			vim.wo.foldcolumn = "0"
			vim.wo.signcolumn = "no"
			vim.wo.statuscolumn = ""
		end,
	})
	-- Highlight yanked text for 1 second
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			vim.hl.on_yank({
				timeout = 1000,
				on_macro = true,
			})
		end,
	})
	-- Send focus event to metals lsp
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = { "*.scala" },
		callback = function()
			vim.lsp.buf_notify(0, "metals/didFocusTextDocument", vim.uri_from_bufnr(0))
		end,
	})
	-- Handle jdt URIs and java class files differently
	vim.api.nvim_create_autocmd("BufReadCmd", {
		pattern = { "jdt://*", "*.class" },
		callback = function(args)
			local function is_jdtls_buf(buffer_nr)
				if vim.bo[buffer_nr].filetype == "java" then
					return true
				end
				local buf_name = vim.api.nvim_buf_get_name(buffer_nr)
				return vim.endswith(buf_name, "build.gradle")
					or vim.endswith(buf_name, "pom.xml")
					or vim.startswith(buf_name, "jdt://")
					or vim.endswith(buf_name, ".class")
					or vim.endswith(buf_name, ".java")
			end
			local attached = false
			local alt_buf = vim.fn.bufnr("#", -1)
			if alt_buf and alt_buf > 0 then
				if is_jdtls_buf(alt_buf) then
					local client = Global.lsp_get_client("jdtls", alt_buf)
					if not client then
						return
					end
					vim.lsp.buf_attach_client(args.buf, client.id)
					attached = true
				end
			end
			if not attached then
				for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(buffer) then
						if is_jdtls_buf(buffer) then
							local client = Global.lsp_get_client("jdtls", buffer)
							if not client then
								return
							end
							vim.lsp.buf_attach_client(args.buf, client.id)
							if client then
								attached = true
								break
							end
						end
					end
				end
			end
			if not attached then
				vim.notify("Cannot attach jdtls to buffer", vim.log.levels.WARN)
				return
			end
			local fname = vim.fn.expand("<amatch>")
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
			vim.bo[buf].filetype = "java"
			local timeout_ms = 5000
			vim.wait(timeout_ms, function()
				return Global.lsp_get_client("jdtls", buf) ~= nil
			end)
			local client = Global.lsp_get_client("jdtls", buf)
			if not client then
				return
			end
			local content
			local function handler(err, result)
				if err then
					vim.notify("Error decompiling class files: " .. err.message, vim.log.levels.WARN)
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
				client:request("java/classFileContents", params, handler, buf)
			end
			vim.wait(timeout_ms, function()
				return content ~= nil
			end)
		end,
	})
end)

-- Lsp configurations setup
now(function()
	-- Make lsp capabilities
	local lsp_capabilities =
		vim.tbl_extend("force", vim.lsp.protocol.make_client_capabilities(), MiniCompletion.get_lsp_capabilities())
	lsp_capabilities.general.positionEncodings = { Global.offset_encoding }
	add("neovim/nvim-lspconfig")
	-- Lua settings
	local lua_runtime_files = vim.api.nvim_get_runtime_file("", true)
	for k, v in ipairs(lua_runtime_files) do
		if v == vim.fn.stdpath("config") then
			table.remove(lua_runtime_files, k)
		end
	end
	-- Jdtls settings
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
	local env = {
		---@diagnostic disable-next-line: undefined-field
		HOME = vim.uv.os_homedir(),
		XDG_CACHE_HOME = os.getenv("XDG_CACHE_HOME"),
		JDTLS_JVM_ARGS = os.getenv("JDTLS_JVM_ARGS"),
		JAVA_EXECUTABLE = os.getenv("JAVA_EXECUTABLE"),
	}
	local function get_cache_dir()
		return env.XDG_CACHE_HOME and env.XDG_CACHE_HOME or env.HOME .. "/.cache"
	end
	local function get_jdtls_cache_dir()
		return get_cache_dir() .. "/jdtls"
	end
	local function get_jdtls_config_dir()
		return get_jdtls_cache_dir() .. "/config"
	end
	local function get_jdtls_workspace_dir()
		return get_jdtls_cache_dir() .. "/workspace"
	end
	local function get_jdtls_jvm_args()
		local args = {}
		for a in string.gmatch((env.JDTLS_JVM_ARGS or ""), "%S+") do
			local arg = string.format("--jvm-arg=%s", a)
			table.insert(args, arg)
		end
		return unpack(args)
	end
	local function get_jdtls_java_executable()
		return env.JAVA_EXECUTABLE or "/usr/lib/jvm/default/bin/java"
	end
	local lsp_servers = {
		lua_ls = {
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
		eslint = {},
		cssls = {},
		bashls = {},
		gopls = {
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
		-- pyright = {},
		basedpyright = {
			settings = {
				basedpyright = {
					analysis = {
						autoSearchPaths = true,
						diagnosticMode = "openFilesOnly",
						useLibraryCodeForTypes = true,
					},
				},
			},
		},
		-- vtsls = {
		--	settings = {
		--		typescript = {
		--			inlayHints = {
		--				parameterNames = { enabled = "all" },
		--				parameterTypes = { enabled = true },
		--				variableTypes = { enabled = true },
		--				propertyDeclarationTypes = { enabled = true },
		--				functionLikeReturnTypes = { enabled = true },
		--				enumMemberValues = { enabled = true },
		--			},
		--		},
		--	},
		-- },
		ts_ls = {
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = true,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayVariableTypeHintsWhenTypeMatchesName = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = true,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayVariableTypeHintsWhenTypeMatchesName = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		},
		svelte = {
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
				["metals/status"] = vim.schedule_wrap(function(_, results)
					vim.notify(results.text, vim.log.levels.INFO)
				end),
			},
		},
		jdtls = {
			cmd = {
				"jdtls",
				"--java-executable",
				get_jdtls_java_executable(),
				"-configuration",
				get_jdtls_config_dir(),
				"-data",
				get_jdtls_workspace_dir(),
				get_jdtls_jvm_args(),
			},
			capabilities = jdtls_capabilities,
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
				workspace = get_jdtls_workspace_dir(),
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
				["language/status"] = vim.schedule_wrap(function(_, results)
					vim.notify(results.message, vim.log.levels.INFO)
				end),
			},
		},
	}
	-- Set capabilities and load lsps
	vim.lsp.config("*", {
		capabilities = lsp_capabilities,
		root_markers = { ".git" },
	})
	for server, config in pairs(lsp_servers) do
		vim.lsp.config(server, config)
		vim.lsp.enable(server)
	end
	-- Define client commands
	local commands = {
		-- Jdtls client commands
		["java.apply.workspaceEdit"] = function(command)
			for _, argument in ipairs(command.arguments) do
				vim.lsp.util.apply_workspace_edit(argument, Global.offset_encoding)
			end
		end,
		["java.action.generateToStringPrompt"] = function(_, ctx)
			local params = ctx.params
			if not ctx.bufnr then
				vim.notify("'ctx' does not have a buffer", vim.log.levels.WARN)
				return
			end
			local bufnr = ctx.bufnr
			local client = Global.lsp_get_client("jdtls", bufnr)
			if not client then
				return
			end
			Global.coroutine_wrap(function()
				local err, result = Global.lsp_client_request(client, "java/checkToStringStatus", params, bufnr)
				if err then
					vim.notify("Could not execute java/checkToStringStatus: " .. err.message, vim.log.levels.WARN)
					return
				end
				if not result then
					return
				end
				local err1, edit = Global.lsp_client_request(
					client,
					"java/generateToString",
					{ context = params, fields = result.fields },
					bufnr
				)
				if err1 then
					vim.notify("Could not execute java/generateToString: " .. err1.message, vim.log.levels.WARN)
				elseif edit then
					vim.lsp.util.apply_workspace_edit(edit, Global.offset_encoding)
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
			local client = Global.lsp_get_client("jdtls", bufnr)
			if not client then
				return
			end
			Global.coroutine_wrap(function()
				local _, result = Global.lsp_client_request(client, "java/checkHashCodeEqualsStatus", params, bufnr)
				if not result then
					vim.notify("No result", vim.log.levels.INFO)
					return
				elseif not result.fields or #result.fields == 0 then
					vim.notify(
						string.format("The operation is not applicable to the type %", result.type),
						vim.log.levels.WARN
					)
					return
				end
				local err1, edit = Global.lsp_client_request(
					client,
					"java/generateHashCodeEquals",
					{ context = params, fields = result.fields },
					bufnr
				)
				if err1 then
					vim.notify("Could not execute java/generateHashCodeEquals: " .. err1.message, vim.log.levels.WARN)
				elseif edit then
					vim.lsp.util.apply_workspace_edit(edit, Global.offset_encoding)
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
			local client = Global.lsp_get_client("jdtls", bufnr)
			if not client then
				return
			end
			Global.coroutine_wrap(function()
				local err, result = Global.lsp_client_request(client, "java/organizeImports", ctx.params, bufnr)
				if err then
					vim.notify("Error on organize imports: " .. err.message, vim.log.levels.WARN)
					return
				end
				if result then
					vim.lsp.util.apply_workspace_edit(result, Global.offset_encoding)
				end
			end)
		end,
		["java.action.generateConstructorsPrompt"] = function(_, ctx)
			if not ctx.bufnr then
				vim.notify("'ctx' does not have a buffer", vim.log.levels.WARN)
				return
			end
			local bufnr = ctx.bufnr
			local client = Global.lsp_get_client("jdtls", bufnr)
			if not client then
				return
			end
			Global.coroutine_wrap(function()
				local err, result = Global.lsp_client_request(client, "java/checkConstructorsStatus", ctx.params, bufnr)
				if err then
					vim.notify("Could not execute java/checkConstructorsStatus: " .. err.message, vim.log.levels.WARN)
					return
				end
				if result then
					vim.lsp.util.apply_workspace_edit(result, Global.offset_encoding)
				end
				local params = {
					context = ctx.params,
					constructors = result.constructors,
					fields = result.fields,
				}
				local err1, edit = Global.lsp_client_request(client, "java/generateConstructors", params, bufnr)
				if err1 then
					vim.notify("Could not execute java/generateConstructors: " .. err1.message, vim.log.levels.WARN)
				elseif edit then
					vim.lsp.util.apply_workspace_edit(edit, Global.offset_encoding)
				end
			end)
		end,
		["java.action.generateDelegateMethodsPrompt"] = function(_, ctx)
			if not ctx.bufnr then
				vim.notify("'ctx' does not have a buffer", vim.log.levels.WARN)
				return
			end
			local bufnr = ctx.bufnr
			local client = Global.lsp_get_client("jdtls", bufnr)
			if not client then
				return
			end
			Global.coroutine_wrap(function()
				local err, status =
					Global.lsp_client_request(client, "java/checkDelegateMethodsStatus", ctx.params, bufnr)
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
				local fields = status.delegateFields
				if #fields.delegateMethods == 0 then
					vim.notify("All delegatable methods are already implemented", vim.log.levels.INFO)
					return
				end
				local methods = fields.delegateMethods
				if not methods or #methods == 0 then
					return
				end
				local params = {
					context = ctx.params,
					delegateEntries = vim.tbl_map(function(x)
						return {
							field = fields.field,
							delegateMethod = x,
						}
					end, methods),
				}
				local err1, workspace_edit =
					Global.lsp_client_request(client, "java/generateDelegateMethods", params, bufnr)
				if err1 then
					vim.notify("Could not execute java/generateDelegateMethods: " .. err1.message, vim.log.levels.WARN)
				elseif workspace_edit then
					vim.lsp.util.apply_workspace_edit(workspace_edit, Global.offset_encoding)
				end
			end)
		end,
		["java.action.overrideMethodsPrompt"] = function(_, ctx)
			if not ctx.bufnr then
				vim.notify("'ctx' does not have a buffer", vim.log.levels.WARN)
				return
			end
			local bufnr = ctx.bufnr
			local client = Global.lsp_get_client("jdtls", bufnr)
			if not client then
				return
			end
			Global.coroutine_wrap(function()
				local err, result = Global.lsp_client_request(client, "java/listOverridableMethods", ctx.params, bufnr)
				if err then
					vim.notify("Error getting overridable methods: " .. err.message, vim.log.levels.WARN)
					return
				end
				if not result or not result.methods then
					vim.notify("No methods to override", vim.log.levels.INFO)
					return
				end
				local params = {
					context = ctx.params,
					overridableMethods = result.methods,
				}
				local err1, edit = Global.lsp_client_request(client, "java/addOverridableMethods", params, bufnr)
				if err1 then
					print("Error getting workspace edits: " .. err1.message)
					return
				end
				if edit then
					vim.lsp.util.apply_workspace_edit(edit, Global.offset_encoding)
				end
			end)
		end,
	}
	if vim.lsp.commands then
		for k, v in pairs(commands) do
			vim.lsp.commands[k] = v
		end
	end
	Global.super_implementation = function()
		if vim.bo.filetype == "java" then
			Global.coroutine_wrap(function()
				local params = {
					type = "superImplementation",
					position = vim.lsp.util.make_position_params(
						vim.api.nvim_get_current_win(),
						Global.offset_encoding
					),
				}
				local bufnr = vim.api.nvim_get_current_buf()
				local err, result =
					Global.lsp_client_request(Global.lsp_get_client("jdtls", bufnr), "java/findLinks", params, bufnr)
				if err then
					vim.notify("Error getting super implementation: " .. err.message, vim.log.levels.WARN)
					return
				end
				if not result then
					vim.notify("No super implementations found", vim.log.levels.INFO)
					return
				end
				if #result == 1 then
					vim.lsp.util.show_document(result[1], Global.offset_encoding, { focus = true })
				elseif #result > 1 then
					local items = vim.lsp.util.locations_to_items(result, Global.offset_encoding)
					local list = {
						title = "References",
						items = items,
					}
					vim.fn.setqflist({}, " ", list)
					vim.cmd("botright copen")
				end
			end)
		elseif vim.bo.filetype == "scala" then
			Global.coroutine_wrap(function()
				local params = vim.lsp.util.make_position_params(vim.api.nvim_get_current_win(), Global.offset_encoding)
				local bufnr = vim.api.nvim_get_current_buf()
				Global.lsp_client_exec_cmd(Global.lsp_get_client("metals", bufnr), {
					command = "goto-super-method",
					arguments = { params },
				}, bufnr)
			end)
		else
			vim.notify("Super implementation not supported for this language", vim.log.levels.INFO)
		end
	end
end)

-- Dap configurations setup
now(function()
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
		local client = Global.lsp_get_client("metals", bufnr)
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
		}, { bufnr = bufnr }, function(err, res)
			if err then
				vim.notify("Error starting scala debug adapter: " .. err.message, vim.log.levels.WARN)
				return
			end
			local uri = res.uri
			local results = {}
			local idx = 1
			local delim_from, delim_to = string.find(uri, ":", idx)
			while delim_from do
				table.insert(results, string.sub(uri, idx, delim_from - 1))
				idx = delim_to + 1
				delim_from, delim_to = string.find(uri, ":", idx)
			end
			table.insert(results, string.sub(uri, idx))
			local res_port = results[3]
			callback({
				type = "server",
				hostName = "127.0.0.1",
				port = tonumber(res_port),
				options = {
					initialize_timeout_sec = 10,
				},
			})
		end)
	end
	dap.adapters["jdtls-java-debug"] = function(callback, _)
		local bufnr = vim.api.nvim_get_current_buf()
		local client = Global.lsp_get_client("jdtls", bufnr)
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
					port = tonumber(res_port),
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
				return Global.input_helper("Enter host: ", "127.0.0.1")
			end,
			port = function()
				return Global.input_helper("Enter port: ", 5678)
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
				return Global.input_helper("Enter host: ", "127.0.0.1")
			end,
			port = function()
				return Global.input_helper("Enter port: ", 38697)
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
				return Global.input_helper("Enter host: ", "127.0.0.1")
			end,
			port = function()
				return Global.input_helper("Enter port: ", 8000)
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
				return Global.input_helper("Enter host: ", "127.0.0.1")
			end,
			port = function()
				return Global.input_helper("Enter port: ", 5005)
			end,
			buildTarget = function()
				return Global.input_helper(
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
					return Global.input_helper("Enter host: ", "127.0.0.1")
				end,
				port = function()
					return Global.input_helper("Enter port: ", 9229)
				end,
			},
		}
	end
end)

-- Lazy loaded plugins registration
later(function()
	-- vim.g.copilot_node_command = "~/.nodenv/versions/18.18.0/bin/node"
	-- vim.g.copilot_proxy = 'http://localhost:3128'
	-- vim.g.copilot_proxy_strict_ssl = false
	-- vim.g.copilot_settings = { selectedCompletionModel = 'gpt-4o-copilot' }
	vim.g.copilot_no_tab_map = true
	vim.g.copilot_no_maps = true
	add("github/copilot.vim")
	vim.cmd("Copilot status")
end)

-- Lazy loaded keymaps registration
later(function()
	Imap("<C-]>", "copilot#Accept()", "Accept copilot suggestion", {
		expr = true,
		replace_keycodes = false,
	})
	Imap("<C-\\>", "<cmd>call copilot#Dismiss()<CR>", "Dismiss copilot suggestion")
	Imap("<M-\\>", "<cmd>call copilot#Suggest()<CR>", "Get copilot suggestion")
	Imap("<M-[>", "<cmd>call copilot#Previous()<CR>", "Go to previous copilot suggestion")
	Imap("<M-]>", "<cmd>call copilot#Next()<CR>", "Go to next copilot suggestion")
	Nmap("<leader>af", "<cmd>CopilotChatFocus<CR>", "Focus copilot chat")
	Nmap("<leader>at", "<cmd>CopilotChatOpen<CR>", "Open copilot chat")
	Nmap("<leader>at", "<cmd>CopilotChatOpen<CR>", "Open copilot chat")
	Vmap("<leader>as", "<Plug>CopilotChatAddSelection", "Add selection to copilot chat")
end)

-- Lazy loaded custom configuration
later(function()
	-- Define custom signs for diagnostics and dap
	vim.fn.sign_define("DiagnosticSignOk", { text = "✓", texthl = "DiagnosticSignOk", linehl = "", numhl = "" })
	vim.fn.sign_define("DapBreakpoint", { text = "󰙧", texthl = "DiagnosticSignOk", linehl = "", numhl = "" })
	vim.fn.sign_define(
		"DapBreakpointRejected",
		{ text = "✗", texthl = "DiagnosticSignError", linehl = "", numhl = "" }
	)
	vim.fn.sign_define(
		"DapBreakpointCondition",
		{ text = "●", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" }
	)
	vim.fn.sign_define("DapLogPoint", { text = "→", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
	vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
end)
::skip_neovim_config::
