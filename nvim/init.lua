-- Paq auto download and configure setup
local function clone_paq()
	local path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
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
		vim.notify("Installing plugins... If prompted, hit Enter to continue.")
	end
	paq(packages)
	paq.install()
	paq.clean()
end

-- Paq plugin setup
bootstrap_paq({
	"savq/paq-nvim",
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	"nvim-treesitter/nvim-treesitter-context",
	"nvim-treesitter/nvim-treesitter-refactor",
	"nvim-lua/plenary.nvim",
	"HiPhish/rainbow-delimiters.nvim",
	"lukas-reineke/indent-blankline.nvim",
	"RRethy/nvim-treesitter-endwise",
	"echasnovski/mini.pairs",
	"echasnovski/mini.indentscope",
	"echasnovski/mini.comment",
	"echasnovski/mini.surround",
	"echasnovski/mini.splitjoin",
	"tpope/vim-endwise",
	"tpope/vim-ragtag",
	"tpope/vim-fugitive",
	"tpope/vim-characterize",
	"tpope/vim-git",
	"tpope/vim-eunuch",
	"tpope/vim-speeddating",
	"nvim-tree/nvim-tree.lua",
	"junegunn/fzf.vim",
	"NvChad/nvim-colorizer.lua",
	"folke/tokyonight.nvim",
	"neovim/nvim-lspconfig",
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"nvim-tree/nvim-web-devicons",
	"nvim-lualine/lualine.nvim",
	"folke/trouble.nvim",
	"mfussenegger/nvim-dap",
	"rcarriga/nvim-dap-ui",
	"theHamsta/nvim-dap-virtual-text",
	"mfussenegger/nvim-lint",
	"stevearc/conform.nvim",
	"stevearc/aerial.nvim",
})

-- Treesitter setup
require("nvim-treesitter.configs").setup({
	modules = {},
	ensure_installed = {
		"awk",
		"bash",
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
		"ini",
		"java",
		"javascript",
		"jq",
		"jsdoc",
		"json",
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
			local max_filesize = 1 * 1024 * 1024
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
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<leader>tis",
			node_incremental = "<leader>tni",
			scope_incremental = "<leader>tsi",
			node_decremental = "<leader>tnd",
		},
	},
	refactor = {
		highlight_definitions = {
			enable = true,
			clear_on_cursor_move = true,
		},
		highlight_current_scope = { enable = false },
		smart_rename = {
			enable = true,
			keymaps = {
				smart_rename = "<leader>tr",
			},
		},
		navigation = {
			enable = true,
			keymaps = {
				goto_definition = "<leader>tgd",
				list_definitions = "<leader>tld",
				list_definitions_toc = "<leader>tldt",
				goto_next_usage = "<leader>tgnu",
				goto_previous_usage = "<leader>tgpu",
			},
		},
	},
	endwise = {
		enable = true,
	},
})

local rainbow_delimiters = require("rainbow-delimiters")
vim.g.rainbow_delimiters = {
	strategy = {
		[""] = rainbow_delimiters.strategy["global"],
		vim = rainbow_delimiters.strategy["local"],
	},
	query = {
		[""] = "rainbow-delimiters",
		lua = "rainbow-blocks",
	},
	highlight = {
		-- "RainbowDelimiterRed",
		-- "RainbowDelimiterYellow",
		-- "RainbowDelimiterBlue",
		"RainbowDelimiterOrange",
		-- "RainbowDelimiterGreen",
		-- "RainbowDelimiterViolet",
		-- "RainbowDelimiterCyan",
	},
}

-- Lsp setup
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local luasnip = require("luasnip")
local cmp = require("cmp")

local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	},
	mapping = cmp.mapping.preset.insert({
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
		["<C-e>"] = cmp.mapping.abort(),
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
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
})

lspconfig.lua_ls.setup({
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					vim.env.VIMRUNTIME,
				},
			},
		},
	},
})
lspconfig.gopls.setup({
	capabilities = capabilities,
})
lspconfig.pyright.setup({
	capabilities = capabilities,
})
lspconfig.rust_analyzer.setup({
	capabilities = capabilities,
})
lspconfig.jdtls.setup({
	capabilities = capabilities,
})
lspconfig.tsserver.setup({
	capabilities = capabilities,
})
lspconfig.svelte.setup({
	capabilities = capabilities,
})

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local opts = { buffer = event.buf }
		vim.keymap.set("n", "<leader>lK", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
		vim.keymap.set("n", "<leader>lgd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
		vim.keymap.set("n", "<leader>lgD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
		vim.keymap.set("n", "<leader>lgi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
		vim.keymap.set("n", "<leader>lgo", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
		vim.keymap.set("n", "<leader>lgr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
		vim.keymap.set("n", "<leader>lgs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
		vim.keymap.set("n", "<leader>l<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
		vim.keymap.set({ "n", "x" }, "<leader>l<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
		vim.keymap.set("n", "<leader>l<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
		vim.keymap.set("n", "<leader>lgl", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
		vim.keymap.set("n", "<leader>l[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
		vim.keymap.set("n", "<leader>l]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)
		vim.keymap.set("n", "<Leader>ldh", function()
			vim.diagnostic.hide()
		end)
		vim.keymap.set("n", "<Leader>lds", function()
			vim.diagnostic.show()
		end)
	end,
})

-- statusline setup
require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "fileformat" },
		lualine_y = { "filetype" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {},
})

-- other plugin setups
require("mini.comment").setup()
require("mini.splitjoin").setup()
require("mini.surround").setup()
require("mini.pairs").setup()
require("mini.indentscope").setup({
	-- symbol = "|"
})
require("ibl").setup()
require("colorizer").setup()
require("nvim-tree").setup()

-- source code outline setup
require("aerial").setup({
	on_attach = function(bufnr)
		vim.keymap.set("n", "<leader>o{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
		vim.keymap.set("n", "<leader>o}", "<cmd>AerialNext<CR>", { buffer = bufnr })
	end,
})

-- colorscheme setup
require("tokyonight").setup({
	style = "moon",
	light_style = "day",
	transparent = true,
	terminal_colors = true,
	styles = {
		comments = { italic = true },
		keywords = { italic = true },
		functions = {},
		variables = {},
		sidebars = "dark",
		floats = "dark",
	},
	sidebars = { "qf", "help" },
	day_brightness = 0.3,
	hide_inactive_statusline = true,
	dim_inactive = true,
	lualine_bold = false,
})

-- linter setup
require("lint").linters_by_ft = {
	java = { "checkstyle" },
	go = { "golangcilint" },
	javascript = { "eslint" },
	lua = { "luacheck" },
	python = { "pylint" },
}

-- formatting setup
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		javascript = { "prettier" },
		java = { "google-java-format" },
		go = { "gofumpt" },
	},
	lsp_fallback = true,
})

-- dap setup
local dap = require("dap")

dap.adapters.go = function(callback, config)
	local stdout = vim.loop.new_pipe(false)
	local handle
	local pid_or_err
	local port = 38697
	local opts = {
		stdio = { nil, stdout },
		args = { "dap", "-l", "127.0.0.1:" .. port },
		detached = true,
	}
	handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
		stdout:close()
		handle:close()
		if code ~= 0 then
			print("dlv exited with code", code)
		end
	end)
	assert(handle, "Error running dlv: " .. tostring(pid_or_err))
	stdout:read_start(function(err, chunk)
		assert(not err, err)
		if chunk then
			vim.schedule(function()
				require("dap.repl").append(chunk)
			end)
		end
	end)
	vim.defer_fn(function()
		callback({ type = "server", host = "127.0.0.1", port = port })
	end, 100)
end

dap.configurations.go = {
	{
		type = "go",
		name = "Debug",
		request = "launch",
		program = "${file}",
	},
	{
		type = "go",
		name = "Debug test",
		request = "launch",
		mode = "test",
		program = "${file}",
	},
	{
		type = "go",
		name = "Debug test (go.mod)",
		request = "launch",
		mode = "test",
		program = "./${relativeFileDirname}",
	},
}

dap.adapters.python = {
	type = "executable",
	command = "/usr/bin/python",
	args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
	{
		type = "python",
		name = "Launch file",
		request = "launch",
		program = "${file}",
		pythonPath = function()
			local cwd = vim.fn.getcwd()
			if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
				return cwd .. "/venv/bin/python"
			elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
				return cwd .. "/.venv/bin/python"
			else
				return "/usr/bin/python"
			end
		end,
	},
}
require("dapui").setup()
require("nvim-dap-virtual-text").setup()

-- options
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.undofile = false
vim.opt.expandtab = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.list = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.listchars = "eol:¬,tab:|-,trail:~,extends:>,precedes:<"
vim.opt.maxmempattern = 2000000
vim.cmd("cd" .. vim.fn.system("git rev-parse --show-toplevel 2> /dev/null"))
vim.cmd([[
	sign define DiagnosticSignError text= linehl= texthl=DiagnosticSignError
	sign define DiagnosticSignWarn text= linehl= texthl=DiagnosticSignWarn
	sign define DiagnosticSignInfo text=󰋼 linehl= texthl=DiagnosticSignInfo
	sign define DiagnosticSignHint text= linehl= texthl=DiagnosticSignHint
	let g:python_recommended_style=0
	filetype on
	filetype plugin on
	filetype indent off
	colorscheme tokyonight-moon
	set showcmd
	set path+=**
	set gp=git\ grep\ -n
	set wildignore=*.exe,*.dll,*.pdb
	set backspace=2
	set conceallevel=2
	set textwidth=0
	set matchpairs+=<:>
	set showmatch
	set nowrap
	set nofoldenable
	set foldmethod=indent
	set noshowmode
	highlight MatchParen guibg=#FFC777 guifg=#000000 gui=NONE
]])

-- keymaps
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>xx", function()
	require("trouble").toggle()
end)
vim.keymap.set("n", "<leader>xw", function()
	require("trouble").toggle("workspace_diagnostics")
end)
vim.keymap.set("n", "<leader>xd", function()
	require("trouble").toggle("document_diagnostics")
end)
vim.keymap.set("n", "<leader>xq", function()
	require("trouble").toggle("quickfix")
end)
vim.keymap.set("n", "<leader>xl", function()
	require("trouble").toggle("loclist")
end)
vim.keymap.set("n", "gR", function()
	require("trouble").toggle("lsp_references")
end)
vim.keymap.set("n", "<leader>et", function()
	require("nvim-tree.api").tree.toggle()
end)
vim.keymap.set("n", "<leader>eo", function()
	require("nvim-tree.api").tree.open()
end)
vim.keymap.set("n", "<leader>eC", function()
	require("nvim-tree.api").tree.collapse_all(true)
end)
vim.keymap.set("n", "<leader>ec", function()
	require("nvim-tree.api").tree.close()
end)
vim.keymap.set("n", "<leader>er", function()
	require("nvim-tree.api").tree.refresh()
end)
vim.keymap.set("n", "<leader>ef", function()
	require("nvim-tree.api").tree.find_file()
end)
vim.keymap.set("n", "<leader>ot", "<cmd>AerialToggle<CR>")
vim.keymap.set("n", "<leader>dt", function()
	require("dapui").toggle()
end)
vim.keymap.set("n", "<leader>drt", function()
	require("dap").repl.toggle()
end)
vim.keymap.set("n", "<leader>dc", function()
	require("dap").continue()
end)
vim.keymap.set("n", "<leader>dso", function()
	require("dap").step_over()
end)
vim.keymap.set("n", "<leader>dsi", function()
	require("dap").step_into()
end)
vim.keymap.set("n", "<leader>dso", function()
	require("dap").step_out()
end)
vim.keymap.set("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end)
vim.keymap.set("n", "<leader>drl", function()
	require("dap").run_last()
end)
vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
	require("dap.ui.widgets").hover()
end)
vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
	require("dap.ui.widgets").preview()
end)
vim.keymap.set("n", "<Leader>df", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.frames)
end)
vim.keymap.set("n", "<Leader>ds", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end)
vim.keymap.set("n", "<Tab><Tab><Tab>", function()
	vim.opt.expandtab = false
	vim.cmd("retab!")
end)
vim.keymap.set("n", "<Space><Space><Space>", function()
	vim.opt.expandtab = true
	vim.cmd("retab")
end)
vim.keymap.set("n", "<leader>pq", "<cmd>pclose<CR>")
vim.keymap.set("n", "<leader>nh", "<cmd>nohl<CR>")
vim.keymap.set("n", "<leader>wt", "<cmd>setl wrap!<CR>")
vim.keymap.set("n", "<C-c>", '"+y"')
vim.keymap.set("n", "<C-v>", '"+p"')
vim.keymap.set("n", "<C-x>", '"+d"')

-- autocommands
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		vim.cmd([[%s/\s\+$//e]])
	end,
})
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		vim.cmd([[%s#\($\n\s*\)\+\%$##e]])
	end,
})
