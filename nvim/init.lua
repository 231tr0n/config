-- MiniDeps auto download and configure setup
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
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
require("mini.deps").setup({ path = { package = path_package } })

-- add, now and later functions from MiniDeps
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Globals declared and used
Global = {
	virtual_text = false,
}

now(function()
	-- Default settings
	-- let g:python_recommended_style=0
	vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
	vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
	vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
	vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
	vim.g.mapleader = " "
	vim.o.conceallevel = 2
	vim.o.fillchars = [[eob: ,foldopen:▾,foldsep: ,foldclose:▸]]
	-- vim.o.fillchars = [[eob: ,foldopen:,foldsep: ,foldclose:]]
	vim.o.foldcolumn = "1"
	vim.o.foldenable = true
	vim.o.foldlevel = 99
	vim.o.foldlevelstart = 99
	vim.o.ignorecase = true
	vim.o.listchars = "eol:¬,tab:│ ,trail:~,extends:>,precedes:<"
	vim.o.mousescroll = "ver:5,hor:5"
	vim.o.showcmd = true
	vim.o.showmatch = true
	vim.o.showmode = false
	vim.o.smartcase = true
	vim.o.termguicolors = true
	vim.o.textwidth = 0
	vim.o.updatetime = 500
	vim.o.wildmode = "longest:full,full"
	vim.o.wrap = true
	vim.opt.cursorcolumn = false
	vim.opt.cursorline = true
	vim.opt.expandtab = true
	vim.opt.hlsearch = true
	vim.opt.incsearch = true
	vim.opt.laststatus = 3
	vim.opt.list = true
	vim.opt.matchpairs:append("<:>")
	vim.opt.maxmempattern = 20000
	vim.opt.number = true
	vim.opt.relativenumber = true
	vim.opt.scrolloff = 999
	vim.opt.shiftwidth = 2
	vim.opt.signcolumn = "auto"
	vim.opt.tabstop = 2
	vim.opt.undofile = false
	vim.opt.wildmenu = true
	vim.cmd("filetype plugin on")
	vim.cmd("filetype plugin indent off")
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

	-- Mini plugins initialisation
	require("mini.ai").setup()
	require("mini.align").setup()
	-- require("mini.animate").setup({ scroll = { enable = false } })
	-- require("mini.base16").setup({
	-- 	-- solarized dark color palette
	-- 	palette = {
	-- 		base00 = "#002B36",
	-- 		base01 = "#073642",
	-- 		base02 = "#586E75",
	-- 		base03 = "#657B83",
	-- 		base04 = "#839496",
	-- 		base05 = "#93A1A1",
	-- 		base06 = "#EEE8D5",
	-- 		base07 = "#FDF6E3",
	-- 		base08 = "#DC322F",
	-- 		base09 = "#CB4B16",
	-- 		base0A = "#B58900",
	-- 		base0B = "#859900",
	-- 		base0C = "#2AA198",
	-- 		base0D = "#268BD2",
	-- 		base0E = "#6C71C4",
	-- 		base0F = "#D33682",
	-- 	},
	-- 	-- one dark color palette
	-- 	-- palette = {
	-- 	-- 	base00 = "#282C34",
	-- 	-- 	base01 = "#353B45",
	-- 	-- 	base02 = "#3E4451",
	-- 	-- 	base03 = "#545862",
	-- 	-- 	base04 = "#565C64",
	-- 	-- 	base05 = "#ABB2BF",
	-- 	-- 	base06 = "#B6BDCA",
	-- 	-- 	base07 = "#C8CCD4",
	-- 	-- 	base08 = "#E06C75",
	-- 	-- 	base09 = "#D19A66",
	-- 	-- 	base0A = "#E5C07B",
	-- 	-- 	base0B = "#98C379",
	-- 	-- 	base0C = "#56B6C2",
	-- 	-- 	base0D = "#61AFEF",
	-- 	-- 	base0E = "#C678DD",
	-- 	-- 	base0F = "#BE5046",
	-- 	-- },
	-- })
	require("mini.basics").setup({
		-- options = {
		-- extra_ui = true,
		-- },
		mappings = {
			windows = true,
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
				{ mode = "n", keys = "<Leader>d", desc = "+Debug" },
				{ mode = "n", keys = "<Leader>e", desc = "+Explorer" },
				{ mode = "n", keys = "<Leader>f", desc = "+Find" },
				{ mode = "n", keys = "<Leader>g", desc = "+Generate" },
				{ mode = "n", keys = "<Leader>l", desc = "+Lsp" },
				{ mode = "n", keys = "<Leader>lj", desc = "+Java" },
				{ mode = "n", keys = "<Leader>r", desc = "+Rest" },
				{ mode = "n", keys = "<Leader>t", desc = "+Test" },
				{ mode = "n", keys = "<Leader>tg", desc = "+Go" },
				{ mode = "n", keys = "<Leader>tj", desc = "+Java" },
				{ mode = "n", keys = "<Leader>tp", desc = "+Python" },
				{ mode = "n", keys = "<Leader>v", desc = "+Visits" },
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
		},
	})
	require("mini.comment").setup()
	-- require("mini.completion").setup({
	--  window = {
	--    info = { border = "single" },
	--    signature = { border = "single" },
	--  },
	-- })
	require("mini.cursorword").setup()
	require("mini.diff").setup()
	-- require("mini.doc").setup()
	require("mini.extra").setup()
	require("mini.files").setup({
		windows = {
			preview = true,
			width_preview = 75,
		},
		options = {
			permanent_delete = true,
			use_as_default_explorer = false,
		},
	})
	require("mini.fuzzy").setup()
	require("mini.git").setup()
	require("mini.hipatterns").setup({
		highlighters = {
			fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
			hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
			todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
			note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
			hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
			-- hl_words = require("mini.extra").gen_highlighter.words({ "TEST: " }, "MiniHipatternsTodo"),
		},
	})
	-- math.randomseed(vim.loop.hrtime())
	-- require("mini.hues").setup(require("mini.hues").gen_random_base_colors())
	-- require("mini.hues").setup({
	--  -- background = "#1c1c1c",
	--  -- foreground = "#83a598",
	--  background = "#11262D",
	--  foreground = "#C0C8CC",
	--  n_hues = 8,
	--  accent = "bg",
	--  saturation = "high",
	-- })
	-- require("mini.colors").setup()
	-- local colors = require("mini.colors")
	-- colors
	-- 	.get_colorscheme()
	-- 	:add_transparency({
	-- 		general = true,
	-- 		float = true,
	-- 		statuscolumn = true,
	-- 		statusline = false,
	-- 		tabline = true,
	-- 		winbar = true,
	-- 	})
	-- 	:apply()
	require("mini.icons").setup({
		lsp = {
			ollama = { glyph = "", hl = "MiniIconsGreen" },
		},
	})
	MiniIcons.mock_nvim_web_devicons()
	require("mini.indentscope").setup({
		symbol = "│",
		draw = {
			delay = 0,
			animation = require("mini.indentscope").gen_animation.none(),
		},
	})
	require("mini.jump").setup()
	require("mini.jump2d").setup()
	-- require("mini.map").setup()
	require("mini.misc").setup()
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
	require("mini.operators").setup()
	-- require("mini.pairs").setup({
	--  mappings = {
	--    ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^\\]." },
	--    [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },
	--  },
	-- })
	require("mini.pick").setup()
	vim.ui.select = MiniPick.ui_select
	require("mini.sessions").setup()
	require("mini.splitjoin").setup()
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
			-- inactive = function()
			--  local git = MiniStatusline.section_git({ trunc_width = 75 })
			--  local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
			--  local filename = MiniStatusline.section_filename({ trunc_width = 140 })
			--  if filename:sub(1, 2) == "%F" or filename:sub(1, 2) == "%f" then
			--    filename = filename:sub(1, 2) .. " " .. filename:sub(3, -1)
			--  end
			--  local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 1000 })
			--  return MiniStatusline.combine_groups({
			--    { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
			--    "%<",
			--    { hl = "MiniStatuslineFileinfo", strings = { filename } },
			--    "%=",
			--    { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
			--  })
			-- end,
		},
		set_vim_settings = false,
	})
	require("mini.surround").setup()
	require("mini.tabline").setup({
		tabpage_section = "right",
	})
	-- require("mini.test").setup()
	require("mini.trailspace").setup()
	require("mini.visits").setup()

	-- Plugin installation
	-- Vimscript plugins
	add("mbbill/undotree")
	add({
		source = "junegunn/fzf",
		hooks = {
			post_checkout = function()
				vim.cmd("call fzf#install()")
			end,
		},
	})
	-- Lua plugins
	add("MunifTanjim/nui.nvim")
	add("nvim-lua/plenary.nvim")
	add("nvim-neotest/nvim-nio")
	add("luukvbaal/statuscol.nvim")
	add("neovim/nvim-lspconfig")
	add("lukas-reineke/indent-blankline.nvim")
	add("rafamadriz/friendly-snippets")
	add("mfussenegger/nvim-dap")
	add("mfussenegger/nvim-lint")
	add("stevearc/conform.nvim")
	add("David-Kunz/gen.nvim")
	add("folke/tokyonight.nvim")
	add("scottmckendry/cyberdream.nvim")
	add({
		source = "folke/ts-comments.nvim",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	add({
		source = "OXY2DEV/helpview.nvim",
		depends = {
			"mini.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	})
	add({
		source = "MeanderingProgrammer/render-markdown.nvim",
		depends = {
			"mini.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	})
	add({
		source = "L3MON4D3/LuaSnip",
		hooks = {
			post_checkout = function(args)
				local temp = vim.fn.getcwd()
				vim.cmd(args.path)
				vim.cmd("make install_jsregexp")
				vim.cmd(temp)
			end,
		},
	})
	add({
		source = "nvim-treesitter/nvim-treesitter",
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
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
	add({
		source = "rcarriga/nvim-dap-ui",
		depends = {
			"mini.nvim",
			"nvim-neotest/nvim-nio",
			"mfussenegger/nvim-dap",
		},
	})
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
		source = "mfussenegger/nvim-jdtls",
		depends = {
			"mfussenegger/nvim-dap",
			"neovim/nvim-lspconfig",
		},
	})
	add({
		source = "jbyuki/one-small-step-for-vimkind",
		depends = {
			"mfussenegger/nvim-dap",
		},
	})
	add({
		source = "nvim-pack/nvim-spectre",
		depends = {
			"nvim-lua/plenary.nvim",
		},
	})
	add({
		source = "danymat/neogen",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	add({
		source = "MysticalDevil/inlay-hints.nvim",
		depends = {
			"neovim/nvim-lspconfig",
		},
	})
	add({
		source = "bennypowers/nvim-regexplainer",
		depends = {
			"nvim-treesitter/nvim-treesitter",
			"MunifTanjim/nui.nvim",
		},
	})
	add({
		source = "HiPhish/rainbow-delimiters.nvim",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	add({
		source = "nvim-treesitter/nvim-treesitter-context",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	add({
		source = "windwp/nvim-autopairs",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	add({
		source = "windwp/nvim-ts-autotag",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	add({
		source = "RRethy/nvim-treesitter-endwise",
		depends = {
			"nvim-treesitter/nvim-treesitter",
		},
	})
	add({
		source = "nvim-tree/nvim-tree.lua",
		depends = {
			"mini.nvim",
		},
	})
	add({
		source = "tzachar/cmp-ai",
		depends = {
			"nvim-lua/plenary.nvim",
		},
	})
	add({
		source = "hrsh7th/nvim-cmp",
		depends = {
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp",
			"tzachar/cmp-ai",
			"hrsh7th/cmp-nvim-lsp-signature-help",
		},
	})
	add({
		source = "saadparwaiz1/cmp_luasnip",
		depends = {
			"hrsh7th/nvim-cmp",
			"L3MON4D3/LuaSnip",
		},
	})
	add({
		source = "folke/trouble.nvim",
		depends = {
			"mini.nvim",
			"ibhagwan/fzf-lua",
		},
	})
	add("mistweaverco/kulala.nvim")

	-- Utility libraries
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
				text = { require("statuscol.builtin").foldfunc },
				click = "v:lua.ScFa",
			},
			{
				text = { "│ " },
				hl = "LineNr",
			},
		},
	})
	require("cyberdream").setup({
		transparent = true,
		italic_comments = true,
		hide_fillchars = false,
		borderless_telescope = false,
		terminal_colors = true,
		theme = {
			variant = "default",
			highlights = {},
			overrides = function(colors)
				return {
					["@variable.member"] = { fg = colors.pink },
					["@lsp.type.property"] = { fg = colors.pink },
					["Identifier"] = { fg = colors.pink },
				}
			end,
			colors = {
				fg = "#dce1dd",
			},
		},
	})
	require("tokyonight").setup({
		style = "storm",
		light_style = "day",
		transparent = true,
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
		dim_inactive = true,
		on_colors = function(colors) end,
		cache = true,
		plugins = {
			all = true,
		},
	})
	vim.cmd.colorscheme("tokyonight")
	require("nvim-tree").setup()
	require("spectre").setup()
	require("fzf-lua").setup({
		"max-perf",
		fzf_colors = true,
		winopts = {
			width = 0.85,
			height = 0.85,
			preview = {
				default = "bat",
				vertical = "up:50%",
				layout = "vertical",
			},
		},
		fzf_opts = {
			["--layout"] = "default",
		},
	})
	local fzf_config = require("fzf-lua.config")
	local fzf_actions = require("trouble.sources.fzf").actions
	fzf_config.defaults.actions.files["ctrl-t"] = fzf_actions.open
	require("kulala").setup({
		default_view = "body",
		default_env = "dev",
		debug = false,
		additional_curl_options = {},
		winbar = true,
	})

	-- Lsp, auto completion and snippet setup
	local cmp = require("cmp")
	local luasnip = require("luasnip")
	local cmp_ai = require("cmp_ai.config")
	cmp_ai:setup({
		max_lines = 100,
		provider = "Ollama",
		provider_options = {
			model = "dolphin-llama3:latest",
		},
		run_on_every_keystroke = false,
		ignored_file_types = {},
	})
	local cmp_autopairs = require("nvim-autopairs.completion.cmp")
	local has_words_before = function()
		unpack = unpack or table.unpack
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
	end
	cmp.setup({
		formatting = {
			format = function(_, item)
				local icon, hl = MiniIcons.get("lsp", item.kind)
				item.kind = icon .. " " .. item.kind
				item.kind_hl_group = hl
				return item
			end,
		},
		snippet = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body)
			end,
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		mapping = cmp.mapping.preset.insert({
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = true }),
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				elseif has_words_before() then
					cmp.complete()
				else
					fallback()
				end
			end, { "i", "s" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),
			["<C-x>"] = cmp.mapping(
				cmp.mapping.complete({
					config = {
						sources = cmp.config.sources({
							{ name = "cmp_ai" },
						}),
					},
				}),
				{ "i" }
			),
		}),
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "nvim_lsp_signature_help" },
			{ name = "luasnip" },
		}, {
			{ name = "buffer" },
		}),
	})
	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer" },
		},
	})
	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = "path" },
		}, {
			{ name = "cmdline" },
		}),
		matching = { disallow_symbol_nonprefix_matching = false },
	})
	cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	require("luasnip.loaders.from_vscode").lazy_load()
	require("luasnip.loaders.from_snipmate").lazy_load()
	local capabilities = require("cmp_nvim_lsp").default_capabilities()
	capabilities.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	local lspconfig = require("lspconfig")
	lspconfig.lua_ls.setup({
		capabilities = capabilities,
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
		capabilities = capabilities,
	})
	lspconfig.html.setup({
		capabilities = capabilities,
	})
	lspconfig.eslint.setup({
		capabilities = capabilities,
	})
	lspconfig.cssls.setup({
		capabilities = capabilities,
	})
	lspconfig.bashls.setup({
		capabilities = capabilities,
	})
	lspconfig.gopls.setup({
		capabilities = capabilities,
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
	-- 	capabilities = capabilities,
	-- })
	lspconfig.basedpyright.setup({
		capabilities = capabilities,
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
		capabilities = capabilities,
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
		capabilities = capabilities,
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
	-- 	capabilities = capabilities,
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
		capabilities = capabilities,
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
		capabilities = capabilities,
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
		capabilities = capabilities,
	})
	lspconfig.jsonls.setup({
		capabilities = capabilities,
	})
	lspconfig.lemminx.setup({
		capabilities = capabilities,
	})
	lspconfig.angularls.setup({
		capabilities = capabilities,
	})
	local function jdtlsConfig()
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
	require("inlay-hints").setup()
	require("trouble").setup()
	Global.symbols = require("trouble").statusline({
		mode = "lsp_document_symbols",
		groups = {},
		title = false,
		filter = { range = true },
		format = "> {kind_icon}{symbol.name:Normal}",
		hl_group = "WinBar",
	})

	-- Syntax highlighting setup
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
		highlight = {
			enable = true,
			disable = function(lang, buf)
				local max_filesize = 2 * 1024 * 1024
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					if lang == "asm" or lang == "wasm" then
						return false
					end
					return true
				end
			end,
			additional_vim_regex_highlighting = false,
		},
		endwise = {
			enable = true,
		},
	})
	vim.wo.foldmethod = "expr"
	vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	require("treesitter-context").setup()
	require("regexplainer").setup({
		mode = "narrative",
		auto = false,
		filetypes = {
			"html",
			"js",
			"cjs",
			"mjs",
			"ts",
			"jsx",
			"tsx",
			"cjsx",
			"mjsx",
		},
		debug = false,
		display = "popup",
		mappings = {
			-- toggle = "gR",
			-- show = 'gS',
			-- hide = 'gH',
			-- show_split = 'gP',
			-- show_popup = 'gU',
		},
		popup = {
			border = {
				padding = { 0, 0 },
				style = "single",
			},
		},
		narrative = {
			indendation_string = "> ",
		},
	})
	local rainbow_delimiters = require("rainbow-delimiters")
	vim.g.rainbow_delimiters = {
		strategy = {
			[""] = rainbow_delimiters.strategy["global"],
			commonlisp = rainbow_delimiters.strategy["local"],
		},
		query = {
			[""] = "rainbow-delimiters",
			-- lua = "rainbow-blocks",
		},
		highlight = {
			"RainbowDelimiterRed",
			-- "RainbowDelimiterYellow",
			-- "RainbowDelimiterBlue",
			-- "RainbowDelimiterOrange",
			-- "RainbowDelimiterGreen",
			-- "RainbowDelimiterViolet",
			-- "RainbowDelimiterCyan",
		},
	}
	require("nvim-autopairs").setup()
	require("nvim-ts-autotag").setup()
	require("ibl").setup({
		indent = {
			char = "│",
			tab_char = "│",
		},
		scope = {
			enabled = false,
			show_start = false,
			show_end = false,
		},
	})
	require("neogen").setup({ snippet_engine = "luasnip" })
	require("ts-comments").setup({
		lang = {
			text = "TODO: %s",
		},
	})
	require("render-markdown").setup()
	require("helpview").setup()
	vim.filetype.add({
		extension = {
			["http"] = "http",
		},
	})

	-- Dap setup
	vim.fn.sign_define("DapBreakpoint", { text = "󰙧", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
	vim.fn.sign_define(
		"DapBreakpointCondition",
		{ text = "●", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" }
	)
	vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
	vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
	require("dapui").setup()
	local dap, dapui = require("dap"), require("dapui")
	dap.listeners.before.attach.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.launch.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated.dapui_config = function()
		dapui.close()
	end
	dap.listeners.before.event_exited.dapui_config = function()
		dapui.close()
	end
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
	-- dap.adapters.nlua = function(callback, config)
	--  local adapter = {
	--    type = "server",
	--    host = config.host or "127.0.0.1",
	--    port = config.port or 8086,
	--  }
	--  if config.start_neovim then
	--    local dap_run = dap.run
	--    dap.run = function(c)
	--      adapter.port = c.port
	--      adapter.host = c.host
	--    end
	--    require("osv").run_this()
	--    dap.run = dap_run
	--  end
	--  callback(adapter)
	-- end
	-- dap.configurations.lua = {
	--  {
	--    type = "nlua",
	--    request = "attach",
	--    name = "Run this file",
	--    start_neovim = {},
	--  },
	--  {
	--    type = "nlua",
	--    request = "attach",
	--    name = "Attach to running Neovim instance (port = 8086)",
	--    port = 8086,
	--  },
	-- }
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
	-- dap.configurations.c = {
	--  {
	--    name = "Run executable (GDB)",
	--    type = "gdb",
	--    request = "launch",
	--    program = function()
	--      local path = vim.fn.input({
	--        prompt = "Path to executable: ",
	--        default = vim.fn.getcwd() .. "/",
	--        completion = "file",
	--      })
	--      return (path and path ~= "") and path or dap.ABORT
	--    end,
	--  },
	--  {
	--    name = "Run executable with arguments (GDB)",
	--    type = "gdb",
	--    request = "launch",
	--    program = function()
	--      local path = vim.fn.input({
	--        prompt = "Path to executable: ",
	--        default = vim.fn.getcwd() .. "/",
	--        completion = "file",
	--      })
	--      return (path and path ~= "") and path or dap.ABORT
	--    end,
	--    args = function()
	--      local args_str = vim.fn.input({
	--        prompt = "Arguments: ",
	--      })
	--      return vim.split(args_str, " +")
	--    end,
	--  },
	--  {
	--    name = "Attach to process (GDB)",
	--    type = "gdb",
	--    request = "attach",
	--    processId = require("dap.utils").pick_process,
	--  },
	-- }
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

	-- Formatting and linting setup
	require("lint").linters_by_ft = {
		json = { "jsonlint" },
		jsonc = { "jsonlint" },
		yaml = { "yamllint" },
		java = { "checkstyle" },
		go = { "golangcilint" },
		-- lua = { "luacheck" },
		-- python = { "pylint" },
		c = { "clangtidy" },
		javascript = { "eslint" },
		typescript = { "eslint" },
		svelte = { "eslint" },
		sh = { "shellcheck" },
		groovy = { "npm-groovy-lint" },
	}
	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "black" },
			svelte = { "prettier" },
			java = { "google-java-format" },
			go = { "gofmt" },
			tex = { "latexindent" },
			xml = { "xmllint" },
			yaml = { "yamlfmt" },
			json = { "jq", "prettier" },
			jsonc = { "prettier" },
			css = { "prettier" },
			html = { "prettier" },
			c = { "clang_format" },
			sh = { "shfmt" },
			rust = { "rustfmt" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			groovy = { "npm-groovy-lint" },
		},
		lsp_fallback = true,
	})
	vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

	-- Ai setup
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

	-- Commands configuration
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

	-- Helper functions
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
	Global.miniPickVisits = function(cwd, desc)
		local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
		MiniExtra.pickers.visit_paths({ cwd = cwd, filter = "core", sort = sort_latest }, { source = { name = desc } })
	end
	Global.diagnosticVirtualTextToggle = function()
		if Global.virtual_text then
			Global.virtual_text = false
			vim.diagnostic.config({
				virtual_text = false,
			})
		else
			Global.virtual_text = true
			vim.diagnostic.config({
				virtual_text = true,
			})
		end
	end

	-- Keymaps
	imap("<C-x><C-f>", require("fzf-lua").complete_path, "Fuzzy complete path")
	nmap("<C-Space>", toggleTerminal, "Toggle terminal")
	nmap("<C-x><C-f>", require("fzf-lua").complete_path, "Fuzzy complete path")
	nmap("<F2>", MiniNotify.clear, "Clear all notifications")
	nmap("<F3>", "<cmd>Inspect<cr>", "Echo syntax group")
	nmap("<Space><Space><Space>", toggleSpaces, "Expand tabs")
	nmap("<Tab><Tab><Tab>", toggleTabs, "Contract tabs")
	nmap("<leader>am", require("gen").select_model, "Select model")
	nmap("<leader>ap", "<cmd>Gen<CR>", "Prompt Model")
	nmap("<leader>bD", "<cmd>lua MiniBufremove.delete(0, true)<CR>", "Delete!")
	nmap("<leader>bW", "<cmd>lua MiniBufremove.wipeout(0, true)<CR>", "Wipeout!")
	nmap("<leader>ba", "<cmd>b#<CR>", "Alternate")
	nmap("<leader>bd", "<cmd>lua MiniBufremove.delete()<CR>", "Delete")
	nmap("<leader>bu", "<cmd>UndotreeToggle<CR>", "Undotree")
	nmap("<leader>bw", "<cmd>lua MiniBufremove.wipeout()<CR>", "Wipeout")
	nmap("<leader>dC", "<cmd>lua require('dap').clear_breakpoints()<cr>", "Clear breakpoints")
	nmap("<leader>db", "<cmd>lua require('dap').list_breakpoints()<cr>", "List breakpoints")
	nmap("<leader>dc", "<cmd>lua require('dap').continue()<cr>", "Continue")
	nmap("<leader>df", ":lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').frames)<cr>", "Frames")
	nmap("<leader>dh", "<cmd>lua require('dap.ui.widgets').hover()<cr>", "Hover value")
	nmap("<leader>dl", "<cmd>lua require('dap').run_last()<cr>", "Run Last")
	nmap("<leader>dlp", "<cmd>lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log: '))<cr>", "Set log point")
	nmap("<leader>dp", "<cmd>lua require('dap.ui.widgets').preview()<cr>", "Preview")
	nmap("<leader>dr", "<cmd>lua require('dap').repl.open()<cr>", "Open Repl")
	nmap("<leader>ds", ":lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets'.scopes)<cr>", "Scopes")
	nmap("<leader>dsi", "<cmd>lua require('dap').step_into()<cr>", "Step into")
	nmap("<leader>dso", "<cmd>lua require('dap').step_out()<cr>", "Step out")
	nmap("<leader>dso", "<cmd>lua require('dap').step_over()<cr>", "Step over")
	nmap("<leader>dt", "<cmd>lua require('dap').toggle_breakpoint()<cr>", "Toggle breakpoint")
	nmap("<leader>due", "<cmd>lua require('dapui').eval()<cr>", "Toggle dap ui eval")
	nmap("<leader>duf", "<cmd>lua require('dapui').float_element()<cr>", "Toggle dap ui float")
	nmap("<leader>dut", "<cmd>lua require('dapui').toggle()<cr>", "Toggle dap ui")
	nmap("<leader>eT", "<cmd>lua if not MiniFiles.close() then MiniFiles.open() end<cr>", "Toggle file explorer")
	nmap("<leader>ef", "<cmd>NvimTreeFindFile<cr>", "Goto file in tree")
	nmap("<leader>et", "<cmd>NvimTreeToggle<cr>", "Toggle file tree")
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
	nmap("<leader>fr", "<cmd>lua require('spectre').toggle()<cr>", "Search and replace")
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
	nmap("<leader>ldd", "<cmd>lua require('osv').launch({ port = 8086 })<cr>", "Lua debug launch")
	nmap("<leader>ldh", "<cmd>lua vim.diagnostic.open_float()<cr>", "Hover diagnostics")
	nmap("<leader>ldn", "<cmd>lua vim.diagnostic.goto_next()<cr>", "Goto next diagnostic")
	nmap("<leader>ldp", "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Goto prev diagnostic")
	nmap("<leader>ldr", "<cmd>lua require('osv').run_this()<cr>", "Lua debug")
	nmap("<leader>ldt", "<cmd>lua Global.diagnosticVirtualTextToggle()<cr>", "Virtual text toggle")
	nmap("<leader>lf", "<cmd>Format<cr>", "Format code")
	nmap("<leader>lgD", "<cmd>lua vim.lsp.buf.declaration()<cr>", "Goto declaration")
	nmap("<leader>lgb", "<C-t>", "Previous tag")
	nmap("<leader>lgd", "<cmd>lua vim.lsp.buf.definition()<cr>", "Goto definition")
	nmap("<leader>lgi", "<cmd>lua vim.lsp.buf.implementation()<cr>", "Goto implementation")
	nmap("<leader>lgr", "<cmd>lua vim.lsp.buf.references()<cr>", "Goto references")
	nmap("<leader>lgs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Signature help")
	nmap("<leader>lgtd", "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Goto type definition")
	nmap("<leader>lh", "<cmd>lua vim.lsp.buf.hover()<cr>", "Hover symbol")
	nmap("<leader>lit", ":lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<cr>", "Inlay hints toggle")
	nmap("<leader>ljo", "<cmd>lua require('jdtls').organize_imports()<cr>", "Organize imports")
	nmap("<leader>ljv", "<cmd>lua require('jdtls').extract_variable()<cr>", "Extract variable")
	nmap("<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename")
	nmap("<leader>rj", "<cmd>lua require('kulala').jump_next()<CR>", "Next request")
	nmap("<leader>rk", "<cmd>lua require('kulala').jump_prev()<CR>", "Previous request")
	nmap("<leader>rr", "<cmd>lua require('kulala').run()<CR>", "Run request")
	nmap("<leader>tgm", "<cmd>lua require('dap-go').debug_test()<cr>", "Test method")
	nmap("<leader>tjc", "<cmd>lua require('jdtls').test_class()<cr>", "Test class")
	nmap("<leader>tjm", "<cmd>lua require('jdtls').test_nearest_method()<cr>", "Test method")
	nmap("<leader>tpc", "<cmd>lua require('dap-python').test_class()<cr>", "Test class")
	nmap("<leader>tpm", "<cmd>lua require('dap-python').test_method()<cr>", "Test method")
	nmap("<leader>tps", "<cmd>lua require('dap-python').debug_selection()<cr>", "Debug selection")
	nmap("<leader>vF", "<cmd>lua Global.miniPickVisits(nil, 'Core (cwd)')<cr>", "Core visits (cwd)")
	nmap("<leader>vR", "<cmd>lua MiniVisits.remove_label()<cr>", "Remove label")
	nmap("<leader>vV", "<cmd>lua MiniVisits.add_label()<cr>", "Add label")
	nmap("<leader>vf", "<cmd>lua Global.miniPickVisits('', 'Core (all)')<cr>", "Core visits (all)")
	nmap("<leader>vr", "<cmd>lua MiniVisits.remove_label('core')<cr>", "Remove core label")
	nmap("<leader>vv", "<cmd>lua MiniVisits.add_label('core')<cr>", "Add core label")
	nmap("<leader>xl", "<cmd>Trouble loclist toggle<cr>", "Toggle loclist")
	nmap("<leader>xq", "<cmd>Trouble qflist toggle<cr>", "Toggle quickfix")
	nmap("<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "Toggle LSP Defs/refs")
	nmap("<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", "Toggle symbols")
	nmap("<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", "Toggle diagnostics")
	nmap("<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Toggle buffer diagnostics")
	nmap("gl", "<cmd>lua MiniGit.show_at_cursor()<cr>", "Git line history")
	smap("<leader>ap", ":Gen<cr>", "Prompt Model")
	tmap("<Esc>", "<C-\\><C-n>", "Escape terminal mode")
	vmap("<C-c>", '"+y', "Copy to clipboard")
	vmap("<C-c><C-c>", '"+x', "Cut to clipboard")
	vmap("<C-x><C-f>", require("fzf-lua").complete_path, "Fuzzy complete path")
	vmap("<leader>dh", "<cmd>lua require('dap.ui.widgets').hover()<cr>", "Hover value")
	vmap("<leader>dp", "<cmd>lua require('dap.ui.widgets').preview()<cr>", "Preview")
	vmap("<leader>due", "<cmd>lua require('dapui').eval()<cr>", "Toggle dap ui eval")
	xmap("<leader>ap", ":Gen<cr>", "Prompt Model")
	xmap("<leader>lf", "<cmd>Format<cr>", "Format code")

	-- Autocommand configuration
	vim.api.nvim_create_autocmd("BufRead", {
		callback = function(ev)
			if vim.bo[ev.buf].buftype == "quickfix" then
				vim.wo.winbar = ""
				vim.schedule(function()
					vim.cmd("cclose")
					vim.cmd("Trouble qflist open")
				end)
			elseif vim.bo[ev.buf].buftype == "loclist" then
				vim.wo.winbar = ""
				vim.schedule(function()
					vim.cmd("lclose")
					vim.cmd("Trouble loclist open")
				end)
			end
		end,
	})
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
			elseif vim.bo.filetype == "java" then
				require("jdtls").start_or_attach(jdtlsConfig())
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
			vim.wo.winbar = "  %{%v:lua.Global.symbols.get()%}"
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
		pattern = { "\\[dap-repl-*\\]", "DAP *", "NvimTree_*" },
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
	vim.api.nvim_create_autocmd("VimEnter", {
		pattern = "*",
		callback = function()
			local git_root = vim.fn.system("git rev-parse --show-toplevel 2> /dev/null")
			if git_root == "" then
				vim.cmd("cd .")
			else
				vim.cmd("cd " .. git_root)
			end
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
