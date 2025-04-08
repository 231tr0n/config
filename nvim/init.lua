-- MiniDeps auto download setup
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/opt/mini.nvim"
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

-- Globals variables and functions declared and used
now(function()
	Global = {
		-- Space, tab and fold characters to use
		leadSpace = "›",
		nextSpace = " ",
		leadTabSpace = "»",
		foldOpen = "", -- ▾
		foldClose = "", -- ▸
		floatMultiplier = 0.8,
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
	}
	-- Function to set leadmultispace correctly
	Global.leadMultiTabSpace = Global.leadTabSpace .. Global.nextSpace
	Global.leadMultiSpace = Global.leadSpace .. Global.nextSpace
	Global.leadMultiSpaceCalc = function()
		vim.opt_local.listchars:remove("leadmultispace")
		vim.opt_local.listchars:append({
			leadmultispace = Global.leadSpace .. string.rep(Global.nextSpace, (vim.bo.shiftwidth - 1)),
		})
	end
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
	-- vim.o.relativenumber = true
	vim.cmd("packadd cfilter")
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "
	vim.g.nerd_font = true
	vim.o.background = "dark"
	vim.o.breakindent = true
	vim.o.completeopt = "menu,menuone,noselect"
	vim.o.conceallevel = 2
	vim.o.cursorcolumn = false
	vim.o.cursorline = true
	vim.o.expandtab = true
	vim.o.fillchars = "eob: ,foldopen:" .. Global.foldOpen .. ",foldsep: ,foldclose:" .. Global.foldClose
	vim.o.foldcolumn = "1"
	vim.o.foldenable = true
	vim.o.foldlevel = 99
	vim.o.foldlevelstart = 99
	vim.o.hlsearch = true
	vim.o.ignorecase = true
	vim.o.incsearch = true
	vim.o.laststatus = 3
	vim.o.list = true
	vim.o.listchars = "tab:" .. Global.leadMultiTabSpace .. ",trail:␣,extends:»,precedes:«,nbsp:⦸,eol:¬"
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
	vim.o.statuscolumn = "%s%l%{(foldlevel(v:lnum) && foldlevel(v:lnum) > foldlevel(v:lnum - 1)) ? (foldclosed(v:lnum) == -1 ? '"
		.. Global.foldOpen
		.. " ' : '"
		.. Global.foldClose
		.. " ') : '  '}"
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
		Hi("@markup.link.vimdoc", { link = "Keyword" })
		Hi("@tag.attribute", { link = "Statement" })
		Hi("@tag.delimiter", { link = "Delimiter" })
		Hi("FloatFooter", { link = "MiniTablineCurrent" })
		Hi("FloatTitle", { link = "MiniTablineCurrent" })
		Hi("Hlargs", { link = "Special" })
		Hi("MiniClueDescGroup", { link = "Keyword" })
		Hi("MiniClueNextKey", { link = "Function" })
		Hi("MiniClueNextKeyWithPostkeys", { link = "Identifier" })
		Hi("MiniClueSeparator", { link = "FloatBorder" })
		Hi("MiniClueTitle", { link = "FloatTitle" })
		Hi("MiniIndentscopeSymbol", { link = "SpecialKey" })
		Hi("MiniPickBorderBusy", { link = "Conditional" })
		Hi("NormalFloat", { link = "Normal" })
		Hi("Operator", { link = "Delimiter" })
		Hi("QuickFixLineNr", { link = "SpecialKey" })
		Hi("TreesitterContext", { link = "Pmenu" })
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
				{ mode = "n", keys = "<leader>lj", desc = "+Java" },
				{ mode = "n", keys = "<leader>p", desc = "+Print" },
				{ mode = "n", keys = "<leader>q", desc = "+QuickFix" },
				{ mode = "n", keys = "<leader>r", desc = "+Regex" },
				{ mode = "n", keys = "<leader>t", desc = "+Test" },
				{ mode = "n", keys = "<leader>tg", desc = "+Go" },
				{ mode = "n", keys = "<leader>tj", desc = "+Java" },
				{ mode = "n", keys = "<leader>tp", desc = "+Python" },
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
	-- Extend mini.completion capabilities with default capabilities
	Global.lspCapabilities =
		vim.tbl_extend("force", vim.lsp.protocol.make_client_capabilities(), MiniCompletion.get_lsp_capabilities())
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

-- Non lazy plugins registration
now(function()
	add("nacro90/numb.nvim")
	require("numb").setup()
	add("neovim/nvim-lspconfig")
	add("mfussenegger/nvim-dap")
	add({
		source = "nvim-treesitter/nvim-treesitter",
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdateSync")
			end,
		},
	})
	add({
		source = "nvim-treesitter/nvim-treesitter-textobjects",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()
	parser_configs.lua_patterns = {
		install_info = {
			url = "https://github.com/OXY2DEV/tree-sitter-lua_patterns",
			files = { "src/parser.c" },
			branch = "main",
		},
	}
	require("nvim-treesitter.configs").setup({
		ensure_installed = {
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
		modules = {},
		sync_install = false,
		auto_install = true,
		ignore_install = {},
		indent = {
			enable = true,
			-- Disable indenting if file size is greater than 2MB
			disable = function(lang, buf)
				local max_filesize = 1 * 1024 * 1024
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize and lang ~= "wasm" then
					return true
				end
			end,
		},
		highlight = {
			enable = true,
			-- -- Disable highlighting if file size is greater than 2MB
			-- disable = function(lang, buf)
			-- 	if lang == "dockerfile" then
			-- 		return true
			-- 	end
			-- 	local max_filesize = 1 * 1024 * 1024
			-- 	local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
			-- 	if ok and stats and stats.size > max_filesize then
			-- 		-- Match syntax for @punctuation.bracket so that all kinds of braces are highlighted even if treesitter is disabled
			-- 		vim.cmd("syntax match @punctuation.bracket /[(){}\\[\\]]/")
			-- 		return true
			-- 	end
			-- end,
			additional_vim_regex_highlighting = false,
		},
	})
	vim.o.foldmethod = "expr"
	-- Set foldexpr to treesitter provided folds
	vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	add({
		source = "m-demare/hlargs.nvim",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("hlargs").setup()
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
			show = true,
			default_section = "breakpoints",
		},
		windows = {
			terminal = {
				hide = { "go", "delve" },
			},
		},
	})
	local dap = require("dap")
	-- dap.defaults.fallback.force_external_terminal = true
	-- dap.defaults.fallback.terminal_win_cmd = "belowright new | resize 15"
	dap.listeners.before.attach.dapui_config = function()
		vim.cmd("DapViewOpen")
	end
	dap.listeners.before.launch.dapui_config = function()
		vim.cmd("DapViewOpen")
	end
	dap.listeners.before.event_terminated.dapui_config = function()
		vim.cmd("DapViewClose")
	end
	dap.listeners.before.event_exited.dapui_config = function()
		vim.cmd("DapViewClose")
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
		source = "danymat/neogen",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("neogen").setup({ snippet_engine = "mini" })
	add({
		source = "MeanderingProgrammer/render-markdown.nvim",
		depends = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.nvim",
		},
	})
	require("render-markdown").setup()
	add({
		source = "OXY2DEV/helpview.nvim",
		depends = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.nvim",
		},
	})
	require("helpview").setup()
	add({
		source = "OXY2DEV/patterns.nvim",
		depends = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.nvim",
		},
	})
	require("patterns").setup()
	add({
		source = "Wansmer/treesj",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("treesj").setup()
	add({
		source = "mfussenegger/nvim-jdtls",
		depends = {
			"mfussenegger/nvim-dap",
			"neovim/nvim-lspconfig",
		},
	})
	Global.jdtls_start = function()
		-- Java lsp lazy loading setup
		require("jdtls").start_or_attach((function()
			local config = {
				cmd = { "/usr/bin/jdtls" },
				root_dir = require("jdtls.setup").find_root({ "mvnw", "gradlew", "pom.xml", "build.gradle", ".git" }),
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
						codeGeneration = {
							toString = {
								template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
							},
							useBlocks = true,
						},
						configuration = {
							runtimes = {
								{
									name = "JavaSE-11",
									path = "/usr/lib/jvm/java-1.11.0-openjdk-amd64/",
								},
								{
									name = "JavaSE-17",
									path = "/usr/lib/jvm/java-1.17.0-openjdk-amd64/",
								},
								{
									name = "JavaSE-21",
									path = "/usr/lib/jvm/java-1.21.0-openjdk-amd64/",
								},
							},
						},
					},
				},
				capabilities = Global.lspCapabilities,
			}
			local bundles = {}
			vim.list_extend(bundles, vim.split(vim.fn.glob("/usr/share/java-debug/*.jar", true), "\n"))
			vim.list_extend(bundles, vim.split(vim.fn.glob("/usr/share/java-test/*.jar", true), "\n"))
			local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
			extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
			config["init_options"] = {
				bundles = bundles,
				extendedClientCapabilities = extendedClientCapabilities,
			}
			return config
		end)())
	end
	add({
		source = "Goose97/timber.nvim",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("timber").setup()
end)

-- Linting and formatting setup
now(function()
	add("stevearc/conform.nvim")
	local conform = require("conform")
	conform.setup({
		formatters_by_ft = {
			c = { "clang_format" },
			css = { "prettier" },
			fish = { "fish_indent" },
			go = { "gofmt", "gofumpt", "goimports", "golines" },
			groovy = { "npm-groovy-lint" },
			html = { "prettier" },
			java = { "google-java-format" },
			javascript = { "prettier" },
			json = { "jq", "prettier" },
			jsonc = { "prettier" },
			lua = { "stylua" },
			python = { "black" },
			rust = { "rustfmt" },
			sh = { "shfmt" },
			sql = { "sqlfluff" },
			svelte = { "prettier" },
			svg = { "xmllint" },
			tex = { "latexindent" },
			typescript = { "prettier" },
			xml = { "xmllint" },
			yaml = { "yamlfmt" },
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
	})
	conform.formatters.yamlfmt = {
		prepend_args = { "-formatter", "include_document_start=true,indentless_arrays=true" },
	}
	conform.formatters.shfmt = {
		prepend_args = { "-s" },
	}
	vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	add("mfussenegger/nvim-lint")
	require("lint").linters_by_ft = {
		-- lua = { "luacheck" },
		-- yaml = { "yamllint" },
		c = { "clangtidy" },
		go = { "golangcilint" },
		groovy = { "npm-groovy-lint" },
		java = { "checkstyle" },
		javascript = { "eslint" },
		json = { "jsonlint" },
		jsonc = { "jsonlint" },
		python = { "pylint" },
		sh = { "shellcheck" },
		sql = { "sqlfluff" },
		svelte = { "eslint" },
		typescript = { "eslint" },
	}
end)

-- Non lazy keymaps registration
now(function()
	local te_buf = nil
	local te_win_id = nil
	local function openTerminal()
		if vim.fn.bufexists(te_buf) ~= 1 then
			vim.cmd("split | wincmd J | resize 10 | terminal")
			te_win_id = vim.fn.win_getid()
			te_buf = vim.fn.bufnr("%")
		elseif vim.fn.win_gotoid(te_win_id) ~= 1 then
			vim.cmd("sbuffer " .. te_buf .. "| wincmd J | resize 10")
			te_win_id = vim.fn.win_getid()
		end
		vim.cmd("startinsert")
	end
	local function hideTerminal()
		if vim.fn.win_gotoid(te_win_id) == 1 then
			vim.cmd("hide")
		end
	end
	local function toggleTerminal()
		if vim.fn.win_gotoid(te_win_id) == 1 then
			hideTerminal()
		else
			openTerminal()
		end
	end
	-- Function to convert spaces to tabs
	local function toggleTabs()
		vim.opt.expandtab = false
		vim.cmd("retab!")
	end
	-- Function to convert tabs to spaces
	local function toggleSpaces()
		vim.opt.expandtab = true
		vim.cmd("retab!")
	end
	-- Function to toggle virtual text for diagnostics
	local function diagnosticVirtualTextToggle()
		vim.diagnostic.config({
			virtual_text = not vim.diagnostic.config().virtual_text,
		})
	end
	-- Function to toggle virtual lines for diagnostics
	local function diagnosticVirtualLinesToggle()
		vim.diagnostic.config({
			virtual_lines = not vim.diagnostic.config().virtual_lines,
		})
	end
	local keycode = vim.keycode or function(x)
		return vim.api.nvim_replace_termcodes(x, true, true, true)
	end
	local keys = {
		["cr"] = keycode("<CR>"),
		["ctrl-y"] = keycode("<C-y>"),
		["ctrl-y_cr"] = keycode("<C-y><CR>"),
	}
	local function crAction()
		if vim.fn.pumvisible() ~= 0 then
			local item_selected = vim.fn.complete_info()["selected"] ~= -1
			return item_selected and keys["ctrl-y"] or keys["ctrl-y_cr"]
		else
			return require("mini.pairs").cr()
		end
	end
	Global.miniPickVisits = function(cwd, desc)
		local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
		MiniExtra.pickers.visit_paths({ cwd = cwd, filter = "core", sort = sort_latest }, { source = { name = desc } })
	end
	Imap("<CR>", crAction, "Enter to select in wildmenu", { expr = true })
	Imap("<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], "Cycle wildmenu anti-clockwise", { expr = true })
	Imap("<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], "Cycle wildmenu clockwise", { expr = true })
	Nmap("<C-Space>", toggleTerminal, "Toggle terminal")
	Nmap("<F2>", ":Inspect<CR>", "Echo syntax group")
	Nmap("<F3>", ":TSContextToggle<CR>", "Toggle treesitter context")
	Nmap("<F4>", MiniNotify.clear, "Clear all notifications")
	Nmap("<F5>", Global.apply_colorscheme, "Apply mini.base16 colorscheme")
	Nmap("<F6>", Global.leadMultiSpaceCalc, "Set leadmultispace according to shiftwidth")
	Nmap("<Space><Space><Space>", toggleSpaces, "Expand tabs")
	Nmap("<Tab><Tab><Tab>", toggleTabs, "Contract tabs")
	Nmap("<leader>F", require("conform").format, "Format code")
	Nmap("<leader>H", ':lua vim.fn.setloclist(MiniDiff.export("qf", { scope = "all" }))<CR>', "List diff hunks")
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
	Nmap("<leader>dlp", ":lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log: '))<CR>", "Set log point")
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
	Nmap("<leader>gc", ":lua require('neogen').generate({ type = 'class' })<CR>", "Generate class annotations")
	Nmap("<leader>gf", ":lua require('neogen').generate({ type = 'file' })<CR>", "Generate file annotations")
	Nmap("<leader>gf", ":lua require('neogen').generate({ type = 'func' })<CR>", "Generate function annotations")
	Nmap("<leader>gg", ":lua require('neogen').generate()<CR>", "Generate annotations")
	Nmap("<leader>gt", ":lua require('neogen').generate({ type = 'type' })<CR>", "Generate type annotations")
	Nmap("<leader>h", ':lua vim.fn.setloclist(MiniDiff.export("qf", {scope="current"}))<CR>', "List buffer diff hunks")
	Nmap("<leader>lF", ":lua vim.lsp.buf.format()<CR>", "Lsp Format")
	Nmap("<leader>lI", ":lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>", "Inlay hints toggle")
	Nmap("<leader>lc", ":lua vim.lsp.buf.code_action()<CR>", "Code action")
	Nmap("<leader>ldT", diagnosticVirtualLinesToggle, "Virtual lines toggle")
	Nmap("<leader>ldh", ":lua vim.diagnostic.open_float()<CR>", "Hover diagnostics")
	Nmap("<leader>ldt", diagnosticVirtualTextToggle, "Virtual text toggle")
	Nmap("<leader>lgD", ":lua vim.lsp.buf.declaration()<CR>", "Goto declaration")
	Nmap("<leader>lgd", ":lua vim.lsp.buf.definition()<CR>", "Goto definition")
	Nmap("<leader>lgi", ":lua vim.lsp.buf.implementation()<CR>", "Goto implementation")
	Nmap("<leader>lgr", ":lua vim.lsp.buf.references()<CR>", "Goto references")
	Nmap("<leader>lgtd", ":lua vim.lsp.buf.type_definition()<CR>", "Goto type definition")
	Nmap("<leader>lh", ":lua vim.lsp.buf.hover()<CR>", "Hover symbol")
	Nmap("<leader>li", ":lua vim.lsp.buf.incoming_calls()<CR>", "Lsp incoming calls")
	Nmap("<leader>lo", ":lua vim.lsp.buf.outgoing_calls()<CR>", "Lsp outgoing calls")
	Nmap("<leader>lr", ":lua vim.lsp.buf.rename()<CR>", "Rename")
	Nmap("<leader>ls", ":lua vim.lsp.buf.signature_help()<CR>", "Signature help")
	Nmap("<leader>ql", ":lua require('quicker').toggle({ loclist = true })<CR>", "Toggle loclist")
	Nmap("<leader>qq", require("quicker").toggle, "Toggle quickfix")
	Nmap("<leader>re", ":Patterns explain<CR>", "Explain pattern")
	Nmap("<leader>rh", ":Patterns hover<CR>", "Hover pattern")
	Nmap("<leader>vf", "<cmd>lua Global.miniPickVisits('', 'Core visits')<cr>", "Core visits")
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
	Tmap("<Space><Esc>", "<C-\\><C-n>", "Escape terminal mode")
	Vmap("<leader>cP", '"+P', "Paste to clipboard")
	Vmap("<leader>cX", '"+X', "Cut to clipboard")
	Vmap("<leader>cY", '"+Y', "Copy to clipboard")
	Vmap("<leader>cp", '"+p', "Paste to clipboard")
	Vmap("<leader>cx", '"+x', "Cut to clipboard")
	Vmap("<leader>cy", '"+y', "Copy to clipboard")
	Xmap("<leader>lf", require("conform").format, "Format code")
end)

-- Autocommands registration
now(function()
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
				local filter_show = function(fs_entry)
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
		pattern = "shiftwidth,background",
		callback = function(args)
			if args.match == "background" then
				Global.apply_colorscheme()
			elseif args.match == "shiftwidth" then
				Global.leadMultiSpaceCalc()
			end
		end,
	})
	-- Set winbar to filename with path
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "*",
		callback = function()
			if vim.bo.buftype ~= "nofile" then
				-- Set winbar
				vim.wo.winbar = "⠀⠀%{% '🢥 / 🢥 ' . join(split(expand('%:p'), '/'), ' 🢥 ') %}"
				-- Call leadMultiSpaceCalc to set leadmultispace
				Global.leadMultiSpaceCalc()
			end
		end,
	})
	-- Various settings for plugin filetypes
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "netrw,help,nofile,qf,git,diff,fugitive,floggraph,dap-repl,dap-float,ministarter",
		callback = function()
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
			elseif vim.bo.filetype == "dap-float" then
				-- Map q to quit window in dap-float filetype
				Nmap("q", "<C-w>q", "Quit window", { buffer = true })
			elseif vim.bo.filetype == "dap-repl" then
				-- Dap repl autocompletion setup
				require("dap.ext.autocompl").attach()
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
	-- Remove statuscolumn for any nvim-dap windows
	vim.api.nvim_create_autocmd("BufWinEnter", {
		pattern = { "DAP *" },
		callback = function(args)
			local win = vim.fn.bufwinid(args.buf)
			vim.schedule(function()
				if win and not vim.api.nvim_win_is_valid(win) then
					return
				end
				vim.api.nvim_set_option_value("statuscolumn", "", { win = win })
			end)
		end,
	})
	-- Java lsp and debug setup
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "java",
		callback = function()
			Global.jdtls_start()
		end,
	})
	-- Lsp semanticTokensProvider disabling and foldexpr enabling setup
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			-- Disable semantic highlighting
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			client.server_capabilities.semanticTokensProvider = nil
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
			require("conform").format()
		end,
	})
	-- Lint on write setup
	vim.api.nvim_create_autocmd("BufWritePost", {
		callback = function()
			Global.leadMultiSpaceCalc()
			require("lint").try_lint()
		end,
	})
	-- Disable statuscolumn in command window
	vim.api.nvim_create_autocmd("CmdwinEnter", {
		callback = function()
			vim.wo.number = false
			vim.wo.relativenumber = false
			vim.wo.foldcolumn = "0"
			vim.wo.signcolumn = "no"
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
end)

-- Lazy loaded plugins registration
later(function()
	add({
		source = "mfussenegger/nvim-dap-python",
		depends = {
			"mfussenegger/nvim-dap",
		},
	})
	add("tpope/vim-fugitive")
	add({
		source = "rbong/vim-flog",
		depends = {
			"tpope/vim-fugitive",
		},
	})
	add("David-Kunz/gen.nvim")
	require("gen").setup({
		model = "gemma3:latest",
		host = "localhost",
		port = "11434",
		display_mode = "split",
		show_prompt = "full",
		show_model = true,
		no_auto_close = false,
		command = function(options)
			return "curl --silent --no-buffer -X POST http://"
				.. options.host
				.. ":"
				.. options.port
				.. "/api/chat -d $body"
		end,
		debug = false,
	})
end)

-- Lazy loaded keymaps registration
later(function()
	Nmap("<F8>", Global.jdtls_start, "Start jdtls")
	Nmap("<leader>am", require("gen").select_model, "Select model")
	Nmap("<leader>ap", ":Gen<CR>", "Prompt Model")
	Nmap("<leader>ljo", ":lua require('jdtls').organize_imports()<CR>", "Organize imports")
	Nmap("<leader>ljv", ":lua require('jdtls').extract_variable()<CR>", "Extract variable")
	Nmap("<leader>tjc", ":lua require('jdtls').test_class()<CR>", "Test class")
	Nmap("<leader>tjm", ":lua require('jdtls').test_nearest_method()<CR>", "Test method")
	Nmap("<leader>tpc", ":lua require('dap-python').test_class()<CR>", "Test class")
	Nmap("<leader>tpm", ":lua require('dap-python').test_method()<CR>", "Test method")
	Nmap("<leader>tps", ":lua require('dap-python').debug_selection()<CR>", "Debug selection")
	Smap("<leader>ap", ":Gen<CR>", "Prompt Model")
	Xmap("<leader>ap", ":Gen<CR>", "Prompt Model")
end)

-- Lazy loaded lsp configurations setup
later(function()
	local lspconfig = require("lspconfig")
	local lua_runtime_files = vim.api.nvim_get_runtime_file("", true)
	for k, v in ipairs(lua_runtime_files) do
		if v == "/home/my-login/.config/nvim" then
			table.remove(lua_runtime_files, k)
		end
	end
	lspconfig.lua_ls.setup({
		capabilities = Global.lspCapabilities,
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
					-- 	vim.env.VIMRUNTIME,
					-- },
					library = lua_runtime_files,
				},
			},
		},
	})
	lspconfig.marksman.setup({
		capabilities = Global.lspCapabilities,
	})
	lspconfig.r_language_server.setup({
		capabilities = Global.lspCapabilities,
	})
	lspconfig.texlab.setup({
		capabilities = Global.lspCapabilities,
	})
	lspconfig.html.setup({
		capabilities = Global.lspCapabilities,
	})
	lspconfig.eslint.setup({
		capabilities = Global.lspCapabilities,
	})
	lspconfig.cssls.setup({
		capabilities = Global.lspCapabilities,
	})
	lspconfig.bashls.setup({
		capabilities = Global.lspCapabilities,
	})
	lspconfig.gopls.setup({
		capabilities = Global.lspCapabilities,
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
	})
	lspconfig.pyright.setup({
		capabilities = Global.lspCapabilities,
	})
	-- lspconfig.basedpyright.setup({
	-- 	capabilities = Global.lspCapabilities,
	-- 	settings = {
	-- 		basedpyright = {
	-- 			analysis = {
	-- 				autoSearchPaths = true,
	-- 				diagnosticMode = "openFilesOnly",
	-- 				useLibraryCodeForTypes = true,
	-- 			},
	-- 		},
	-- 	},
	-- })
	lspconfig.rust_analyzer.setup({
		capabilities = Global.lspCapabilities,
		settings = {
			["rust-analyzer"] = {
				inlayHints = {
					bindingModeHints = {
						enable = false,
					},
					chainingHints = {
						enable = true,
					},
					closingBraceHints = {
						enable = true,
						minLines = 25,
					},
					closureReturnTypeHints = {
						enable = "never",
					},
					lifetimeElisionHints = {
						enable = "never",
						useParameterNames = false,
					},
					maxLength = 25,
					parameterHints = {
						enable = true,
					},
					reborrowHints = {
						enable = "never",
					},
					renderColons = true,
					typeHints = {
						enable = true,
						hideClosureInitialization = false,
						hideNamedConstructor = false,
					},
				},
			},
		},
	})
	lspconfig.ts_ls.setup({
		capabilities = Global.lspCapabilities,
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
	})
	-- lspconfig.vtsls.setup({
	-- 	capabilities = Global.lspCapabilities,
	-- 	settings = {
	-- 		typescript = {
	-- 			inlayHints = {
	-- 				parameterNames = { enabled = "all" },
	-- 				parameterTypes = { enabled = true },
	-- 				variableTypes = { enabled = true },
	-- 				propertyDeclarationTypes = { enabled = true },
	-- 				functionLikeReturnTypes = { enabled = true },
	-- 				enumMemberValues = { enabled = true },
	-- 			},
	-- 		},
	-- 	},
	-- })
	lspconfig.svelte.setup({
		capabilities = Global.lspCapabilities,
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
	})
	lspconfig.clangd.setup({
		capabilities = Global.lspCapabilities,
		settings = {
			clangd = {
				InlayHints = {
					Designators = true,
					Enabled = true,
					ParameterNames = true,
					DeducedTypes = true,
				},
			},
		},
	})
	lspconfig.yamlls.setup({
		capabilities = Global.lspCapabilities,
	})
	lspconfig.jsonls.setup({
		capabilities = Global.lspCapabilities,
	})
	lspconfig.lemminx.setup({
		capabilities = Global.lspCapabilities,
	})
	lspconfig.angularls.setup({
		capabilities = Global.lspCapabilities,
	})
	-- Start lsp lazily
	vim.cmd("LspStart")
end)

-- Lazy loaded dap configurations setup
later(function()
	local dap = require("dap")
	-- Debug plugin setups
	-- ~/.local/share/debugpy/bin/python -m debugpy --listen localhost:5678 --wait-for-client main.py
	require("dap-python").setup("~/.local/share/debugpy/bin/python")
	-- Adapter definitions
	dap.adapters["pwa-node"] = {
		type = "server",
		host = "localhost",
		port = "${port}",
		executable = {
			command = "node",
			args = { "/usr/share/js-debug/src/dapDebugServer.js", "${port}" },
		},
	}
	dap.adapters.lldb = {
		type = "executable",
		command = (function()
			if vim.fn.executable("lldb-dap-18") then
				return "/usr/bin/lldb-dap-18"
			end
			return "/usr/bin/lldb-dap"
		end)(),
		name = "lldb",
	}
	dap.adapters.delve = function(callback, config)
		if config.mode == "remote" and config.request == "attach" then
			callback({
				type = "server",
				host = config.host or "127.0.0.1",
				port = config.port or 38697,
			})
		else
			local port = config.port or 38697
			local host = config.host or "127.0.0.1"
			local term_buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_command("vsplit")
			vim.api.nvim_command("buffer " .. term_buf)
			vim.fn.jobstart({ "dlv", "dap", "-l", host .. ":" .. port }, { term = true })
			vim.defer_fn(function()
				callback({ type = "server", host = host, port = port })
			end, 100)
			-- callback({
			-- 	type = "server",
			-- 	port = "${port}",
			-- 	executable = {
			-- 		command = "dlv",
			-- 		args = { "dap", "-l", "127.0.0.1:${port}" },
			-- 		detached = vim.fn.has("win32") == 0,
			-- 	},
			-- })
		end
	end
	-- Debug configurations
	-- dlv debug --headless -l 127.0.0.1:38697 main.go
	dap.configurations.go = {
		{
			type = "delve",
			name = "Debug",
			request = "launch",
			program = "${file}",
			-- outputMode = "remote",
		},
		{
			type = "delve",
			name = "Debug test",
			request = "launch",
			mode = "test",
			program = "${file}",
			-- outputMode = "remote",
		},
		{
			type = "delve",
			name = "Debug test (go.mod)",
			request = "launch",
			mode = "test",
			program = "./${relativeFileDirname}",
			-- outputMode = "remote",
		},
		{
			type = "delve",
			name = "Attach remote",
			mode = "remote",
			request = "attach",
			hostName = "127.0.0.1",
			port = 38697,
			outputMode = "remote",
		},
	}
	-- java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=8000 Main.java
	-- mvnDebug exec:java -Dexec.mainClass="com.mycompany.app.App"
	dap.configurations.java = {
		{
			type = "java",
			request = "attach",
			name = "Attach remote",
			hostName = "127.0.0.1",
			port = 8000,
		},
	}
	for _, language in ipairs({ "typescript", "javascript" }) do
		dap.configurations[language] = {
			{
				type = "pwa-node",
				request = "launch",
				name = "Launch file",
				program = "${file}",
				cwd = "${workspaceFolder}",
			},
			{
				type = "pwa-node",
				request = "attach",
				name = "Attach",
				processId = require("dap.utils").pick_process,
				cwd = "${workspaceFolder}",
			},
			{
				type = "pwa-node",
				request = "launch",
				name = "Debug Jest Tests",
				-- trace = true,
				runtimeExecutable = "node",
				runtimeArgs = {
					"./node_modules/jest/bin/jest.js",
					"--runInBand",
				},
				rootPath = "${workspaceFolder}",
				cwd = "${workspaceFolder}",
				console = "integratedTerminal",
				internalConsoleOptions = "neverOpen",
			},
			{
				type = "pwa-node",
				request = "launch",
				name = "Debug Mocha Tests",
				-- trace = true,
				runtimeExecutable = "node",
				runtimeArgs = {
					"./node_modules/mocha/bin/mocha.js",
				},
				rootPath = "${workspaceFolder}",
				cwd = "${workspaceFolder}",
				console = "integratedTerminal",
				internalConsoleOptions = "neverOpen",
			},
		}
	end
	dap.configurations.rust = {
		{
			name = "Launch file",
			type = "lldb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			initCommands = function()
				local rustc_sysroot = vim.fn.trim(vim.fn.system("rustc --print sysroot"))
				local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
				local commands_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_commands"
				local commands = {}
				local file = io.open(commands_file, "r")
				if file then
					for line in file:lines() do
						table.insert(commands, line)
					end
					file:close()
				end
				table.insert(commands, 1, script_import)
				return commands
			end,
		},
	}
	dap.configurations.cpp = {
		{
			name = "Launch file",
			type = "lldb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
		},
	}
	dap.configurations.c = {
		{
			name = "Launch file",
			type = "lldb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
		},
	}
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
