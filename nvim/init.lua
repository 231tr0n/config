-- Globals declared and used
Global = {}
Global.virtual_text = false

-- Paq auto download and configure setup
local function paq_path()
	return vim.fn.stdpath("data") .. "/site/pack/paqs/start"
end
local function clone_paq()
	local path = paq_path() .. "/paq-nvim"
	local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0
	if not is_installed then
		vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/savq/paq-nvim.git", path })
		return true
	end
end
local function bootstrap_paq(packages)
	local first_install = clone_paq()
	vim.cmd.packadd("paq-nvim")
	local paq = require("paq")
	if first_install then
		vim.notify("Installing plugins")
	end
	paq(packages)
	paq.install()
end

-- Paq plugin setup
bootstrap_paq({
	"savq/paq-nvim",
	-- Vimscript plugins
	"tpope/vim-fugitive",
	{
		"junegunn/fzf",
		build = ":call fzf#install()",
	},
	"honza/vim-snippets",
	"mbbill/undotree",
	"antoinemadec/FixCursorHold.nvim",
	"itchyny/vim-qfedit",
	"mg979/vim-visual-multi",
	-- Lua plugins
	"echasnovski/mini.nvim",
	"nvim-lua/plenary.nvim",
	"luukvbaal/statuscol.nvim",
	"nvim-tree/nvim-web-devicons",
	"nvim-pack/nvim-spectre",
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	"nvim-treesitter/nvim-treesitter-context",
	"neovim/nvim-lspconfig",
	"lukas-reineke/indent-blankline.nvim",
	"windwp/nvim-autopairs",
	"windwp/nvim-ts-autotag",
	"RRethy/nvim-treesitter-endwise",
	-- "prichrd/netrw.nvim",
	"nvim-tree/nvim-tree.lua",
	"rafamadriz/friendly-snippets",
	"L3MON4D3/LuaSnip",
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/cmp-nvim-lsp",
	"saadparwaiz1/cmp_luasnip",
	"petertriho/cmp-git",
	"folke/trouble.nvim",
	"nvim-neotest/nvim-nio",
	"mfussenegger/nvim-dap",
	"rcarriga/nvim-dap-ui",
	"jbyuki/one-small-step-for-vimkind",
	"leoluz/nvim-dap-go",
	{
		"mfussenegger/nvim-dap-python",
		build = function()
			local path = vim.fn.stdpath("data")
			vim.fn.system({
				"bash",
				"-c",
				"cd "
					.. path
					.. " && rm -rf debugpy && python -m venv debugpy && "
					.. path
					.. "/debugpy/bin/python -m pip install debugpy",
			})
			return true
		end,
	},
	"mfussenegger/nvim-jdtls",
	{
		"microsoft/vscode-js-debug",
		build = function()
			local path = paq_path() .. "/vscode-js-debug"
			vim.fn.system({
				"bash",
				"-c",
				"cd " .. path .. " && rm -rf dist out && npm install && npx gulp vsDebugServerBundle && mv dist out",
			})
			return true
		end,
	},
	"mxsdev/nvim-dap-vscode-js",
	"mfussenegger/nvim-lint",
	"stevearc/conform.nvim",
	"stevearc/aerial.nvim",
	"David-Kunz/gen.nvim",
	"danymat/neogen",
	"nvim-neotest/neotest",
	"nvim-neotest/neotest-python",
	"nvim-neotest/neotest-go",
	"nvim-neotest/neotest-jest",
	"marilari88/neotest-vitest",
	"thenbe/neotest-playwright",
	"rouge8/neotest-rust",
	"MarkEmmons/neotest-deno",
	"lawrence-laz/neotest-zig",
	"alfaix/neotest-gtest",
	"rcasia/neotest-bash",
	"ray-x/web-tools.nvim",
	"stevearc/overseer.nvim",
	"ibhagwan/fzf-lua",
})

-- Default settings
-- let g:python_recommended_style=0
vim.fn.sign_define("DapBreakpoint", { text = "󰙧", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint", linehl = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = " "
vim.o.conceallevel = 2
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
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
vim.opt.list = true
vim.opt.matchpairs:append("<:>")
vim.opt.maxmempattern = 20000
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.signcolumn = "auto"
vim.opt.tabstop = 2
vim.opt.undofile = false
vim.opt.wildmenu = true
vim.cmd([[
  set nocompatible
  filetype plugin on
  filetype plugin indent off
  " Netrw config
  " let g:netrw_banner=0
  " let g:netrw_liststyle=3
  " let g:netrw_browse_split=4
  " let g:netrw_altv=1
  " let g:netrw_winsize=40
  " let g:netrw_preview=1
  " au FileType netrw setl signcolumn=no
  " au FileType netrw vertical resize 40
  " function FileBrowserToggle()
  "   if !exists("t:NetrwIsOpen")
  "     let t:NetrwIsOpen=0
  "   endif
  "   if t:NetrwIsOpen
  "     let i = bufnr("$")
  "     while (i >= 1)
  "       if (getbufvar(i, "&filetype") == "netrw")
  "         silent exe "bwipeout " . i
  "       endif
  "       let i-=1
  "     endwhile
  "     let t:NetrwIsOpen=0
  "   else
  "     let t:NetrwIsOpen=1
  "     silent Lexplore
  "   endif
  " endfunction
  " Colorscheme related config
  function SynGroup()
    if !exists("*synstack")
      return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
  endfun
]])

-- Mini plugins initialisation
require("mini.ai").setup()
require("mini.align").setup()
-- require("mini.animate").setup({ scroll = { enable = false } })
require("mini.base16").setup({
	-- solarized dark color palette
	palette = {
		base00 = "#002B36",
		base01 = "#073642",
		base02 = "#586E75",
		base03 = "#657B83",
		base04 = "#839496",
		base05 = "#93A1A1",
		base06 = "#EEE8D5",
		base07 = "#FDF6E3",
		base08 = "#DC322F",
		base09 = "#CB4B16",
		base0A = "#B58900",
		base0B = "#859900",
		base0C = "#2AA198",
		base0D = "#268BD2",
		base0E = "#6C71C4",
		base0F = "#D33682",
	},
	-- one dark color palette
	-- palette = {
	--  base00 = "#282C34",
	--  base01 = "#353B45",
	--  base02 = "#3E4451",
	--  base03 = "#545862",
	--  base04 = "#565C64",
	--  base05 = "#ABB2BF",
	--  base06 = "#B6BDCA",
	--  base07 = "#C8CCD4",
	--  base08 = "#E06C75",
	--  base09 = "#D19A66",
	--  base0A = "#E5C07B",
	--  base0B = "#98C379",
	--  base0C = "#56B6C2",
	--  base0D = "#61AFEF",
	--  base0E = "#C678DD",
	--  base0F = "#BE5046",
	-- },
})
require("mini.basics").setup({
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
			{ mode = "n", keys = "<Leader>c", desc = "+Code outline" },
			{ mode = "n", keys = "<Leader>d", desc = "+Debug" },
			{ mode = "n", keys = "<Leader>e", desc = "+Explorer" },
			{ mode = "n", keys = "<Leader>f", desc = "+Find" },
			{ mode = "n", keys = "<Leader>g", desc = "+Generate" },
			{ mode = "n", keys = "<Leader>l", desc = "+Lsp" },
			{ mode = "n", keys = "<Leader>lj", desc = "+Java" },
			{ mode = "n", keys = "<Leader>r", desc = "+Rest" },
			{ mode = "n", keys = "<Leader>t", desc = "+Test" },
			{ mode = "n", keys = "<Leader>tj", desc = "+Java" },
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
-- 	-- background = "#1c1c1c",
-- 	-- foreground = "#83a598",
-- 	background = "#11262D",
-- 	foreground = "#C0C8CC",
-- 	n_hues = 8,
-- 	accent = "bg",
-- 	saturation = "high",
-- })
-- require("mini.colors").setup()
-- local colors = require("mini.colors")
-- colors
--  .get_colorscheme()
--  :add_transparency({
--    general = true,
--    float = true,
--    statuscolumn = true,
--    statusline = false,
--    tabline = true,
--    winbar = true,
--  })
--  :apply()
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
		reindent_linewise = false,
	},
})
require("mini.notify").setup({
	window = {
		max_width_share = 0.5,
	},
})
require("mini.operators").setup()
-- require("mini.pairs").setup({
--  mappings = {
--    ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^\\]." },
--    [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },
--  },
-- })
require("mini.pick").setup()
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
			local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
			local filename = MiniStatusline.section_filename({ trunc_width = 140 })
			if filename:sub(1, 2) == "%F" or filename:sub(1, 2) == "%f" then
				filename = filename:sub(1, 2) .. " " .. filename:sub(3, -1)
			end
			local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 1000 })
			local location = MiniStatusline.section_location({ trunc_width = 75 })
			-- local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
			return MiniStatusline.combine_groups({
				{ hl = mode_hl, strings = { mode } },
				{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
				"%<",
				{ hl = "MiniStatuslineFilename", strings = { filename } },
				"%=",
				{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
				-- { hl = mode_hl, strings = { search, location } },
				{ hl = mode_hl, strings = { location } },
			})
		end,
		inactive = function()
			local git = MiniStatusline.section_git({ trunc_width = 75 })
			local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
			local filename = MiniStatusline.section_filename({ trunc_width = 140 })
			if filename:sub(1, 2) == "%F" or filename:sub(1, 2) == "%f" then
				filename = filename:sub(1, 2) .. " " .. filename:sub(3, -1)
			end
			local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 1000 })
			return MiniStatusline.combine_groups({
				{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
				"%<",
				{ hl = "MiniStatuslineFilename", strings = { filename } },
				"%=",
				{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
			})
		end,
	},
})
require("mini.surround").setup()
require("mini.tabline").setup()
-- require("mini.test").setup()
require("mini.trailspace").setup()
-- require("mini.visits").setup()
-- defer setup
vim.notify = MiniNotify.make_notify()
vim.ui.select = MiniPick.ui_select

-- Utility libraries
vim.cmd([[
  " Highlight groups
  highlight! link WinBar LineNr
  highlight! link WinBarNC LineNr
  highlight! link IblScope MiniIndentscopeSymbol
  " highlight! link CursorLineFold CursorLineNr
  au ColorScheme * highlight! link WinBar LineNr
  au ColorScheme * highlight! link WinBarNC LineNr
  au ColorScheme * highlight! link IblScope MiniIndentscopeSymbol
  " au ColorScheme * highlight! link CursorLineFold CursorLineNr
]])
local cmp = require("cmp")
local luasnip = require("luasnip")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
-- defer setup
require("nvim-web-devicons").setup()
require("statuscol").setup({
	ft_ignore = { "netrw", "NvimTree", "aerial" },
	bt_ignore = { "netrw", "NvimTree", "aerial" },
	relculright = false,
	segments = {
		{ text = { " ", "%s" }, click = "v:lua.ScSa" },
		{ text = { require("statuscol.builtin").lnumfunc }, click = "v:lua.ScLa", hl = "" },
		{ text = { require("statuscol.builtin").foldfunc, " " }, click = "v:lua.ScFa", hl = "" },
		-- { text = { require("statuscol.builtin").foldfunc, "▕" }, click = "v:lua.ScFa" },
		-- { text = { " " }, hl = "Comment" },
	},
})
require("trouble").setup()
require("nvim-autopairs").setup()
cmp.setup({
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
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
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
})
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()
-- require("netrw").setup()
require("nvim-tree").setup()
require("spectre").setup()
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
require("fzf-lua").setup({
	"max-perf",
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

-- Treesitter setup
require("nvim-treesitter.configs").setup({
	modules = {},
	indent = true,
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
		additional_vim_regex_highlighting = true,
	},
	endwise = {
		enable = true,
	},
	autotag = {
		enable = true,
	},
})
require("treesitter-context").setup()
vim.cmd([[
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()
  au BufWinEnter *.* setlocal winbar=%{nvim_treesitter#statusline()}
  au TermOpen * setlocal winbar=""
]])

-- Lsp setup
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
			runtime = {
				version = "LuaJIT",
			},
			completion = {
				callSnippet = "Replace",
			},
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
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
})
-- lspconfig.pyright.setup({
--  capabilities = capabilities,
-- })
lspconfig.basedpyright.setup({
	capabilities = capabilities,
})
lspconfig.rust_analyzer.setup({
	capabilities = capabilities,
})
lspconfig.tsserver.setup({
	capabilities = capabilities,
})
lspconfig.svelte.setup({
	capabilities = capabilities,
})
lspconfig.clangd.setup({
	capabilities = capabilities,
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
require("aerial").setup({
	backends = { "treesitter", "lsp" },
	show_guides = true,
	layout = {
		filter_kind = false,
	},
})
require("neogen").setup({ snippet_engine = "luasnip" })

-- Dap setup
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
require("dap-go").setup({
	dap_configurations = {
		{
			type = "go",
			name = "Attach remote",
			mode = "remote",
			request = "attach",
		},
	},
})
require("dap-python").setup(vim.fn.stdpath("data") .. "/debugpy/bin/python")
require("dap-vscode-js").setup({
	debugger_path = paq_path() .. "/vscode-js-debug",
	adapters = { "pwa-node" },
})
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
		return "/usr/bin/lldb-vscode-14"
	end
	return "/usr/bin/lldb-vscode"
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
}
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		svelte = { "prettier" },
		java = { "google-java-format" },
		go = { "gofumpt" },
		tex = { "latexindent" },
		xml = { "xmllint" },
		yaml = { "yamlfix" },
		json = { "jq", "prettier" },
		jsonc = { "prettier" },
		css = { "prettier" },
		html = { "prettier" },
		c = { "clang_format" },
		sh = { "shfmt" },
		rust = { "rustfmt" },
		javascript = { "prettier" },
		typescript = { "prettier" },
	},
	lsp_fallback = true,
})

-- Testing setup
require("neotest").setup({
	adapters = {
		require("neotest-python"),
		require("neotest-playwright"),
		require("neotest-go"),
		require("neotest-jest"),
		require("neotest-vitest"),
		require("neotest-rust"),
		require("neotest-deno"),
		require("neotest-zig"),
		require("neotest-gtest"),
		require("neotest-bash"),
	},
})

-- Git setup
require("cmp").setup.filetype("gitcommit", {
	sources = cmp.config.sources({
		{ name = "git" },
	}, {
		{ name = "buffer" },
	}),
})

-- Api setup
require("web-tools").setup({
	keymaps = {
		rename = nil,
		repeat_rename = ".",
	},
	hurl = {
		show_headers = true,
		floating = true,
		json5 = true,
		formatters = {
			json = { "jq" },
			html = { "prettier", "--parser", "html" },
		},
	},
})

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

-- Task runner setup
require("overseer").setup({
	templates = { "builtin" },
})

-- Keymap configuration
local te_buf = nil
local te_win_id = nil
-- defer setup
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
local function openTerminal()
	if vim.fn.bufexists(te_buf) ~= 1 then
		vim.api.nvim_command("au TermOpen * setlocal nonumber norelativenumber signcolumn=no")
		vim.api.nvim_command("sp | winc J | res 10 | te")
		te_win_id = vim.fn.win_getid()
		te_buf = vim.fn.bufnr("%")
	elseif vim.fn.win_gotoid(te_win_id) ~= 1 then
		vim.api.nvim_command("sb " .. te_buf .. "| winc J | res 10")
		te_win_id = vim.fn.win_getid()
	end
	vim.api.nvim_command("startinsert")
end
local function hideTerminal()
	if vim.fn.win_gotoid(te_win_id) == 1 then
		vim.api.nvim_command("hide")
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
nmap("<C-Space>", toggleTerminal, "Toggle terminal")
nmap("<F2>", MiniNotify.clear, "Clear all notifications")
nmap("<F3>", "<cmd>call SynGroup()<cr>", "Echo highlight group")
nmap("<Space><Space><Space>", toggleSpaces, "Expand tabs")
nmap("<Tab><Tab><Tab>", toggleTabs, "Contract tabs")
nmap("<leader>am", require("gen").select_model, "Select model")
nmap("<leader>ap", ":Gen<cr>", "Prompt Model")
nmap("<leader>bD", "<cmd>lua MiniBufremove.delete(0, true)<CR>", "Delete!")
nmap("<leader>bW", "<cmd>lua MiniBufremove.wipeout(0, true)<CR>", "Wipeout!")
nmap("<leader>ba", "<cmd>b#<CR>", "Alternate")
nmap("<leader>bd", "<cmd>lua MiniBufremove.delete()<CR>", "Delete")
nmap("<leader>bu", "<cmd>UndotreeToggle<CR>", "Undotree")
nmap("<leader>bw", "<cmd>lua MiniBufremove.wipeout()<CR>", "Wipeout")
nmap("<leader>cf", "<cmd>call aerial#fzf()<cr>", "Code outline fzf")
nmap("<leader>cn", "<cmd>AerialNext<cr>", "Code outline next")
nmap("<leader>co", "<cmd>AerialNavToggle<cr>", "Code navigation toggle")
nmap("<leader>cp", "<cmd>AerialPrev<cr>", "Code outline prev")
nmap("<leader>ct", "<cmd>AerialToggle<cr>", "Code outline toggle")
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
nmap("<leader>et", "<cmd>NvimTreeToggle<cr>", "Toggle file tree")
nmap("<leader>ef", "<cmd>NvimTreeFindFile<cr>", "Goto file in tree")
-- nmap("<leader>et", "<cmd>call FileBrowserToggle()<cr>", "Toggle tree")
nmap("<leader>fL", "<cmd>FzfLua lines<cr>", "Search lines")
nmap("<leader>fS", "<cmd>FzfLua live_grep_native<cr>", "Search content live")
nmap("<leader>fT", "<cmd>FzfLua tags<cr>", "Search tags")
nmap("<leader>fX", "<cmd>FzfLua diagnostics_workspace<cr>", "Search workspace diagnostics")
nmap("<leader>fb", "<cmd>FzfLua buffers<cr>", "Search buffers")
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
nmap("<leader>ljo", "<cmd>lua require('jdtls').organize_imports()<cr>", "Organize imports")
nmap("<leader>ljv", "<cmd>lua require('jdtls').extract_variable()<cr>", "Extract variable")
nmap("<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename")
nmap("<leader>lt", "<cmd>lua require('trouble').toggle('lsp_references')<cr>", "Toggle lsp references")
nmap("<leader>rc", "<cmd>CurlToHurl<cr>", "Convert curl to hurl")
nmap("<leader>rr", "<cmd>HurlRun<cr>", "Run request")
nmap("<leader>ta", "<cmd>lua require('neotest').run.attach()<cr>", "Attach to test")
nmap("<leader>td", "<cmd>lua require('neotest').run.run({ strategy = 'dap' })<cr>", "Run test with dap")
nmap("<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", "Run file tests")
nmap("<leader>tjc", "<cmd>lua require('jdtls').test_class()<cr>", "Test class")
nmap("<leader>tjm", "<cmd>lua require('jdtls').test_nearest_method()<cr>", "Test method")
nmap("<leader>ts", "<cmd>lua require('neotest').run.stop()<cr>", "Stop test")
nmap("<leader>tt", "<cmd>lua require('neotest').run.run()<cr>", "Run nearest test")
nmap("<leader>xl", "<cmd>lua require('trouble').toggle('loclist')<cr>", "Toggle loclist")
nmap("<leader>xq", "<cmd>lua require('trouble').toggle('quickfix')<cr>", "Toggle quickfix list")
nmap("<leader>xt", "<cmd>lua require('trouble').toggle()<cr>", "Toggle trouble")
nmap("<leader>xw", ":lua require('trouble').toggle('workspace_diagnostics')<cr>", "Toggle workspace diagnostics")
nmap("<leader>xx", "<cmd>lua require('trouble').toggle('document_diagnostics')<cr>", "Toggle document diagnostics")
smap("<leader>ap", ":Gen<cr>", "Prompt Model")
tmap("<Esc>", "<C-\\><C-n>", "Escape terminal mode")
vmap("<C-c>", '"+y', "Copy to clipboard")
vmap("<C-c><C-c>", '"+x', "Cut to clipboard")
vmap("<leader>dh", "<cmd>lua require('dap.ui.widgets').hover()<cr>", "Hover value")
vmap("<leader>dp", "<cmd>lua require('dap.ui.widgets').preview()<cr>", "Preview")
vmap("<leader>due", "<cmd>lua require('dapui').eval()<cr>", "Toggle dap ui eval")
xmap("<leader>ap", ":Gen<cr>", "Prompt Model")
xmap("<leader>lf", "<cmd>Format<cr>", "Format code")

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

-- Autocommand configuration
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "quickfix",
	callback = function()
		local ok, trouble = pcall(require, "trouble")
		if ok then
			vim.defer_fn(function()
				vim.cmd("cclose")
				trouble.open("quickfix")
			end, 0)
		end
	end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "loclist",
	callback = function()
		local ok, trouble = pcall(require, "trouble")
		if ok then
			vim.defer_fn(function()
				vim.cmd("lclose")
				trouble.open("loclist")
			end, 0)
		end
	end,
})
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		vim.cmd("norm zx")
		vim.cmd("norm zR")
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "java" },
	callback = function()
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
		require("jdtls").start_or_attach(config)
	end,
})
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function()
		vim.diagnostic.config({
			virtual_text = true,
			underline = false,
		})
		if vim.bo.filetype == "java" then
			require("jdtls.dap").setup_dap_main_class_configs()
		end
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "svelte,jsx,html,xml,xsl,javascriptreact",
	callback = function()
		vim.bo.omnifunc = "htmlcomplete#CompleteTags"
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
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		MiniTrailspace.trim()
		MiniTrailspace.trim_last_lines()
	end,
})

-- Custom functionality
-- Setting border for lsp hover
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
