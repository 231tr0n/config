-- MiniDeps auto download and configure setup
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.deps"
if not vim.uv.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.deps`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/echasnovski/mini.deps",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd('echo "Installed `mini.deps`" | redraw')
	vim.cmd("packadd mini.deps | helptags ALL")
end
require("mini.deps").setup({ path = { package = path_package } })

-- add, now and later functions from MiniDeps
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Globals declared and used
now(function()
	Global = {
		paletteOneDark = {
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
		treesitterNamePattern = "[#~%*%w%._%->!@:]+%s*" .. string.rep("[#~%*%w%._%->!@:]*", 3, "%s*"),
		treesitterTypePatterns = {
			"function",
			"array",
			"boolean",
			"class",
			"constant",
			"constructor",
			"enum",
			"enum_member",
			"event",
			"field",
			"file",
			"interface",
			"keyword",
			"method",
			"module",
			"namespace",
			"null",
			"number",
			"object",
			"operator",
			"package",
			"property",
			"string",
			"struct",
			"type_parameter",
			"variable",
		},
	}
	-- Set default palette
	Global.palette = Global.paletteOneDark
end)

-- Default settings
now(function()
	-- let g:python_recommended_style=0
	-- vim.o.colorcolumn = "100"
	-- vim.o.relativenumber = true
	math.randomseed(vim.uv.hrtime())
	vim.cmd("filetype plugin indent off")
	vim.cmd("filetype plugin on")
	vim.cmd("packadd cfilter")
	vim.cmd("set complete=.")
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
	vim.g.mapleader = " "
	vim.o.conceallevel = 2
	vim.o.cursorcolumn = false
	vim.o.cursorline = true
	vim.o.expandtab = true
	vim.o.fillchars = [[eob: ,foldopen:▾,foldsep: ,foldclose:▸]] -- ,
	vim.o.foldcolumn = "1"
	vim.o.foldenable = true
	vim.o.foldlevel = 99
	vim.o.foldlevelstart = 99
	vim.o.hlsearch = true
	vim.o.ignorecase = true
	vim.o.incsearch = true
	vim.o.laststatus = 3
	vim.o.list = true
	vim.o.listchars = "eol:¬,tab:  ,trail:~,extends:…,precedes:…"
	vim.o.maxmempattern = 20000
	vim.o.mousescroll = "ver:5,hor:5"
	vim.o.number = true
	vim.o.pumblend = 0
	vim.o.scrolloff = 999
	vim.o.shiftwidth = 2
	vim.o.showcmd = true
	vim.o.showmatch = true
	vim.o.showmode = false
	vim.o.signcolumn = "auto:1"
	vim.o.smartcase = true
	vim.o.tabstop = 2
	vim.o.termguicolors = true
	vim.o.textwidth = 0
	vim.o.undofile = false
	vim.o.updatetime = 500
	vim.o.wildmenu = true
	vim.o.wildmode = "longest:full,full"
	vim.o.winblend = 0
	vim.o.wrap = true
	vim.opt.matchpairs:append("<:>")
end)

now(function()
	local border = {
		{ "╭", "FloatBorder" },
		{ "─", "FloatBorder" },
		{ "╮", "FloatBorder" },
		{ "│", "FloatBorder" },
		{ "╯", "FloatBorder" },
		{ "─", "FloatBorder" },
		{ "╰", "FloatBorder" },
		{ "│", "FloatBorder" },
	}
	local original_util_open_floating_preview = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or border
		return original_util_open_floating_preview(contents, syntax, opts, ...)
	end
end)

now(function()
	vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
	vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
	vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
	vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
	vim.fn.sign_define("DapBreakpoint", { text = "󰙧", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
	vim.fn.sign_define(
		"DapBreakpointCondition",
		{ text = "●", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" }
	)
	vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
	vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
end)

-- Initial ui setup
now(function()
	add("echasnovski/mini.notify")
	require("mini.notify").setup({
		window = {
			config = {
				row = 2,
				border = "rounded",
			},
			max_width_share = 0.5,
			winblend = 0,
		},
	})
	vim.notify = MiniNotify.make_notify()
	add("echasnovski/mini.base16")
	Global.setBase16Colorscheme = function()
		require("mini.base16").setup({
			palette = Global.palette,
		})
		local function hi(highlight, options)
			vim.api.nvim_set_hl(0, highlight, options)
		end
		hi("CursorLineSign", { bg = Global.palette.base00 })
		hi("CursorLineFold", { fg = Global.palette.base03, bg = Global.palette.base01 })
		hi("DiagnosticError", { bg = Global.palette.base00, fg = Global.palette.base0F })
		hi("DiagnosticFloatingError", { link = "DiagnosticError" })
		hi("DiagnosticFloatingHint", { link = "DiagnosticHint" })
		hi("DiagnosticFloatingInfo", { link = "DiagnosticInfo" })
		hi("DiagnosticFloatingOk", { link = "DiagnosticOk" })
		hi("DiagnosticFloatingWarn", { link = "DiagnosticWarn" })
		hi("DiagnosticHint", { bg = Global.palette.base00, fg = Global.palette.base0B })
		hi("DiagnosticInfo", { bg = Global.palette.base00, fg = Global.palette.base0C })
		hi("DiagnosticOk", { bg = Global.palette.base00, fg = Global.palette.base0D })
		hi("DiagnosticSignError", { link = "DiagnosticError" })
		hi("DiagnosticSignHint", { link = "DiagnosticHint" })
		hi("DiagnosticSignInfo", { link = "DiagnosticInfo" })
		hi("DiagnosticSignOk", { link = "DiagnosticOk" })
		hi("DiagnosticSignWarn", { link = "DiagnosticWarn" })
		hi("DiagnosticWarn", { bg = Global.palette.base00, fg = Global.palette.base09 })
		hi("FloatBorder", { bg = "NONE" })
		hi("FzfLuaBorder", { bg = Global.palette.base00, fg = Global.palette.base00 })
		hi("FzfLuaFzfBorder", { link = "NonText" })
		hi("FoldColumn", { bg = Global.palette.base00, fg = Global.palette.base03 })
		hi("IndentLine", { link = "NonText" })
		hi("IndentLineCurrent", { link = "NonText" })
		hi("LineNr", { bg = Global.palette.base00, fg = Global.palette.base03 })
		hi("LineNrBelow", { link = "LineNr" })
		hi("LineNrAbove", { link = "LineNr" })
		hi("NormalFloat", { bg = "NONE" })
		hi("SignColumn", { bg = Global.palette.base00, fg = Global.palette.base03 })
		hi("TreesitterContext", { bg = Global.palette.base01 })
		hi("WinSeparator", { link = "FloatBorder" })
		hi("WinBar", { bg = Global.palette.base01, fg = Global.palette.base04 })
	end
	-- Global.setBase16Colorscheme()
	add("231tr0n/onedarkpro.nvim")
	require("onedarkpro").setup({
		colors = {}, -- Override default colors or create your own
		highlights = {}, -- Override default highlight groups or create your own
		options = {
			cursorline = false,
			transparency = false,
			terminal_colors = true,
			lualine_transparency = false,
			highlight_inactive_windows = false,
		},
	})
	vim.cmd.colorscheme("onedark_vivid")
	add("luukvbaal/statuscol.nvim")
	require("statuscol").setup({
		ft_ignore = { "netrw", "NvimTree" },
		bt_ignore = { "netrw", "NvimTree" },
		relculright = false,
		segments = {
			{ text = { "%s" }, click = "v:lua.ScSa" },
			{
				text = { require("statuscol.builtin").lnumfunc },
				click = "v:lua.ScLa",
			},
			{
				text = { require("statuscol.builtin").foldfunc, "│" },
				click = "v:lua.ScFa",
			},
		},
	})
end)

now(function()
	add("echasnovski/mini.ai")
	require("mini.ai").setup()
	add("echasnovski/mini.align")
	require("mini.align").setup()
	add("echasnovski/mini.basics")
	require("mini.basics").setup({
		options = {
			extra_ui = true,
			win_borders = "rounded",
		},
		mappings = {
			windows = true,
			move_with_alt = true,
		},
		autocommands = {
			relnum_in_visual_mode = true,
		},
	})
	add("echasnovski/mini.bracketed")
	require("mini.bracketed").setup()
	add("echasnovski/mini.bufremove")
	require("mini.bufremove").setup()
	add("echasnovski/mini.clue")
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
				{ mode = "n", keys = "<Leader>R", desc = "+REST" },
				{ mode = "n", keys = "<Leader>a", desc = "+Ai" },
				{ mode = "n", keys = "<Leader>b", desc = "+Buffer" },
				{ mode = "n", keys = "<Leader>c", desc = "+Clipboard" },
				{ mode = "n", keys = "<Leader>d", desc = "+Debug" },
				{ mode = "n", keys = "<Leader>e", desc = "+Explorer" },
				{ mode = "n", keys = "<Leader>f", desc = "+Find" },
				{ mode = "n", keys = "<Leader>g", desc = "+Generate" },
				{ mode = "n", keys = "<Leader>l", desc = "+Lsp" },
				{ mode = "n", keys = "<Leader>lj", desc = "+Java" },
				{ mode = "n", keys = "<Leader>r", desc = "+Refactor" },
				{ mode = "n", keys = "<Leader>t", desc = "+Test" },
				{ mode = "n", keys = "<Leader>tg", desc = "+Go" },
				{ mode = "n", keys = "<Leader>tj", desc = "+Java" },
				{ mode = "n", keys = "<Leader>tp", desc = "+Python" },
				{ mode = "n", keys = "<Leader>v", desc = "+Visits" },
				{ mode = "n", keys = "<Leader>q", desc = "+Quickfix" },
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
			config = {
				border = "rounded",
			},
		},
	})
	add("echasnovski/mini.comment")
	require("mini.comment").setup()
	add("echasnovski/mini.completion")
	require("mini.completion").setup({
		window = {
			info = { border = "rounded" },
			signature = { border = "rounded" },
		},
	})
	add("echasnovski/mini.cursorword")
	require("mini.cursorword").setup()
	add("echasnovski/mini.diff")
	require("mini.diff").setup()
	add("echasnovski/mini.doc")
	require("mini.doc").setup()
	add("echasnovski/mini.extra")
	require("mini.extra").setup()
	add("echasnovski/mini.files")
	require("mini.files").setup({
		windows = {
			preview = true,
			width_preview = 75,
		},
		options = {
			permanent_delete = true,
			use_as_default_explorer = true,
		},
	})
	add("echasnovski/mini.hipatterns")
	require("mini.hipatterns").setup({
		highlighters = {
			fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
			hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
			todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
			note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
			hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
			hl_words = require("mini.extra").gen_highlighter.words({ "TEST: " }, "MiniHipatternsTodo"),
		},
	})
	add("echasnovski/mini.icons")
	require("mini.icons").setup({
		lsp = {
			ollama = { glyph = "", hl = "MiniIconsGreen" },
		},
	})
	MiniIcons.mock_nvim_web_devicons()
	MiniIcons.tweak_lsp_kind()
	add("echasnovski/mini.indentscope")
	require("mini.indentscope").setup({
		symbol = "│",
		draw = {
			delay = 0,
			animation = require("mini.indentscope").gen_animation.none(),
			priority = 10000,
		},
	})
	add("echasnovski/mini.jump")
	require("mini.jump").setup()
	add("echasnovski/mini.jump2d")
	require("mini.jump2d").setup()
	add("echasnovski/mini.misc")
	require("mini.misc").setup()
	MiniMisc.setup_auto_root({ ".git", "Makefile", "go.mod", "package.json", "pom.xml" })
	add("echasnovski/mini.move")
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
	add("echasnovski/mini.operators")
	require("mini.operators").setup()
	add("echasnovski/mini.pairs")
	require("mini.pairs").setup({
		mappings = {
			["<"] = { action = "open", pair = "<>", neigh_pattern = "[^\\]." },
			[">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },
		},
	})
	add("echasnovski/mini.splitjoin")
	require("mini.splitjoin").setup()
	add("echasnovski/mini.starter")
	require("mini.starter").setup({
		header = table.concat({
			"██████╗░██████╗░░░███╗░░████████╗██████╗░░█████╗░███╗░░██╗",
			"╚════██╗╚════██╗░████║░░╚══██╔══╝██╔══██╗██╔══██╗████╗░██║",
			"░░███╔═╝░█████╔╝██╔██║░░░░░██║░░░██████╔╝██║░░██║██╔██╗██║",
			"██╔══╝░░░╚═══██╗╚═╝██║░░░░░██║░░░██╔══██╗██║░░██║██║╚████║",
			"███████╗██████╔╝███████╗░░░██║░░░██║░░██║╚█████╔╝██║░╚███║",
			"╚══════╝╚═════╝░╚══════╝░░░╚═╝░░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚══╝",
		}, "\n"),
		query_updaters = "abcdefghijklmnopqrstuvwxyz0123456789_-.+",
		items = {
			require("mini.starter").sections.builtin_actions(),
			require("mini.starter").sections.recent_files(5, false),
			require("mini.starter").sections.recent_files(5, true),
			require("mini.starter").sections.sessions(5, true),
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
	add("echasnovski/mini.statusline")
	require("mini.statusline").setup({
		content = {
			active = function()
				local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
				local git = MiniStatusline.section_git({ trunc_width = 75 })
				local diagnostics = MiniStatusline.section_diagnostics({
					trunc_width = 75,
					-- signs = { ERROR = " ", WARN = " ", INFO = " ", HINT = " " },
				})
				local filename = MiniStatusline.section_filename({ trunc_width = 140 })
				if filename:sub(1, 2) == "%F" or filename:sub(1, 2) == "%f" then
					filename = filename:sub(1, 2) .. " " .. filename:sub(3, -1)
				end
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
	add("echasnovski/mini.surround")
	require("mini.surround").setup()
	add("echasnovski/mini.tabline")
	require("mini.tabline").setup({
		tabpage_section = "right",
	})
	add("echasnovski/mini.trailspace")
	require("mini.trailspace").setup()
end)

-- Vimscript plugins
now(function()
	add("tpope/vim-fugitive")
	add("rbong/vim-flog")
	add("mbbill/undotree")
	add({
		source = "junegunn/fzf",
		hooks = {
			post_checkout = function()
				vim.cmd("call fzf#install()")
			end,
		},
	})
end)

-- Lua plugins
now(function()
	add("neovim/nvim-lspconfig")
	Global.lspCapabilities = vim.lsp.protocol.make_client_capabilities()
	Global.lspCapabilities.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}
	Global.lspCapabilities.textDocument.completion.completionItem.snippetSupport = true
	add({
		source = "nvim-treesitter/nvim-treesitter",
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})
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
		sync_install = false,
		auto_install = true,
		ignore_install = {},
		modules = {},
		indent = {
			enable = true,
		},
		incremental_selection = {
			enable = false,
		},
		highlight = {
			enable = true,
			disable = function(lang, buf)
				local max_filesize = 2 * 1024 * 1024
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					return true
				end
			end,
			additional_vim_regex_highlighting = false,
		},
	})
	Global.winbarSymbols = function()
		return "   > "
			.. require("nvim-treesitter").statusline({
				indicator_size = vim.o.columns - 7,
				type_patterns = Global.treesitterTypePatterns,
				transform_fn = function(line, node)
					local correctIcon = "?"
					local ts_type = node:type()
					for _, type in ipairs(Global.treesitterTypePatterns) do
						if ts_type:find(type, 1, true) then
							correctIcon, _ = MiniIcons.get("lsp", type)
							break
						end
					end
					return correctIcon
						.. " "
						.. vim.trim(
							vim.treesitter.get_node_text(node, 0):gsub("\n.*", ""):match(Global.treesitterNamePattern)
								or ""
						)
				end,
				separator = " > ",
				allow_duplicates = false,
			})
	end
	vim.wo.foldmethod = "expr"
	vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	add("mfussenegger/nvim-dap")
	local dap = require("dap")
	dap.listeners.before.attach.dapui_config = function()
		vim.cmd("DapToggleRepl")
	end
	dap.listeners.before.launch.dapui_config = function()
		vim.cmd("DapToggleRepl")
	end
	add("mfussenegger/nvim-lint")
	require("lint").linters_by_ft = {
		-- lua = { "luacheck" },
		python = { "pylint" },
		yaml = { "yamllint" },
		c = { "clangtidy" },
		go = { "golangcilint" },
		groovy = { "npm-groovy-lint" },
		java = { "checkstyle" },
		javascript = { "eslint" },
		json = { "jsonlint" },
		jsonc = { "jsonlint" },
		sh = { "shellcheck" },
		svelte = { "eslint" },
		typescript = { "eslint" },
	}
	add("stevearc/conform.nvim")
	local conform = require("conform")
	conform.setup({
		formatters_by_ft = {
			c = { "clang_format" },
			css = { "prettier" },
			go = { "gofmt" },
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
			svelte = { "prettier" },
			tex = { "latexindent" },
			typescript = { "prettier" },
			xml = { "xmllint" },
			yaml = { "yamlfmt" },
		},
		lsp_fallback = true,
	})
	conform.formatters.yamlfmt = {
		prepend_args = { "-formatter", "include_document_start=true,indentless_arrays=true" },
	}
	conform.formatters.shfmt = {
		inherit = false,
		command = "shfmt",
		args = { "-i", "0", "-s", "-filename", "$FILENAME" },
	}
	vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	add("stevearc/quicker.nvim")
	require("quicker").setup({
		opts = {
			signcolumn = "no",
			foldcolumn = "0",
			statuscolumn = "",
		},
		highlight = {
			treesitter = true,
			lsp = true,
			load_buffers = false,
		},
		trim_leading_whitespace = false,
	})
	add("David-Kunz/gen.nvim")
	require("gen").setup({
		model = "dolphin-llama3",
		host = "localhost",
		port = "11434",
		display_mode = "float",
		show_prompt = true,
		show_model = true,
		no_auto_close = false,
		-- init = function(options)
		--  pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
		-- end,
		command = function(options)
			return "curl --silent --no-buffer -X POST http://"
				.. options.host
				.. ":"
				.. options.port
				.. "/api/chat -d $body"
		end,
		debug = false,
	})
	add({
		source = "nvim-tree/nvim-tree.lua",
		depends = {
			"echasnovski/mini.icons",
		},
	})
	require("nvim-tree").setup()
	add({
		source = "ibhagwan/fzf-lua",
		depends = {
			"echasnovski/mini.icons",
			"junegunn/fzf",
		},
	})
	require("fzf-lua").setup({
		"max-perf",
		fzf_colors = true,
		winopts = {
			width = 0.85,
			height = 0.85,
			border = "thicc",
			preview = {
				default = "bat",
				vertical = "up:50%",
				layout = "vertical",
			},
		},
		fzf_opts = {
			["--layout"] = "default",
		},
		previewers = {
			bat = {
				theme = "Solarized (dark)",
			},
		},
		grep = {
			multiline = 1,
		},
	})
	vim.cmd("FzfLua register_ui_select")
	add({
		source = "L3MON4D3/LuaSnip",
		hooks = {
			post_checkout = function(args)
				local temp = vim.fn.getcwd()
				vim.cmd("cd " .. args.path)
				vim.cmd("make install_jsregexp")
				vim.cmd("cd " .. temp)
			end,
		},
		depends = {
			"rafamadriz/friendly-snippets",
		},
	})
	require("luasnip.loaders.from_vscode").lazy_load()
	require("luasnip.loaders.from_snipmate").lazy_load()
	add({
		source = "nvim-treesitter/nvim-treesitter-context",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("treesitter-context").setup()
	add({
		source = "RRethy/nvim-treesitter-endwise",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	vim.cmd("TSEnable endwise")
	add({
		source = "OXY2DEV/helpview.nvim",
		depends = {
			"echasnovski/mini.icons",
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("helpview").setup()
	add({
		source = "MeanderingProgrammer/render-markdown.nvim",
		depends = {
			"echasnovski/mini.icons",
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("render-markdown").setup()
	add({
		source = "danymat/neogen",
		depends = {
			"nvim-treesitter/nvim-treesitter",
			"L3MON4D3/LuaSnip",
		},
	})
	require("neogen").setup({ snippet_engine = "luasnip" })
	add({
		source = "leoluz/nvim-dap-go",
		depends = {
			"mfussenegger/nvim-dap",
		},
	})
	require("dap-go").setup({
		dap_configurations = {
			{
				type = "go",
				name = "Attach remote",
				mode = "remote",
				request = "attach",
			},
			{
				type = "go",
				name = "Attach remote(Substitute path)",
				mode = "remote",
				request = "attach",
				substitutePath = {
					{ from = "${workspaceFolder}", to = "${workspaceFolder}" },
				},
			},
		},
	})
	add({
		source = "mfussenegger/nvim-dap-python",
		depends = {
			"mfussenegger/nvim-dap",
		},
	})
	require("dap-python").setup("~/.local/share/debugpy/bin/python")
	add({
		source = "jbyuki/one-small-step-for-vimkind",
		depends = {
			"mfussenegger/nvim-dap",
		},
	})
	add({
		source = "mfussenegger/nvim-jdtls",
		depends = {
			"mfussenegger/nvim-dap",
			"neovim/nvim-lspconfig",
		},
	})
	Global.lspJdtlsConfig = function()
		local config = {
			cmd = { "/usr/bin/jdtls" },
			root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
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
						enabled = false,
						-- settings = {
						--      url = vim.fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
						--      profile = "GoogleStyle",
						-- },
					},
					inlayHints = {
						parameterNames = {
							enabled = "all",
							exclusions = { "this" },
						},
					},
					signatureHelp = { enabled = true },
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
						},
					},
				},
			},
		}
		local bundles = {
			vim.fn.glob("/usr/share/java-debug/com.microsoft.java.debug.plugin.jar", true),
		}
		vim.list_extend(bundles, vim.split(vim.fn.glob("/usr/share/java-test/*.jar", true), "\n"))
		local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
		extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
		config["init_options"] = {
			bundles = bundles,
			extendedClientCapabilities = extendedClientCapabilities,
		}
		return config
	end
end)

-- New commands
now(function()
	vim.api.nvim_create_user_command("Format", function(args)
		local range = nil
		if args.count ~= -1 then
			local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
			range = {
				start = { args.line1, 0 },
				["end"] = { args.line2, end_line:len() },
			}
		end
		require("conform").format({ async = true, range = range })
	end, { range = true })
end)

-- Keymaps
now(function()
	local function tmap(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.desc = desc
		vim.keymap.set("t", suffix, rhs, opts)
	end
	local function nmap(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.desc = desc
		vim.keymap.set("n", suffix, rhs, opts)
	end
	local function vmap(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.desc = desc
		vim.keymap.set("v", suffix, rhs, opts)
	end
	local function imap(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.desc = desc
		vim.keymap.set("i", suffix, rhs, opts)
	end
	local function smap(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.desc = desc
		vim.keymap.set("s", suffix, rhs, opts)
	end
	local function xmap(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.desc = desc
		vim.keymap.set("x", suffix, rhs, opts)
	end
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
	local function toggleTabs()
		vim.opt.expandtab = false
		vim.cmd("retab!")
	end
	local function toggleSpaces()
		vim.opt.expandtab = true
		vim.cmd("retab!")
	end
	local function diagnosticVirtualTextToggle()
		vim.diagnostic.config({
			virtual_text = not vim.diagnostic.config().virtual_text,
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
			-- return keys["cr"]
		end
	end
	imap("<C-x><C-f>", require("fzf-lua").complete_path, "Fuzzy complete path")
	imap("<CR>", crAction, "Enter to select in wildmenu", { expr = true })
	imap("<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], "Cycle wildmenu anti-clockwise", { expr = true })
	imap("<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], "Cycle wildmenu clockwise", { expr = true })
	nmap("<C-Space>", toggleTerminal, "Toggle terminal")
	nmap("<C-x><C-f>", require("fzf-lua").complete_path, "Fuzzy complete path")
	nmap("<F2>", MiniNotify.clear, "Clear all notifications")
	nmap("<F3>", "<cmd>Inspect<cr>", "Echo syntax group")
	nmap("<F4>", setBase16Colorscheme, "Set base16 colorscheme")
	nmap("<Space><Space><Space>", toggleSpaces, "Expand tabs")
	nmap("<Tab><Tab><Tab>", toggleTabs, "Contract tabs")
	nmap("<leader>am", require("gen").select_model, "Select model")
	nmap("<leader>ap", "<cmd>Gen<CR>", "Prompt Model")
	nmap("<leader>bD", "<cmd>lua MiniBufremove.delete(0, true)<CR>", "Delete!")
	nmap("<leader>bW", "<cmd>lua MiniBufremove.wipeout(0, true)<CR>", "Wipeout!")
	nmap("<leader>ba", "<cmd>b#<CR>", "Alternate")
	nmap("<leader>bc", "<cmd>:close<CR>", "Close window")
	nmap("<leader>bd", "<cmd>lua MiniBufremove.delete()<CR>", "Delete")
	nmap("<leader>bu", "<cmd>UndotreeToggle<CR>", "Undo tree toggle")
	nmap("<leader>bw", "<cmd>lua MiniBufremove.wipeout()<CR>", "Wipeout")
	nmap("<leader>cP", '"+P', "Paste to clipboard")
	nmap("<leader>cX", '"+X', "Cut to clipboard")
	nmap("<leader>cY", '"+Y', "Copy to clipboard")
	nmap("<leader>cp", '"+p', "Paste to clipboard")
	nmap("<leader>cx", '"+x', "Cut to clipboard")
	nmap("<leader>cy", '"+y', "Copy to clipboard")
	nmap("<leader>dC", "<cmd>lua require('dap').clear_breakpoints()<cr>", "Clear breakpoints")
	nmap("<leader>dL", "<cmd>lua require('osv').launch({ port = 8086 })<cr>", "Lua debug launch")
	nmap("<leader>dLr", "<cmd>lua require('osv').run_this()<cr>", "Lua debug")
	nmap("<leader>db", "<cmd>lua require('dap').list_breakpoints()<cr>", "List breakpoints")
	nmap("<leader>dc", "<cmd>lua require('dap').continue()<cr>", "Continue")
	nmap("<leader>df", ":lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').frames)<cr>", "Frames")
	nmap("<leader>dh", "<cmd>lua require('dap.ui.widgets').hover()<cr>", "Hover value")
	nmap("<leader>dl", "<cmd>lua require('dap').run_last()<cr>", "Run Last")
	nmap("<leader>dlp", "<cmd>lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log: '))<cr>", "Set log point")
	nmap("<leader>dp", "<cmd>lua require('dap.ui.widgets').preview()<cr>", "Preview")
	nmap("<leader>dr", "<cmd>lua require('dap').repl.open()<cr>", "Open Repl")
	nmap("<leader>ds", ":lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets'.scopes)<cr>", "Scopes")
	nmap("<leader>dsO", "<cmd>lua require('dap').step_over()<cr>", "Step over")
	nmap("<leader>dsi", "<cmd>lua require('dap').step_into()<cr>", "Step into")
	nmap("<leader>dso", "<cmd>lua require('dap').step_out()<cr>", "Step out")
	nmap("<leader>dt", "<cmd>lua require('dap').toggle_breakpoint()<cr>", "Toggle breakpoint")
	nmap("<leader>eT", "<cmd>lua if not MiniFiles.close() then MiniFiles.open() end<cr>", "Toggle file explorer")
	nmap("<leader>ef", "<cmd>NvimTreeFindFile<cr>", "Goto file in tree")
	nmap("<leader>et", "<cmd>NvimTreeToggle<cr>", "Toggle file tree")
	nmap("<leader>fC", "<cmd>FzfLua colorschemes<cr>", "Change colorschemes")
	nmap("<leader>fF", "<cmd>FzfLua lsp_finder<cr>", "Search everything lsp")
	nmap("<leader>fL", "<cmd>FzfLua lines<cr>", "Search lines")
	nmap("<leader>fS", "<cmd>FzfLua live_grep_native<cr>", "Search content live")
	nmap("<leader>fT", "<cmd>FzfLua tags<cr>", "Search tags")
	nmap("<leader>fX", "<cmd>FzfLua diagnostics_workspace<cr>", "Search workspace diagnostics")
	nmap("<leader>fY", "<cmd>FzfLua lsp_workspace_symbols<cr>", "Search workspace symbols")
	nmap("<leader>fb", "<cmd>FzfLua buffers<cr>", "Search buffers")
	nmap("<leader>fc", "<cmd>FzfLua lsp_code_actions<cr>", "Code Actions")
	nmap("<leader>fdb", "<cmd>FzfLua dap_breakpoints<cr>", "Search dap breakpoints")
	nmap("<leader>fdc", "<cmd>FzfLua dap_configurations<cr>", "Search dap configurations")
	nmap("<leader>fdf", "<cmd>FzfLua dap_frames<cr>", "Search dap frames")
	nmap("<leader>fdv", "<cmd>FzfLua dap_variables<cr>", "Search dap variables")
	nmap("<leader>ff", "<cmd>FzfLua files<cr>", "Search files")
	nmap("<leader>fg", "<cmd>FzfLua git_files<cr>", "Search Git files")
	nmap("<leader>fgC", "<cmd>FzfLua git_commits<cr>", "Search commits")
	nmap("<leader>fgS", "<cmd>FzfLua git_stash<cr>", "Search git stash")
	nmap("<leader>fgb", "<cmd>FzfLua git_branches<cr>", "Search branches")
	nmap("<leader>fgc", "<cmd>FzfLua git_bcommits<cr>", "Search buffer commits")
	nmap("<leader>fgs", "<cmd>FzfLua git_status<cr>", "Search git status")
	nmap("<leader>fgt", "<cmd>FzfLua git_tags<cr>", "Search git tags")
	nmap("<leader>fj", "<cmd>FzfLua jumps<cr>", "Search jumps")
	nmap("<leader>fk", "<cmd>FzfLua keymaps<cr>", "Search keymaps")
	nmap("<leader>fl", "<cmd>FzfLua blines<cr>", "Search buffer lines")
	nmap("<leader>fm", "<cmd>FzfLua marks<cr>", "Search marks")
	nmap("<leader>fo", "<cmd>FzfLua loclist<cr>", "Search loclist")
	nmap("<leader>fq", "<cmd>FzfLua quickfix<cr>", "Search quickfix")
	nmap("<leader>fs", "<cmd>FzfLua grep_project<cr>", "Search content")
	nmap("<leader>ft", "<cmd>FzfLua btags<cr>", "Search buffer tags")
	nmap("<leader>fx", "<cmd>FzfLua diagnostics_document<cr>", "Search document diagnostics")
	nmap("<leader>fy", "<cmd>FzfLua lsp_document_symbols<cr>", "Search document symbols")
	nmap("<leader>gc", "<cmd>lua require('neogen').generate({ type = 'class' })<cr>", "Generate class annotations")
	nmap("<leader>gf", "<cmd>lua require('neogen').generate({ type = 'file' })<cr>", "Generate file annotations")
	nmap("<leader>gf", "<cmd>lua require('neogen').generate({ type = 'func' })<cr>", "Generate function annotations")
	nmap("<leader>gg", "<cmd>lua require('neogen').generate()<cr>", "Generate annotations")
	nmap("<leader>gt", "<cmd>lua require('neogen').generate({ type = 'type' })<cr>", "Generate type annotations")
	nmap("<leader>lF", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", "Lsp Format")
	nmap("<leader>lc", "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code action")
	nmap("<leader>ldh", "<cmd>lua vim.diagnostic.open_float()<cr>", "Hover diagnostics")
	nmap("<leader>ldn", "<cmd>lua vim.diagnostic.goto_next()<cr>", "Goto next diagnostic")
	nmap("<leader>ldp", "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Goto prev diagnostic")
	nmap("<leader>ldt", diagnosticVirtualTextToggle, "Virtual text toggle")
	nmap("<leader>lf", "<cmd>Format<cr>", "Format code")
	nmap("<leader>lgD", "<cmd>lua vim.lsp.buf.declaration()<cr>", "Goto declaration")
	nmap("<leader>lgb", "<C-t>", "Previous tag")
	nmap("<leader>lgd", "<cmd>lua vim.lsp.buf.definition()<cr>", "Goto definition")
	nmap("<leader>lgi", "<cmd>lua vim.lsp.buf.implementation()<cr>", "Goto implementation")
	nmap("<leader>lgr", "<cmd>lua vim.lsp.buf.references()<cr>", "Goto references")
	nmap("<leader>lgs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Signature help")
	nmap("<leader>lgtd", "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Goto type definition")
	nmap("<leader>lh", "<cmd>lua vim.lsp.buf.hover()<cr>", "Hover symbol")
	nmap("<leader>li", ":lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<cr>", "Inlay hints toggle")
	nmap("<leader>ljo", "<cmd>lua require('jdtls').organize_imports()<cr>", "Organize imports")
	nmap("<leader>ljv", "<cmd>lua require('jdtls').extract_variable()<cr>", "Extract variable")
	nmap("<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename")
	nmap("<leader>rI", ":Refactor inline_func")
	nmap("<leader>rV", ":lua require('refactoring').debug.print_var()")
	nmap("<leader>rb", ":Refactor extract_block")
	nmap("<leader>rbf", ":Refactor extract_block_to_file")
	nmap("<leader>rc", ":lua require('refactoring').debug.cleanup({})<cr>")
	nmap("<leader>ri", ":Refactor inline_var")
	nmap("<leader>rp", ":lua require('refactoring').debug.printf({ below = false })")
	nmap("<leader>rr", ":lua require('refactoring').select_refactor()<cr>")
	nmap("<leader>tgm", "<cmd>lua require('dap-go').debug_test()<cr>", "Test method")
	nmap("<leader>tjc", "<cmd>lua require('jdtls').test_class()<cr>", "Test class")
	nmap("<leader>tjm", "<cmd>lua require('jdtls').test_nearest_method()<cr>", "Test method")
	nmap("<leader>tpc", "<cmd>lua require('dap-python').test_class()<cr>", "Test class")
	nmap("<leader>tpm", "<cmd>lua require('dap-python').test_method()<cr>", "Test method")
	nmap("<leader>tps", "<cmd>lua require('dap-python').debug_selection()<cr>", "Debug selection")
	nmap("<leader>xl", "<cmd>Trouble loclist toggle<cr>", "Toggle loclist")
	nmap("<leader>xq", "<cmd>Trouble qflist toggle<cr>", "Toggle quickfix")
	nmap("<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "Toggle LSP Defs/refs")
	nmap("<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", "Toggle symbols")
	nmap("<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", "Toggle diagnostics")
	nmap("<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Toggle buffer diagnostics")
	nmap("gl", "<cmd>lua MiniGit.show_at_cursor()<cr>", "Git line history")
	smap("<leader>ap", ":Gen<cr>", "Prompt Model")
	tmap("<Esc>", "<C-\\><C-n>", "Escape terminal mode")
	vmap("<C-x><C-f>", require("fzf-lua").complete_path, "Fuzzy complete path")
	vmap("<leader>cP", '"+P', "Paste to clipboard")
	vmap("<leader>cX", '"+X', "Cut to clipboard")
	vmap("<leader>cY", '"+Y', "Copy to clipboard")
	vmap("<leader>cp", '"+p', "Paste to clipboard")
	vmap("<leader>cx", '"+x', "Cut to clipboard")
	vmap("<leader>cy", '"+y', "Copy to clipboard")
	vmap("<leader>dh", "<cmd>lua require('dap.ui.widgets').hover()<cr>", "Hover value")
	vmap("<leader>dp", "<cmd>lua require('dap.ui.widgets').preview()<cr>", "Preview")
	xmap("<leader>ap", ":Gen<cr>", "Prompt Model")
	xmap("<leader>lf", "<cmd>Format<cr>", "Format code")
	xmap("<leader>rV", ":lua require('refactoring').debug.print_var()")
	xmap("<leader>re", ":Refactor extract ")
	xmap("<leader>rf", ":Refactor extract_to_file ")
	xmap("<leader>ri", ":Refactor inline_var")
	xmap("<leader>rr", ":lua require('refactoring').select_refactor()<cr>")
	xmap("<leader>rv", ":Refactor extract_var ")
end)

-- Autocommands
now(function()
	vim.api.nvim_create_autocmd("BufReadPost", {
		callback = function()
			vim.cmd("norm zx")
			vim.cmd("norm zR")
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		pattern = "MiniGitUpdated",
		callback = function(data)
			local summary = vim.b[data.buf].minigit_summary
			vim.b[data.buf].minigit_summary_string = summary.head_name or ""
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "*",
		callback = function(ev)
			if vim.bo.filetype == "trouble" or vim.bo.filetype == "help" then
				vim.wo.signcolumn = "no"
				vim.wo.foldcolumn = "0"
				vim.wo.statuscolumn = ""
			elseif vim.bo.filetype == "diff" or vim.bo.filetype == "git" then
				vim.wo.foldmethod = "expr"
				vim.wo.foldexpr = "v:lua.MiniGit.diff_foldexpr()"
			elseif vim.bo.filetype == "NvimTree" or vim.bo.filetype == "netrw" then
				vim.b.minicursorword_disable = true
			elseif
				vim.bo.filetype == "svelte"
				or vim.bo.filetype == "jsx"
				or vim.bo.filetype == "html"
				or vim.bo.filetype == "xml"
				or vim.bo.filetype == "xsl"
				or vim.bo.filetype == "javascriptreact"
			then
				vim.bo.omnifunc = "htmlcomplete#CompleteTags"
				MiniPairs.unmap("i", "<", "")
				MiniPairs.unmap("i", ">", "")
				vim.keymap.set("i", "><Space>", ">")
				vim.keymap.set("i", ">", "><Esc>A<CR><BS></<C-x><C-o><C-x><C-o><C-p><C-p><Esc>O")
				vim.keymap.set("i", ">>", "><Esc>F<f>a</<C-x><C-o><C-x><C-o><C-p><C-p><Esc>vit<Esc>i")
				vim.keymap.set("i", ">>>", "><Esc>F<f>a</<C-x><C-o><C-x><C-o><C-p><C-p><Space><BS>")
			elseif vim.bo.filetype == "java" then
				require("jdtls").start_or_attach(Global.lspJdtlsConfig())
			end
		end,
	})
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			-- local client = vim.lsp.get_client_by_id(args.data.client_id)
			-- client.server_capabilities.semanticTokensProvider = nil
			vim.diagnostic.config({
				virtual_text = true,
				underline = false,
			})
			vim.wo.winbar = "%{%v:lua.Global.winbarSymbols()%}"
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
			if vim.bo.filetype == "java" then
				require("jdtls.dap").setup_dap_main_class_configs()
			end
		end,
	})
	vim.api.nvim_create_autocmd("TermOpen", {
		pattern = "*",
		callback = function()
			vim.wo.winbar = ""
			vim.wo.number = false
			vim.wo.relativenumber = false
			vim.wo.signcolumn = "no"
			vim.wo.foldcolumn = "0"
			vim.wo.statuscolumn = ""
		end,
	})
	vim.api.nvim_create_autocmd("BufWinEnter", {
		pattern = { "\\[dap-repl-*\\]", "NvimTree_*" },
		callback = function(args)
			local win = vim.fn.bufwinid(args.buf)
			vim.schedule(function()
				if not vim.api.nvim_win_is_valid(win) then
					return
				end
				vim.api.nvim_set_option_value("foldcolumn", "0", { win = win })
				vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
				vim.api.nvim_set_option_value("statuscolumn", "", { win = win })
			end)
		end,
	})
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*",
		callback = function(args)
			require("conform").format({ bufnr = args.buf })
			MiniTrailspace.trim()
			MiniTrailspace.trim_last_lines()
		end,
	})
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		callback = function()
			require("lint").try_lint()
		end,
	})
end)

-- Dap configuration setup
later(function()
	local dap = require("dap")
	dap.adapters.delve = {
		type = "server",
		host = "127.0.0.1",
		port = 38697,
	}
	require("dap-go").setup({
		dap_configurations = {
			{
				type = "go",
				name = "Attach remote",
				mode = "remote",
				request = "attach",
			},
			{
				type = "go",
				name = "Attach remote(Substitute path)",
				mode = "remote",
				request = "attach",
				substitutePath = {
					{ from = "${workspaceFolder}", to = "${workspaceFolder}" },
				},
			},
		},
	})
	require("dap-python").setup("~/.local/share/debugpy/bin/python")
	require("dap").adapters["pwa-node"] = {
		type = "server",
		host = "localhost",
		port = "${port}",
		executable = {
			command = "node",
			args = { "/usr/share/js-debug/src/dapDebugServer.js", "${port}" },
		},
	}
	for _, language in ipairs({ "typescript", "javascript" }) do
		require("dap").configurations[language] = {
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
				-- trace = true, -- include debugger info
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
				-- trace = true, -- include debugger info
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
	dap.configurations.java = {
		{
			type = "java",
			request = "attach",
			name = "Debug (Attach) - Remote",
			hostName = "127.0.0.1",
			port = 5005,
		},
	}
	dap.configurations.lua = {
		{
			type = "nlua",
			request = "attach",
			name = "Attach to running Neovim instance",
		},
	}
	dap.adapters.nlua = function(callback, config)
		callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
	end
	local function lldb_command()
		if vim.fn.empty(os.execute("which lldb-vscode")) == 0 then
			return "/usr/bin/lldb-dap-18"
		end
		return "/usr/bin/lldb-dap"
	end
	dap.adapters.lldb = {
		type = "executable",
		command = lldb_command(),
		name = "lldb",
	}
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

-- Lsp configuration configuration
later(function()
	local lspconfig = require("lspconfig")
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
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME,
					},
					-- library = vim.api.nvim_get_runtime_file("", true),
				},
			},
		},
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
	})
	-- lspconfig.pyright.setup({
	-- 	capabilities = Global.lspCapabilities,
	-- })
	lspconfig.basedpyright.setup({
		capabilities = Global.lspCapabilities,
		settings = {
			basedpyright = {
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = "openFilesOnly",
					useLibraryCodeForTypes = true,
				},
			},
		},
	})
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
	lspconfig.vtsls.setup({
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
	-- lspconfig.tsserver.setup({
	-- 	capabilities = Global.lspCapabilities,
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
	vim.cmd("LspStart")
end)