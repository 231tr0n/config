-- MiniDeps auto download setup
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
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
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Setup MiniDeps
require("mini.deps").setup({ path = { package = path_package } })
-- Export add, now and later functions from MiniDeps
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Globals variables and functions declared and used
now(function()
	Global = {
		-- Lsp capabilities used
		lspCapabilities = vim.lsp.protocol.make_client_capabilities(),
	}
	Global.lspCapabilities.textDocument.completion.completionItem.snippetSupport = true
	-- Mapping functions to map keys
	Tmap = function(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.desc = desc
		vim.keymap.set("t", suffix, rhs, opts)
	end
	Nmap = function(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.desc = desc
		vim.keymap.set("n", suffix, rhs, opts)
	end
	Vmap = function(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.desc = desc
		vim.keymap.set("v", suffix, rhs, opts)
	end
	Imap = function(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.desc = desc
		vim.keymap.set("i", suffix, rhs, opts)
	end
	Smap = function(suffix, rhs, desc, opts)
		opts = opts or {}
		opts.desc = desc
		vim.keymap.set("s", suffix, rhs, opts)
	end
	Xmap = function(suffix, rhs, desc, opts)
		opts = opts or {}
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
	-- let g:python_recommended_style=0
	-- vim.o.colorcolumn = "150"
	-- vim.o.relativenumber = true
	vim.cmd("packadd cfilter")
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "
	vim.g.nerd_font = true
	vim.o.breakindent = true
	vim.o.completeopt = "menu,menuone,noselect"
	vim.o.conceallevel = 2
	vim.o.cursorcolumn = false
	vim.o.cursorline = true
	vim.o.expandtab = true
	vim.o.fillchars = [[eob: ,foldopen:▾,foldsep: ,foldclose:▸]] -- ,
	vim.o.foldcolumn = "1"
	vim.o.foldenable = true
	vim.o.foldlevel = 99
	vim.o.foldlevelstart = 99
	vim.o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
	vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"
	vim.o.hlsearch = true
	vim.o.ignorecase = true
	vim.o.incsearch = true
	vim.o.laststatus = 3
	vim.o.list = true
	vim.o.listchars = "tab:  ,trail: ,extends:»,precedes:«,nbsp:⦸" -- ¬
	vim.o.maxmempattern = 10000
	vim.o.mouse = "a"
	vim.o.mousescroll = "ver:5,hor:5"
	vim.o.number = true
	vim.o.path = "**"
	vim.o.pumblend = 0
	vim.o.scrolloff = 999
	vim.o.shiftwidth = 2
	vim.o.showcmd = true
	vim.o.showmatch = true
	vim.o.showmode = false
	vim.o.signcolumn = "auto:1"
	vim.o.smartcase = true
	vim.o.splitbelow = true
	vim.o.splitright = true
	vim.o.synmaxcol = 100
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
	vim.opt.wildignore:append(
		"*.png,*.jpg,*.jpeg,*.gif,*.wav,*.aiff,*.dll,*.pdb,*.mdb,*.so,*.swp,*.zip,*.gz,*.bz2,*.meta,*.svg,*.cache,*/.git/*"
	)
end)

-- Initial UI setup
now(function()
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
	add("folke/tokyonight.nvim")
	require("tokyonight").setup({
		style = "storm",
		light_style = "day",
		transparent = false,
		terminal_colors = true,
		styles = {
			comments = { italic = true },
			keywords = {},
			functions = {},
			variables = {},
			sidebars = "transparent",
			floats = "transparent",
		},
		day_brightness = 0.3,
		dim_inactive = false,
		cache = true,
		plugins = {
			all = true,
		},
	})
	vim.cmd.colorscheme("tokyonight")
	add("luukvbaal/statuscol.nvim")
	require("statuscol").setup({
		relculright = false,
		bt_ignore = { "terminal", "\\[dap-repl-*\\]" },
		ft_ignore = { "ministarter", "help" },
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

-- Mini plugins setup
now(function()
	require("mini.ai").setup()
	require("mini.align").setup()
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
				{ mode = "n", keys = "<Leader>a", desc = "+Ai" },
				{ mode = "n", keys = "<Leader>b", desc = "+Buffer" },
				{ mode = "n", keys = "<Leader>c", desc = "+Clipboard" },
				{ mode = "n", keys = "<Leader>d", desc = "+Debug" },
				{ mode = "n", keys = "<Leader>e", desc = "+Explorer" },
				{ mode = "n", keys = "<Leader>f", desc = "+Find" },
				{ mode = "n", keys = "<Leader>g", desc = "+Generate" },
				{ mode = "n", keys = "<Leader>l", desc = "+Lsp" },
				{ mode = "n", keys = "<Leader>lj", desc = "+Java" },
				{ mode = "n", keys = "<Leader>q", desc = "+Quickfix" },
				{ mode = "n", keys = "<Leader>t", desc = "+Test" },
				{ mode = "n", keys = "<Leader>tg", desc = "+Go" },
				{ mode = "n", keys = "<Leader>tj", desc = "+Java" },
				{ mode = "n", keys = "<Leader>tp", desc = "+Python" },
				{ mode = "n", keys = "<Leader>x", desc = "+Trouble" },
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
	require("mini.comment").setup()
	require("mini.completion").setup({
		window = {
			info = { border = "rounded" },
			signature = { border = "rounded" },
		},
	})
	-- This makes completion faster by suggesting words from current buffer only
	vim.cmd("set complete=.")
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
			hl_words = require("mini.extra").gen_highlighter.words({ "TEST: " }, "MiniHipatternsTodo"),
		},
	})
	require("mini.icons").setup({
		lsp = {
			ollama = { glyph = "", hl = "MiniIconsGreen" },
		},
	})
	MiniIcons.mock_nvim_web_devicons()
	MiniIcons.tweak_lsp_kind()
	require("mini.indentscope").setup({
		symbol = "│",
		draw = {
			delay = 0,
			animation = require("mini.indentscope").gen_animation.none(),
			priority = 10000,
		},
	})
	require("mini.jump").setup()
	require("mini.jump2d").setup()
	require("mini.misc").setup()
	MiniMisc.setup_auto_root({ ".git", "Makefile", "go.mod", "package.json", "pom.xml" })
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
	require("mini.pairs").setup({
		mappings = {
			["<"] = { action = "open", pair = "<>", neigh_pattern = "[^\\]." },
			[">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },
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
			require("mini.starter").sections.recent_files(5, false),
			require("mini.starter").sections.recent_files(5, true),
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
				local diagnostics = MiniStatusline.section_diagnostics({
					trunc_width = 75,
					signs = { ERROR = " ", WARN = " ", INFO = " ", HINT = " " },
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
	require("mini.surround").setup()
	require("mini.tabline").setup({
		tabpage_section = "right",
	})
	require("mini.trailspace").setup()
end)

-- Non lazy plugins registration
now(function()
	add("neovim/nvim-lspconfig")
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
		-- Disable indent module if file size is greater than 2MB
		indent = {
			enable = true,
			disable = function(lang, buf)
				local max_filesize = 2 * 1024 * 1024
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					return true
				end
			end,
		},
		incremental_selection = {
			enable = false,
		},
		-- Disable highlight module if file size is greater than 2MB
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
	vim.wo.foldmethod = "expr"
	vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	add("mfussenegger/nvim-dap")
	local dap = require("dap")
	dap.defaults.fallback.force_external_terminal = true
	dap.defaults.fallback.terminal_win_cmd = "belowright new | resize 15"
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
		prepend_args = { "-s" },
	}
	vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
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
			"mini.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("helpview").setup()
	add({
		source = "MeanderingProgrammer/render-markdown.nvim",
		depends = {
			"mini.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("render-markdown").setup()
	add({
		source = "danymat/neogen",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	require("neogen").setup()
	add({
		source = "mfussenegger/nvim-jdtls",
		depends = {
			"mfussenegger/nvim-dap",
			"neovim/nvim-lspconfig",
		},
	})
end)

-- New commands registration
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
	Imap("<CR>", crAction, "Enter to select in wildmenu", { expr = true })
	Imap("<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], "Cycle wildmenu anti-clockwise", { expr = true })
	Imap("<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], "Cycle wildmenu clockwise", { expr = true })
	Nmap("<C-Space>", toggleTerminal, "Toggle terminal")
	Nmap("<F2>", ":nohl<CR>", "Remove search highlight")
	Nmap("<F3>", MiniNotify.clear, "Clear all notifications")
	Nmap("<F4>", ":Inspect<CR>", "Echo syntax group")
	Nmap("<Space><Space><Space>", toggleSpaces, "Expand tabs")
	Nmap("<Tab><Tab><Tab>", toggleTabs, "Contract tabs")
	Nmap("<leader>bD", ":lua MiniBufremove.delete(0, true)<CR>", "Delete!")
	Nmap("<leader>bW", ":lua MiniBufremove.wipeout(0, true)<CR>", "Wipeout!")
	Nmap("<leader>ba", ":b#<CR>", "Alternate")
	Nmap("<leader>bc", "::close<CR>", "Close window")
	Nmap("<leader>bd", ":lua MiniBufremove.delete()<CR>", "Delete")
	Nmap("<leader>bu", ":UndotreeToggle<CR>", "Undo tree toggle")
	Nmap("<leader>bw", ":lua MiniBufremove.wipeout()<CR>", "Wipeout")
	Nmap("<leader>cP", '"+P', "Paste to clipboard")
	Nmap("<leader>cX", '"+X', "Cut to clipboard")
	Nmap("<leader>cY", '"+Y', "Copy to clipboard")
	Nmap("<leader>cp", '"+p', "Paste to clipboard")
	Nmap("<leader>cx", '"+x', "Cut to clipboard")
	Nmap("<leader>cy", '"+y', "Copy to clipboard")
	Nmap("<leader>dC", ":lua require('dap').clear_breakpoints()<CR>", "Clear breakpoints")
	Nmap("<leader>dL", ":lua require('osv').launch({ port = 8086 })<CR>", "Lua debug launch")
	Nmap("<leader>dLr", ":lua require('osv').run_this()<CR>", "Lua debug")
	Nmap("<leader>db", ":lua require('dap').list_breakpoints()<CR>", "List breakpoints")
	Nmap("<leader>dc", ":lua require('dap').continue()<CR>", "Continue")
	Nmap("<leader>df", ":lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').frames)<CR>", "Frames")
	Nmap("<leader>dh", ":lua require('dap.ui.widgets').hover()<CR>", "Hover value")
	Nmap("<leader>dl", ":lua require('dap').run_last()<CR>", "Run Last")
	Nmap("<leader>dlp", ":lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log: '))<CR>", "Set log point")
	Nmap("<leader>dp", ":lua require('dap.ui.widgets').preview()<CR>", "Preview")
	Nmap("<leader>dr", ":lua require('dap').repl.open({}, '30vsplit new')<CR>", "Open Repl")
	Nmap("<leader>ds", ":lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets'.scopes)<CR>", "Scopes")
	Nmap("<leader>dsO", ":lua require('dap').step_over()<CR>", "Step over")
	Nmap("<leader>dsi", ":lua require('dap').step_into()<CR>", "Step into")
	Nmap("<leader>dso", ":lua require('dap').step_out()<CR>", "Step out")
	Nmap("<leader>dt", ":lua require('dap').toggle_breakpoint()<CR>", "Toggle breakpoint")
	Nmap("<leader>et", ":lua if not MiniFiles.close() then MiniFiles.open() end<CR>", "Toggle file explorer")
	Nmap("<leader>gc", ":lua require('neogen').generate({ type = 'class' })<CR>", "Generate class annotations")
	Nmap("<leader>gf", ":lua require('neogen').generate({ type = 'file' })<CR>", "Generate file annotations")
	Nmap("<leader>gf", ":lua require('neogen').generate({ type = 'func' })<CR>", "Generate function annotations")
	Nmap("<leader>gg", ":lua require('neogen').generate()<CR>", "Generate annotations")
	Nmap("<leader>gt", ":lua require('neogen').generate({ type = 'type' })<CR>", "Generate type annotations")
	Nmap("<leader>lF", ":lua vim.lsp.buf.format({async = true})<CR>", "Lsp Format")
	Nmap("<leader>lc", ":lua vim.lsp.buf.code_action()<CR>", "Code action")
	Nmap("<leader>ldh", ":lua vim.diagnostic.open_float()<CR>", "Hover diagnostics")
	Nmap("<leader>ldn", ":lua vim.diagnostic.goto_next()<CR>", "Goto next diagnostic")
	Nmap("<leader>ldp", ":lua vim.diagnostic.goto_prev()<CR>", "Goto prev diagnostic")
	Nmap("<leader>ldt", diagnosticVirtualTextToggle, "Virtual text toggle")
	Nmap("<leader>lf", ":Format<CR>", "Format code")
	Nmap("<leader>lgD", ":lua vim.lsp.buf.declaration()<CR>", "Goto declaration")
	Nmap("<leader>lgb", "<C-t>", "Previous tag")
	Nmap("<leader>lgd", ":lua vim.lsp.buf.definition()<CR>", "Goto definition")
	Nmap("<leader>lgi", ":lua vim.lsp.buf.implementation()<CR>", "Goto implementation")
	Nmap("<leader>lgr", ":lua vim.lsp.buf.references()<CR>", "Goto references")
	Nmap("<leader>lgs", ":lua vim.lsp.buf.signature_help()<CR>", "Signature help")
	Nmap("<leader>lgtd", ":lua vim.lsp.buf.type_definition()<CR>", "Goto type definition")
	Nmap("<leader>lh", ":lua vim.lsp.buf.hover()<CR>", "Hover symbol")
	Nmap("<leader>li", ":lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>", "Inlay hints toggle")
	Nmap("<leader>ljo", ":lua require('jdtls').organize_imports()<CR>", "Organize imports")
	Nmap("<leader>ljv", ":lua require('jdtls').extract_variable()<CR>", "Extract variable")
	Nmap("<leader>lr", ":lua vim.lsp.buf.rename()<CR>", "Rename")
	Nmap("<leader>tjc", ":lua require('jdtls').test_class()<CR>", "Test class")
	Nmap("<leader>tjm", ":lua require('jdtls').test_nearest_method()<CR>", "Test method")
	Nmap("gB", ":norm gxiagxila<CR>", "Move arg left")
	Nmap("gb", ":norm gxiagxina<CR>", "Move arg right")
	Nmap("gl", ":lua MiniGit.show_at_cursor()<CR>", "Git line history")
	Nmap("gz", ":lua MiniDiff.toggle_overlay()<CR>", "Show diff")
	Tmap("<Esc>", "<C-\\><C-n>", "Escape terminal mode")
	Vmap("<leader>cP", '"+P', "Paste to clipboard")
	Vmap("<leader>cX", '"+X', "Cut to clipboard")
	Vmap("<leader>cY", '"+Y', "Copy to clipboard")
	Vmap("<leader>cp", '"+p', "Paste to clipboard")
	Vmap("<leader>cx", '"+x', "Cut to clipboard")
	Vmap("<leader>cy", '"+y', "Copy to clipboard")
	Xmap("<leader>lf", ":Format<CR>", "Format code")
end)

-- Autocommands registration
now(function()
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
			if vim.bo.filetype == "NvimTree" or vim.bo.filetype == "netrw" then
				vim.b.minicursorword_disable = true
			elseif vim.bo.filetype == "dap-repl" then
				-- Dap repl autocompletion setup
				require("dap.ext.autocompl").attach()
				vim.b.miniindentscope_disable = true
			elseif
				vim.bo.filetype == "svelte"
				or vim.bo.filetype == "jsx"
				or vim.bo.filetype == "html"
				or vim.bo.filetype == "xml"
				or vim.bo.filetype == "xsl"
				or vim.bo.filetype == "javascriptreact"
			then
				-- HTML tag completion with >, >> and >>>
				vim.bo.omnifunc = "htmlcomplete#CompleteTags"
				MiniPairs.unmap("i", "<", "")
				MiniPairs.unmap("i", ">", "")
				vim.keymap.set("i", "><Space>", ">")
				vim.keymap.set("i", ">", "><Esc>yyppk^Dj^Da</<C-x><C-o><C-x><C-o><C-p><C-p><Esc>ka<Tab>")
				vim.keymap.set("i", ">>", "><Esc>F<f>a</<C-x><C-o><C-x><C-o><C-p><C-p><Esc>vit<Esc>i")
				vim.keymap.set("i", ">>>", "><Esc>F<f>a</<C-x><C-o><C-x><C-o><C-p><C-p><Space><BS>")
			elseif vim.bo.filetype == "java" then
				-- Java lsp lazy loading setup
				require("jdtls").start_or_attach((function()
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
									enabled = true,
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
						capabilities = Global.lspCapabilities,
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
				end)())
			end
		end,
	})
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			-- Disable semantic highlighting
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			client.server_capabilities.semanticTokensProvider = nil
			vim.diagnostic.config({
				virtual_text = true,
				underline = false,
			})
			vim.wo.winbar = "  %{%v:lua.Global.symbols.get()%}"
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

-- Lazy loaded plugins registration
later(function()
	add({
		source = "junegunn/fzf",
		hooks = {
			post_checkout = function()
				vim.cmd("call fzf#install()")
			end,
		},
	})
	add({
		source = "ibhagwan/fzf-lua",
		depends = {
			"mini.nvim",
			"junegunn/fzf",
		},
	})
	add("stevearc/quicker.nvim")
	require("quicker").setup({
		opts = {
			number = false,
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
		source = "folke/trouble.nvim",
		depends = {
			"mini.nvim",
			"neovim/nvim-lspconfig",
			"ibhagwan/fzf-lua",
		},
	})
	local fzf_config = require("fzf-lua.config")
	local fzf_actions = require("trouble.sources.fzf").actions
	fzf_config.defaults.actions.files["ctrl-t"] = fzf_actions.open
	require("trouble").setup()
	Global.symbols = require("trouble").statusline({
		mode = "lsp_document_symbols",
		groups = {},
		title = false,
		filter = { range = true },
		format = "> {kind_icon}{symbol.name:Normal}",
		hl_group = "WinBar",
	})
	add("mfussenegger/nvim-lint")
	add({
		source = "leoluz/nvim-dap-go",
		depends = {
			"mfussenegger/nvim-dap",
		},
	})
	add({
		source = "mfussenegger/nvim-dap-python",
		depends = {
			"mfussenegger/nvim-dap",
		},
	})
	add({
		source = "jbyuki/one-small-step-for-vimkind",
		depends = {
			"mfussenegger/nvim-dap",
		},
	})
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
	add("David-Kunz/gen.nvim")
	require("gen").setup({
		model = "llama3.1",
		host = "localhost",
		port = "11434",
		display_mode = "split",
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
	add("mbbill/undotree")
end)

-- Lazy autocommands registration
later(function()
	-- vim.api.nvim_create_autocmd("BufRead", {
	-- 	callback = function(ev)
	-- 		if vim.bo[ev.buf].buftype == "quickfix" then
	-- 			vim.schedule(function()
	-- 				vim.cmd("cclose")
	-- 				vim.cmd("Trouble qflist open")
	-- 			end)
	-- 		elseif vim.bo[ev.buf].buftype == "loclist" then
	-- 			vim.schedule(function()
	-- 				vim.cmd("lclose")
	-- 				vim.cmd("Trouble loclist open")
	-- 			end)
	-- 		end
	-- 	end,
	-- })
end)

-- Lazy loaded keymaps registration
later(function()
	Imap("<C-x><C-f>", require("fzf-lua").complete_path, "Fuzzy complete path")
	Nmap("<leader>am", require("gen").select_model, "Select model")
	Nmap("<leader>ap", ":Gen<CR>", "Prompt Model")
	Nmap("<leader>fC", ":FzfLua colorschemes<CR>", "Change colorschemes")
	Nmap("<leader>fL", ":FzfLua lines<CR>", "Search lines")
	Nmap("<leader>fS", ":FzfLua live_grep_native<CR>", "Search content live")
	Nmap("<leader>fT", ":FzfLua tags<CR>", "Search tags")
	Nmap("<leader>fX", ":FzfLua diagnostics_workspace<CR>", "Search workspace diagnostics")
	Nmap("<leader>fY", ":FzfLua lsp_workspace_symbols<CR>", "Search workspace symbols")
	Nmap("<leader>fb", ":FzfLua buffers<CR>", "Search buffers")
	Nmap("<leader>fc", ":FzfLua lsp_code_actions<CR>", "Code Actions")
	Nmap("<leader>fdb", ":FzfLua dap_breakpoints<CR>", "Search dap breakpoints")
	Nmap("<leader>fdc", ":FzfLua dap_configurations<CR>", "Search dap configurations")
	Nmap("<leader>fdf", ":FzfLua dap_frames<CR>", "Search dap frames")
	Nmap("<leader>fdv", ":FzfLua dap_variables<CR>", "Search dap variables")
	Nmap("<leader>ff", ":FzfLua files<CR>", "Search files")
	Nmap("<leader>fgC", ":FzfLua git_commits<CR>", "Search commits")
	Nmap("<leader>fgS", ":FzfLua git_stash<CR>", "Search git stash")
	Nmap("<leader>fgb", ":FzfLua git_branches<CR>", "Search branches")
	Nmap("<leader>fgc", ":FzfLua git_bcommits<CR>", "Search buffer commits")
	Nmap("<leader>fgf", ":FzfLua git_files<CR>", "Search Git files")
	Nmap("<leader>fgs", ":FzfLua git_status<CR>", "Search git status")
	Nmap("<leader>fgt", ":FzfLua git_tags<CR>", "Search git tags")
	Nmap("<leader>fh", ":FzfLua highlights<CR>", "Search highlight groups")
	Nmap("<leader>fj", ":FzfLua jumps<CR>", "Search jumps")
	Nmap("<leader>fk", ":FzfLua keymaps<CR>", "Search keymaps")
	Nmap("<leader>fl", ":FzfLua blines<CR>", "Search buffer lines")
	Nmap("<leader>fm", ":FzfLua marks<CR>", "Search marks")
	Nmap("<leader>fo", ":FzfLua loclist<CR>", "Search loclist")
	Nmap("<leader>fq", ":FzfLua quickfix<CR>", "Search quickfix")
	Nmap("<leader>fs", ":FzfLua grep_project<CR>", "Search content")
	Nmap("<leader>ft", ":FzfLua btags<CR>", "Search buffer tags")
	Nmap("<leader>fx", ":FzfLua diagnostics_document<CR>", "Search document diagnostics")
	Nmap("<leader>fy", ":FzfLua lsp_document_symbols<CR>", "Search document symbols")
	Nmap("<leader>qc", ":lua require('quicker').collapse()<CR>", "Collapse")
	Nmap("<leader>qe", ":lua require('quicker').expand({before = 2, after = 2, add_to_existing = true})<CR>", "Expand")
	Nmap("<leader>ql", ":lua require('quicker').toggle({ loclist = true })<CR>", "Toggle loclist")
	Nmap("<leader>qq", ":lua require('quicker').toggle()<CR>", "Toggle quickfix")
	Nmap("<leader>tgm", ":lua require('dap-go').debug_test()<CR>", "Test method")
	Nmap("<leader>tpc", ":lua require('dap-python').test_class()<CR>", "Test class")
	Nmap("<leader>tpm", ":lua require('dap-python').test_method()<CR>", "Test method")
	Nmap("<leader>tps", ":lua require('dap-python').debug_selection()<CR>", "Debug selection")
	Nmap("<leader>xl", "<cmd>Trouble loclist toggle<cr>", "Toggle loclist")
	Nmap("<leader>xq", "<cmd>Trouble qflist toggle<cr>", "Toggle quickfix")
	Nmap("<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "Toggle LSP Defs/refs")
	Nmap("<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", "Toggle symbols")
	Nmap("<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", "Toggle diagnostics")
	Nmap("<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Toggle buffer diagnostics")
	Smap("<leader>ap", ":Gen<CR>", "Prompt Model")
	Xmap("<leader>ap", ":Gen<CR>", "Prompt Model")
end)

-- Lazy loaded dap configurations setup
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
	dap.adapters.lldb = {
		type = "executable",
		command = (function()
			if vim.fn.empty(os.execute("which lldb-vscode")) == 0 then
				return "/usr/bin/lldb-dap-18"
			end
			return "/usr/bin/lldb-dap"
		end)(),
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

-- Lazy loaded lsp configurations setup
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

-- Lazy loaded custom configuration
later(function()
	vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
	vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
	vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
	vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
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
