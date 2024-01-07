-- Custom commands and functions
local te_buf = nil
local te_win_id = nil

local v = vim
local fun = v.fn
local cmd = v.api.nvim_command
local gotoid = fun.win_gotoid
local getid = fun.win_getid

local function openTerminal()
	if fun.bufexists(te_buf) ~= 1 then
		cmd("au TermOpen * setlocal nonumber norelativenumber signcolumn=no")
		cmd("sp | winc J | res 10 | te")
		te_win_id = getid()
		te_buf = fun.bufnr("%")
	elseif gotoid(te_win_id) ~= 1 then
		cmd("sb " .. te_buf .. "| winc J | res 10")
		te_win_id = getid()
	end
	cmd("startinsert")
end

local function hideTerminal()
	if gotoid(te_win_id) == 1 then
		cmd("hide")
	end
end

local function ToggleTerminal()
	if gotoid(te_win_id) == 1 then
		hideTerminal()
	else
		openTerminal()
	end
end

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
end

-- Paq plugin setup
bootstrap_paq({
	"savq/paq-nvim",
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	"nvim-treesitter/nvim-treesitter-context",
	"nvim-treesitter/nvim-treesitter-refactor",
	"nvim-lua/plenary.nvim",
	"MunifTanjim/nui.nvim",
	"HiPhish/rainbow-delimiters.nvim",
	"lukas-reineke/indent-blankline.nvim",
	"windwp/nvim-autopairs",
	"windwp/nvim-ts-autotag",
	"RRethy/nvim-treesitter-endwise",
	"echasnovski/mini.indentscope",
	"echasnovski/mini.comment",
	"echasnovski/mini.surround",
	"echasnovski/mini.splitjoin",
	"echasnovski/mini.jump2d",
	"folke/which-key.nvim",
	"tpope/vim-endwise",
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
	"leoluz/nvim-dap-go",
	"mfussenegger/nvim-dap-python",
	"mfussenegger/nvim-jdtls",
	"mxsdev/nvim-dap-vscode-js",
	"mfussenegger/nvim-lint",
	"stevearc/conform.nvim",
	"stevearc/aerial.nvim",
	"nomnivore/ollama.nvim",
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
				goto_next_usage = "<leader>tgn",
				goto_previous_usage = "<leader>tgp",
			},
		},
	},
	endwise = {
		enable = true,
	},
	autotag = {
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
		["<C-x><C-p>"] = cmp.mapping.complete(),
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
lspconfig.html.setup({
	capabilities = capabilities,
})
lspconfig.cssls.setup({
	capabilities = capabilities,
})
lspconfig.bashls.setup({
	capabilities = capabilities,
})
lspconfig.eslint.setup({
	capabilities = capabilities,
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
lspconfig.tsserver.setup({
	capabilities = capabilities,
})
lspconfig.svelte.setup({
	capabilities = capabilities,
})
lspconfig.clangd.setup({
	capabilities = capabilities,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "java" },
	callback = function()
		local config = {
			cmd = { "/usr/bin/jdtls" },
			root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]),
		}
		config["init_options"] = {
			bundles = {
				vim.fn.glob("/usr/share/java-debug/com.microsoft.java.debug.plugin.jar", 1),
			},
		}
		require("jdtls").start_or_attach(config)
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local opts = { buffer = event.buf }
		vim.keymap.set("n", "<leader>lh", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
		vim.keymap.set("n", "<leader>lgd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
		vim.keymap.set("n", "<leader>lgD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
		vim.keymap.set("n", "<leader>lgi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
		vim.keymap.set("n", "<leader>lgtd", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
		vim.keymap.set("n", "<leader>lgr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
		vim.keymap.set("n", "<leader>lgs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
		vim.keymap.set("n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
		vim.keymap.set({ "n", "x" }, "<leader>lf", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
		vim.keymap.set("n", "<leader>lc", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
		vim.keymap.set("n", "<leader>lo", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
		vim.keymap.set("n", "<leader>lgp", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
		vim.keymap.set("n", "<leader>lgn", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)
		vim.keymap.set("n", "<Leader>ldh", function()
			vim.diagnostic.hide()
		end)
		vim.keymap.set("n", "<Leader>lds", function()
			vim.diagnostic.show()
		end)
		if vim.bo.filetype == "java" then
			require("jdtls.dap").setup_dap_main_class_configs()
		end
		if vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = event.buf,
				command = "EslintFixAll",
			})
		end
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
require("nvim-autopairs").setup()
require("nvim-ts-autotag").setup()
require("mini.indentscope").setup({
	symbol = "|",
})
require("ibl").setup()
require("colorizer").setup()
require("nvim-tree").setup()
require("which-key").setup()
require("mini.jump2d").setup()

-- source code outline setup
require("aerial").setup({
	on_attach = function(bufnr)
		vim.keymap.set("n", "<leader>cp", "<cmd>AerialPrev<CR>", { buffer = bufnr })
		vim.keymap.set("n", "<leader>cn", "<cmd>AerialNext<CR>", { buffer = bufnr })
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
	lua = { "luacheck" },
	python = { "pylint" },
	c = { "clangtidy" },
}

-- formatting setup
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		svelte = { "prettier" },
		java = { "google-java-format" },
		go = { "gofumpt" },
		xml = { "xmlformat" },
		json = { "jq" },
		css = { "prettier" },
		html = { "prettier" },
		c = { "clang_format" },
	},
	lsp_fallback = true,
})
vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })

-- dap setup
local dap = require("dap")
local dapui = require("dapui")
require("dapui").setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end
require("nvim-dap-virtual-text").setup()

require("dap-go").setup()
require("dap-python").setup("/usr/bin/python")
require("dap-vscode-js").setup({
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

-- ai setup
require("ollama").setup({
	model = "codellama",
	url = "http://127.0.0.1:11434",
	-- serve = {
	-- 	on_start = false,
	-- 	command = "ollama",
	-- 	args = { "serve" },
	-- 	stop_command = "pkill",
	-- 	stop_args = { "-SIGTERM", "ollama" },
	-- },
	prompts = {
		Sample_Prompt = {
			prompt = "This is a sample prompt that receives $input and $sel(ection), among others.",
			input_label = "> ",
			model = "codellama",
			action = "display",
		},
	},
})

-- options
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.undofile = false
vim.opt.expandtab = true
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
vim.opt.maxmempattern = 20000
vim.fn.sign_define("DapBreakpoint", { text = "󰙧", texthl = "Breakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "DebugPosition", linehl = "", numhl = "" })
vim.fn.sign_define(
	"DiagnosticSignError",
	{ text = "", texthl = "LspDiagnosticErr", linehl = "", numhl = "LspDiagnosticErr" }
)
vim.fn.sign_define(
	"DiagnosticSignWarn",
	{ text = "", texthl = "LspDiagnosticWarn", linehl = "", numhl = "LspDiagnosticWarn" }
)
vim.fn.sign_define(
	"DiagnosticSignInfo",
	{ text = "󰋼", texthl = "LspDiagnosticInfo", linehl = "", numhl = "LspDiagnosticInfo" }
)
vim.fn.sign_define(
	"DiagnosticSignHint",
	{ text = "", texthl = "LspDiagnosticHint", linehl = "", numhl = "LspDiagnosticHint" }
)
vim.cmd("cd" .. vim.fn.system("git rev-parse --show-toplevel 2> /dev/null"))
vim.cmd([[
	let g:python_recommended_style=0
	colorscheme tokyonight-night
	set showcmd
	set ignorecase
	set smartcase
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
	highlight Breakpoint guibg=NONE guifg=#FCA7EA gui=NONE
	highlight DebugPosition guibg=NONE guifg=#C099FF gui=NONE
	highlight LspDiagnosticErr guibg=NONE guifg=#FF757F gui=NONE
	highlight LspDiagnosticHint guibg=NONE guifg=#4FD6BE gui=NONE
	highlight LspDiagnosticWarn guibg=NONE guifg=#B2D380 gui=NONE
	highlight LspDiagnosticInfo guibg=NONE guifg=#82AAFF gui=NONE
	vnoremap <C-c> "+y
	vnoremap <C-x> "+d
	nnoremap <Space>lgb <C-t>
	let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9 } }
	let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git --exclude node_modules'
	command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, fzf#vim#with_preview('up', 'ctrl-/'), <bang>0)
	command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --hidden --smart-case -g '!.git/' -g '!node_modules/' -- ".fzf#shellescape(<q-args>), fzf#vim#with_preview('up', 'ctrl-/'), <bang>0)
	command! -bang -nargs=* RG call fzf#vim#grep2("rg --column --line-number --no-heading --color=always --hidden --smart-case -g '!.git/' -g '!node_modules/' -- ", <q-args>, fzf#vim#with_preview('up', 'ctrl-/'), <bang>0)
]])

-- keymaps
vim.g.mapleader = " "
local wk = require("which-key")

wk.register({
	["<leader>"] = {
		x = {
			name = "Trouble",
			x = {
				function()
					require("trouble").toggle()
				end,
				"Toggle Diagnostics",
			},
			w = {
				function()
					require("trouble").toggle("workspace_diagnostics")
				end,
				"Toggle Workspace Diagnostics",
			},
			d = {
				function()
					require("trouble").toggle("document_diagnostics")
				end,
				"Toggle Document Diagnostics",
			},
			q = {
				function()
					require("trouble").toggle("quickfix")
				end,
				"Toggle Quickfix List",
			},
			l = {
				function()
					require("trouble").toggle("loclist")
				end,
				"Toggle Loclist",
			},
			r = {
				function()
					require("trouble").toggle("lsp_references")
				end,
				"Toggle Loclist",
			},
		},
		e = {
			name = "File Explorer",
			t = {
				function()
					require("nvim-tree.api").tree.toggle()
				end,
				"Toggle File Explorer",
			},
			o = {
				function()
					require("nvim-tree.api").tree.open()
				end,
				"Open File Explorer",
			},
			C = {
				function()
					require("nvim-tree.api").tree.collapse_all(true)
				end,
				"Collapse whole tree",
			},
			c = {
				function()
					require("nvim-tree.api").tree.close()
				end,
				"Close File Explorer",
			},
			r = {
				function()
					require("nvim-tree.api").tree.refresh()
				end,
				"Refresh File Explorer",
			},
			f = {
				function()
					require("nvim-tree.api").tree.find_file()
				end,
				"File file in File Explorer",
			},
		},
		a = {
			name = "Ollama",
			p = {
				":<c-u>lua require('ollama').prompt()<cr>",
				"Prompt model",
			},
			g = {
				":<c-u>lua require('ollama').prompt('Generate_Code')<cr>",
				"Generate code from model",
			},
		},
		c = {
			name = "Code Outline",
			t = {
				"<cmd>AerialToggle<CR>",
				"Toggle Code outline",
			},
			n = "Go to next definition in aerial",
			p = "Go to previous definition in aerial",
		},
		d = {
			name = "Debug",
			t = {
				function()
					require("dapui").toggle()
				end,
				"Toggle debug UI",
			},
			rt = {
				function()
					require("dap").repl.toggle()
				end,
				"Toggle debug Repl",
			},
			c = {
				function()
					require("dap").continue()
				end,
				"Debug Continue",
			},
			so = {
				function()
					require("dap").step_over()
				end,
				"Debug Step over",
			},
			si = {
				function()
					require("dap").step_into()
				end,
				"Debug Step into",
			},
			sO = {
				function()
					require("dap").step_out()
				end,
				"Debug Step out",
			},
			b = {
				function()
					require("dap").toggle_breakpoint()
				end,
				"Debug Toggle breakpoint",
			},
			rl = {
				function()
					require("dap").run_last()
				end,
				"Debug Run last",
			},
			h = {
				function()
					require("dap.ui.widgets").hover()
				end,
				"Debug Ui Hover",
			},
			p = {
				function()
					require("dap.ui.widgets").preview()
				end,
				"Debug Ui Preview",
			},
			f = {
				function()
					local widgets = require("dap.ui.widgets")
					widgets.centered_float(widgets.frames)
				end,
				"Debug Ui Frames",
			},
			s = {
				function()
					local widgets = require("dap.ui.widgets")
					widgets.centered_float(widgets.scopes)
				end,
				"Debug Ui Scopes",
			},
		},
		o = {
			name = "Own Keymaps",
			pq = {
				"<cmd>pclose<CR>",
				"Close panels",
			},
			nh = {
				"<cmd>nohl<CR>",
				"Disable search regex highlighting",
			},
			tw = {
				"<cmd>setl wrap!<CR>",
				"Toggle wrap",
			},
		},
		t = {
			name = "Treesitter",
			is = "Init selection",
			ni = "Node incremental selection",
			si = "Scope incremental selection",
			nd = "Node decremental selection",
			r = "Smart rename",
			gd = "Goto definition",
			ld = "List definitions",
			ldt = "List definitions toc",
			gn = "Goto next usage",
			gp = "Goto previous usage",
		},
		l = {
			name = "Lsp",
			h = "Hover",
			gd = "Goto definition",
			gb = "Goto previous definition",
			gD = "Goto declaraction",
			gi = "Goto implementation",
			gtd = "Goto type definition",
			gr = "Goto references",
			gs = "Signature help",
			r = "Rename",
			f = "Format",
			c = "Code action",
			o = "Open float",
			gp = "Goto previous",
			gn = "Goto next",
			dh = "Diagnostics hide",
			ds = "Diagnostics show",
		},
		f = {
			name = "Find",
			f = {
				"<cmd>Files<CR>",
				"Find files",
			},
			g = {
				"<cmd>GFiles<CR>",
				"Find git files",
			},
			G = {
				"<cmd>GFiles?<CR>",
				"Find git status files",
			},
			b = {
				"<cmd>Buffers<CR>",
				"Find buffers",
			},
			s = {
				"<cmd>Rg<CR>",
				"Find content in files",
			},
			S = {
				"<cmd>RG<CR>",
				"Find content in files with rg run everytime",
			},
			l = {
				"<cmd>BLines<CR>",
				"Find content in buffer lines",
			},
			L = {
				"<cmd>Lines<CR>",
				"Find content in all buffer lines",
			},
			t = {
				"<cmd>BTags<CR>",
				"Find content in ctags for current buffer",
			},
			T = {
				"<cmd>Tags<CR>",
				"Find content in ctags",
			},
			m = {
				"<cmd>Marks<CR>",
				"Find marks",
			},
			j = {
				"<cmd>Jumps<CR>",
				"Find jumps",
			},
			w = {
				"<cmd>Windows<CR>",
				"Find windows",
			},
			h = {
				"<cmd>History:<CR>",
				"Find history of commands",
			},
			H = {
				"<cmd>History/<CR>",
				"Find history of search",
			},
			c = {
				"<cmd>Commits<CR>",
				"Find commits",
			},
			C = {
				"<cmd>BCommits<CR>",
				"Find buffer commits",
			},
		},
	},
	["<C-Space>"] = {
		function()
			ToggleTerminal()
		end,
		"Toggle terminal",
	},
	["<C-\\><C-n>"] = "Exit terminal mode",
	["<C-x><C-p>"] = "Complete mapping",
	["<C-u>"] = "Scroll mapping docs up",
	["<C-d>"] = "Scroll mapping docs down",
	["<C-e>"] = "Abort mapping",
	["Tab"] = "Go down completitions",
	["<S-Tab>"] = "Go up completitions",
	["<Tab><Tab><Tab>"] = {
		function()
			vim.opt.expandtab = false
			vim.cmd("retab!")
		end,
		"Convert tabs to spaces",
	},
	["<Space><Space><Space>"] = {
		function()
			vim.opt.expandtab = true
			vim.cmd("retab")
		end,
		"Convert tabs to spaces",
	},
	["<C-c>"] = "Copy to clipboard",
	["<C-x>"] = "Cut to clipboard",
	["<C-S-v>"] = "Paste from clipboard",
})

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
