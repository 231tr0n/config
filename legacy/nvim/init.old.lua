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
	paq.install()
end

-- Paq plugin setup
bootstrap_paq({
	"savq/paq-nvim",
	"LunarVim/bigfile.nvim",
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	"nvim-treesitter/nvim-treesitter-refactor",
	"nvim-lua/plenary.nvim",
	"MunifTanjim/nui.nvim",
	"HiPhish/rainbow-delimiters.nvim",
	"lukas-reineke/indent-blankline.nvim",
	"windwp/nvim-ts-autotag",
	-- tpope/vim-ragtag
	"RRethy/nvim-treesitter-endwise",
	-- tpope/vim-endwise
	"windwp/nvim-autopairs",
	-- "echasnovski/mini.pairs",
	"RRethy/vim-illuminate",
	"echasnovski/mini.indentscope",
	"echasnovski/mini.comment",
	"echasnovski/mini.surround",
	-- "echasnovski/mini.splitjoin",
	"echasnovski/mini.jump2d",
	"echasnovski/mini.move",
	-- "echasnovski/mini.animate",
	"folke/which-key.nvim",
	-- "tpope/vim-repeat",
	"tpope/vim-fugitive",
	-- "tpope/vim-characterize",
	-- "tpope/vim-git",
	-- "tpope/vim-eunuch",
	-- "tpope/vim-speeddating",
	"nvim-tree/nvim-tree.lua",
	{
		"junegunn/fzf",
		build = ":call fzf#install()",
	},
	"junegunn/fzf.vim",
	"NvChad/nvim-colorizer.lua",
	"folke/tokyonight.nvim",
	"neovim/nvim-lspconfig",
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-nvim-lua",
	"hrsh7th/cmp-calc",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/cmp-nvim-lsp",
	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"rafamadriz/friendly-snippets",
	"nvim-tree/nvim-web-devicons",
	"nvim-lualine/lualine.nvim",
	-- "folke/flash.nvim",
	"echasnovski/mini.jump",
	"folke/trouble.nvim",
	"mfussenegger/nvim-dap",
	"jbyuki/one-small-step-for-vimkind",
	"rcarriga/nvim-dap-ui",
	-- "theHamsta/nvim-dap-virtual-text",
	"leoluz/nvim-dap-go",
	{
		"mfussenegger/nvim-dap-python",
		build = function()
			local path = vim.fn.stdpath("data") .. "/site/pack/paqs"
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
			local path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/vscode-js-debug"
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
	"stevearc/dressing.nvim",
	"rcarriga/nvim-notify",
	"folke/noice.nvim",
	"onsails/lspkind.nvim",
	"echasnovski/mini.starter",
	"folke/todo-comments.nvim",
	"s1n7ax/nvim-window-picker",
	"folke/neodev.nvim",
	"danymat/neogen",
	"SmiteshP/nvim-navic",
	"SmiteshP/nvim-navbuddy",
	"stevearc/qf_helper.nvim",
	"kevinhwang91/promise-async",
	"luukvbaal/statuscol.nvim",
	"kevinhwang91/nvim-ufo",
	"nvim-pack/nvim-spectre",
	"otavioschwanck/arrow.nvim",
	"Wansmer/treesj",
	"antoinemadec/FixCursorHold.nvim",
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
})

-- Disable plugins for big files.
vim.opt.maxmempattern = 20000
-- require("bigfile").setup({
--	filesize = 2,
--	pattern = function(bufnr, filesize_mib)
--		local width = 0
--		local content = vim.fn.readblob(vim.api.nvim_buf_get_name(bufnr))
--		for line in content:gmatch("[^\r\n]+") do
--			if #line > width then
--				width = #line
--			end
--		end
--		local filetype = vim.filetype.match({ buf = bufnr })
--		if filetype == "csv" or filetype == "json" or filetype == "xml" then
--			if width > 10000 then
--				return true
--			end
--			if filesize_mib > 2 then
--				return true
--			end
--		end
--	end,
--	features = {
--		"indent_blankline",
--		"illuminate",
--		"lsp",
--		"treesitter",
--		"syntax",
--		"matchparen",
--		"vimopts",
--		"filetype",
--	},
-- })

-- Treesitter setup
require("nvim-treesitter.configs").setup({
	modules = {},
	indent = true,
	ensure_installed = {
		"angular",
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
	refactor = {
		smart_rename = {
			enable = true,
			keymaps = {
				smart_rename = "<leader>r",
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

require("treesj").setup({
	max_join_length = 1000,
})

-- Lsp setup
local lspconfig = require("lspconfig")
local navic = require("nvim-navic")
local navbuddy = require("nvim-navbuddy")
navic.setup({
	lsp = {
		auto_attach = true,
	},
	highlight = true,
	click = true,
})
navbuddy.setup({
	lsp = {
		auto_attach = true,
	},
})
vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
require("illuminate").configure({
	providers = {
		"lsp",
		"treesitter",
		"regex",
	},
	delay = 500,
})
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}
local luasnip = require("luasnip")
local cmp = require("cmp")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local lspkind = require("lspkind")
cmp.setup({
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol",
			maxwidth = 50,
			ellipsis_char = "...",
			show_labelDetails = true,
		}),
	},
	sources = {
		{ name = "buffer" },
		{ name = "path" },
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "nvim_lua" },
		{ name = "calc" },
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
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	completion = { autocomplete = false },
	sources = {
		{ name = "buffer" },
	},
})
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	completion = { autocomplete = false },
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

require("neodev").setup()
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
						--	url = vim.fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
						--	profile = "GoogleStyle",
						-- },
					},
					signatureHelp = { enabled = true },
					contentProvider = { preferred = "fernflower" },
					-- codeGeneration = {
					--	toString = {
					--		template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
					--	},
					--	useBlocks = true,
					-- },
					configuration = {
						-- runtimes = {
						--	{
						--		name = "java-11-openjdk",
						--		path = "/usr/lib/jvm/java-1.11.0-openjdk-amd64/",
						--	},
						--	{
						--		name = "java-17-openjdk",
						--		path = "/usr/lib/jvm/java-1.17.0-openjdk-amd64/",
						--	},
						--	{
						--		name = "java-21-openjdk",
						--		path = "/usr/lib/jvm/java-1.21.0-openjdk-amd64/",
						--	},
						-- },
					},
				},
			},
		}
		local bundles = {
			vim.fn.glob("/usr/share/java-debug/com.microsoft.java.debug.plugin.jar", 1),
		}
		vim.list_extend(bundles, vim.split(vim.fn.glob("/usr/share/java-test/*.jar", 1), "\n"))
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
	callback = function(event)
		local opts = { buffer = event.buf }
		-- local bufnr = event.buf
		-- local client = vim.lsp.get_client_by_id(event.data.client_id)
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
		vim.keymap.set("n", "<leader>ldt", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
		vim.keymap.set("n", "<leader>ldp", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
		vim.keymap.set("n", "<leader>ldn", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)
		vim.keymap.set("n", "<leader>ldh", "<cmd>lua vim.diagnostic.hide()<cr>", opts)
		vim.keymap.set("n", "<leader>lds", "<cmd>lua vim.diagnostic.show()<cr>", opts)
		vim.diagnostic.config({
			virtual_text = true,
		})
		vim.cmd([[
			nnoremap <Space>lgb <C-t>
		]])
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
require("qf_helper").setup()

-- doc generation setup
require("neogen").setup({ snippet_engine = "luasnip" })

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
		lualine_y = { "filetype", "progress" },
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
-- require("mini.splitjoin").setup()
require("mini.surround").setup()
require("nvim-autopairs").setup()
require("nvim-ts-autotag").setup()
-- require("mini.pairs").setup()
require("mini.indentscope").setup({
	symbol = "|",
})
-- require("mini.animate").setup()
require("mini.move").setup({
	mappings = {
		left = "<C-h>",
		right = "<C-l>",
		down = "<C-j>",
		up = "<C-k>",
		line_left = "<C-h>",
		line_right = "<C-l>",
		line_down = "<C-j>",
		line_up = "<C-k>",
	},
	options = {
		reindent_linewise = true,
	},
})
require("mini.starter").setup()
require("ibl").setup({
	scope = {
		show_start = false,
		show_end = false,
	},
})
require("colorizer").setup()
require("nvim-tree").setup()
require("which-key").setup()
require("todo-comments").setup({
	signs = false,
})

-- Navigating setup
require("mini.jump2d").setup()
-- require("flash").setup()
require("mini.jump").setup()

-- Ui setup
require("nvim-web-devicons").setup()
require("dressing").setup({
	select = {
		backend = { "fzf", "nui", "builtin" },
		trim_prompt = false,
	},
})
require("noice").setup({
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
	},
	presets = {
		bottom_search = true,
		command_palette = true,
		long_message_to_split = true,
		inc_rename = false,
		lsp_doc_border = false,
	},
})
require("window-picker").setup({
	hint = "floating-big-letter",
})
require("arrow").setup({
	show_icons = true,
	leader_key = ";",
})

-- source code outline and folds setup
require("aerial").setup({
	backends = { "lsp", "markdown", "man" },
	on_attach = function(bufnr)
		vim.keymap.set("n", "<leader>cp", "<cmd>AerialPrev<CR>", { buffer = bufnr })
		vim.keymap.set("n", "<leader>cn", "<cmd>AerialNext<CR>", { buffer = bufnr })
	end,
	show_guides = true,
	layout = {
		filter_kind = false,
	},
})
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
require("statuscol").setup({
	relculright = true,
	segments = {
		{ text = { require("statuscol.builtin").foldfunc }, click = "v:lua.ScFa" },
		{ text = { "%s" }, click = "v:lua.ScSa" },
		{ text = { require("statuscol.builtin").lnumfunc, " " }, click = "v:lua.ScLa" },
	},
})
vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { noremap = false, silent = true, desc = "Open folds" })
vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { noremap = false, silent = true, desc = "Close folds" })
vim.keymap.set("n", "zk", function()
	local winid = require("ufo").peekFoldedLinesUnderCursor()
	if not winid then
		vim.lsp.buf.hover()
	end
end, { noremap = false, silent = true, desc = "Peek folded lines under cursor" })
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
	callback = function()
		vim.cmd([[
			norm zx
			norm zR
		]])
	end,
})
require("ufo").setup({
	provider_selector = function(bufnr, filetype, buftype)
		return { "lsp", "indent" }
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
	json = { "jsonlint" },
	jsonc = { "jsonlint" },
	yaml = { "yamllint" },
	java = { "checkstyle" },
	go = { "golangcilint" },
	lua = { "luacheck" },
	python = { "pylint" },
	c = { "clangtidy" },
	javascript = { "eslint" },
	typescript = { "eslint" },
	svelte = { "eslint" },
	sh = { "shellcheck" },
}

-- formatting setup
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
vim.keymap.set({ "n", "v" }, "<F2>", function()
	if vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then
		vim.cmd("EslintFixAll")
		return
	end
	vim.cmd("Format")
end)

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
-- require("nvim-dap-virtual-text").setup()
require("dap-go").setup()
require("dap-python").setup(vim.fn.stdpath("data") .. "/site/pack/paqs/debugpy/bin/python")
require("dap-vscode-js").setup({
	debugger_path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/vscode-js-debug",
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
--	local adapter = {
--		type = "server",
--		host = config.host or "127.0.0.1",
--		port = config.port or 8086,
--	}
--	if config.start_neovim then
--		local dap_run = dap.run
--		dap.run = function(c)
--			adapter.port = c.port
--			adapter.host = c.host
--		end
--		require("osv").run_this()
--		dap.run = dap_run
--	end
--	callback(adapter)
-- end
-- dap.configurations.lua = {
--	{
--		type = "nlua",
--		request = "attach",
--		name = "Run this file",
--		start_neovim = {},
--	},
--	{
--		type = "nlua",
--		request = "attach",
--		name = "Attach to running Neovim instance (port = 8086)",
--		port = 8086,
--	},
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
--	{
--		name = "Run executable (GDB)",
--		type = "gdb",
--		request = "launch",
--		program = function()
--			local path = vim.fn.input({
--				prompt = "Path to executable: ",
--				default = vim.fn.getcwd() .. "/",
--				completion = "file",
--			})
--			return (path and path ~= "") and path or dap.ABORT
--		end,
--	},
--	{
--		name = "Run executable with arguments (GDB)",
--		type = "gdb",
--		request = "launch",
--		program = function()
--			local path = vim.fn.input({
--				prompt = "Path to executable: ",
--				default = vim.fn.getcwd() .. "/",
--				completion = "file",
--			})
--			return (path and path ~= "") and path or dap.ABORT
--		end,
--		args = function()
--			local args_str = vim.fn.input({
--				prompt = "Arguments: ",
--			})
--			return vim.split(args_str, " +")
--		end,
--	},
--	{
--		name = "Attach to process (GDB)",
--		type = "gdb",
--		request = "attach",
--		processId = require("dap.utils").pick_process,
--	},
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

-- testing setup
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

-- ai setup
require("gen").setup({
	model = "dolphin-mistral",
	host = "localhost",
	port = "11434",
	display_mode = "float",
	show_prompt = true,
	show_model = true,
	no_auto_close = false,
	init = function(options) end,
	command = function(options)
		return "curl --silent --no-buffer -X POST http://"
			.. options.host
			.. ":"
			.. options.port
			.. "/api/chat -d $body"
	end,
	debug = false,
})
vim.keymap.set({ "n", "v" }, "<F3>", ":Gen<CR>")

-- options
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.undofile = false
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.cursorcolumn = false
vim.opt.list = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.wildmenu = true
vim.o.wildmode = "longest:full,list"
vim.o.listchars = "eol:¬,tab:|-,trail:~,extends:>,precedes:<"
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "" })
vim.fn.sign_define(
	"DapBreakpointCondition",
	{ text = "", texthl = "DapBreakpointCondition", linehl = "DapBreakpointCondition", numhl = "" }
)
vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStopped", linehl = "DapStopped", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "" })
vim.fn.sign_define(
	"DiagnosticSignError",
	{ text = "", texthl = "LspDiagnosticErr", linehl = "", numhl = "LspDiagnosticErr" }
)
vim.fn.sign_define(
	"DiagnosticSignWarn",
	{ text = "", texthl = "LspDiagnosticWarn", linehl = "", numhl = "LspDiagnosticWarn" }
)
vim.fn.sign_define(
	"DiagnosticSignInfo",
	{ text = "", texthl = "LspDiagnosticInfo", linehl = "", numhl = "LspDiagnosticInfo" }
)
vim.fn.sign_define(
	"DiagnosticSignHint",
	{ text = "", texthl = "LspDiagnosticHint", linehl = "", numhl = "LspDiagnosticHint" }
)
vim.cmd("cd " .. vim.fn.system("git rev-parse --show-toplevel 2> /dev/null"))
vim.cmd([[
	tnoremap <Esc> <C-\><C-n>
	tnoremap <C-w>h <C-\><C-n><C-w>h
	tnoremap <C-w>j <C-\><C-n><C-w>j
	tnoremap <C-w>k <C-\><C-n><C-w>k
	tnoremap <C-w>l <C-\><C-n><C-w>l
	filetype indent on
	filetype plugin indent on
	let g:python_recommended_style=0
	colorscheme tokyonight-night
	set showcmd
	set ignorecase
	set smartcase
	set path+=**
	set updatetime=500
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
	highlight MatchParen guibg=#FF9E64 guifg=#000000 gui=NONE
	highlight DapBreakpoint guifg=#7AA2F7 guibg=#3B4261 gui=NONE
	highlight DapBreakpointCondition guifg=#000000 guibg=#AA5162 gui=NONE
	highlight DapStopped guifg=#000000 guibg=#7AA2F7 gui=NONE
	highlight DapLogPoint guifg=#000000 guibg=#76C3F2 gui=NONE
	highlight LspDiagnosticErr guibg=NONE guifg=#FF757F gui=NONE
	highlight LspDiagnosticHint guibg=NONE guifg=#4FD6BE gui=NONE
	highlight LspDiagnosticWarn guibg=NONE guifg=#B2D380 gui=NONE
	highlight LspDiagnosticInfo guibg=NONE guifg=#82AAFF gui=NONE
	highlight NavicIconsFile guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsModule guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsNamespace guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsPackage guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsClass guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsMethod guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsProperty guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsField guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsConstructor guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsEnum guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsInterface guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsFunction guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsVariable guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsConstant guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsString guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsNumber guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsBoolean guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsArray guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsObject guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsKey guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsNull guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsEnumMember guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsStruct guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsEvent guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsOperator guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicIconsTypeParameter guifg=#FF9E64 guibg=#16161E gui=NONE
	highlight NavicSeparator guifg=#4FD6BE guibg=#16161E gui=NONE
	highlight NavicText guibg=#16161E gui=NONE
	vnoremap <C-c> "+y
	vnoremap <C-c><C-c> "+x
	let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9 } }
	let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git --exclude node_modules'
	command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, fzf#vim#with_preview('up', 'ctrl-/'), <bang>0)
	command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --hidden --smart-case -g '!.git/' -g '!node_modules/' -- ".fzf#shellescape(<q-args>), fzf#vim#with_preview('up', 'ctrl-/'), <bang>0)
	command! -bang -nargs=* RG call fzf#vim#grep2("rg --column --line-number --no-heading --color=always --hidden --smart-case -g '!.git/' -g '!node_modules/' -- ", <q-args>, fzf#vim#with_preview('up', 'ctrl-/'), <bang>0)
]])

-- keymaps
vim.g.mapleader = " "
local wk = require("which-key")

Diagnostic_virtual_text = true
wk.register({
	["<leader>"] = {
		x = {
			name = "Trouble",
			x = {
				function()
					require("trouble").toggle("document_diagnostics")
				end,
				"Toggle Document Diagnostics",
			},
			w = {
				function()
					require("trouble").toggle("workspace_diagnostics")
				end,
				"Toggle Workspace Diagnostics",
			},
			d = {
				function()
					require("trouble").toggle()
				end,
				"Toggle Diagnostics",
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
			t = {
				name = "Todo Comments",
				t = {
					"<cmd>TodoTrouble<CR>",
					"Toggles todolist",
				},
				l = {
					"<cmd>TodoLocList<CR>",
					"Toggles Loclist",
				},
				q = {
					"<cmd>TodoQuickFix<CR>",
					"Toggles Quickfix list",
				},
				n = {
					require("todo-comments").jump_next(),
				},
				p = {
					require("todo-comments").jump_prev(),
				},
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
			m = {
				function()
					require("gen").select_model()
				end,
				"Select model",
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
			o = {
				function()
					require("nvim-navbuddy").open()
				end,
				"Open navigation for code",
			},
		},
		d = {
			name = "Debug",
			n = {
				function()
					require("osv").launch({ port = 8086 })
				end,
				"Start neovim lua remote debugger",
			},
			nt = {
				function()
					require("osv").run_this()
				end,
				"Run present file with dap",
			},
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
			dp = "Goto previous",
			dn = "Goto next",
			dt = "Line diagnostics toggle",
			dh = "Diagnostics hide",
			ds = "Diagnostics show",
			dvt = {
				function()
					if Diagnostic_virtual_text then
						vim.diagnostic.config({
							virtual_text = true,
						})
						Diagnostic_virtual_text = false
					else
						vim.diagnostic.config({
							virtual_text = false,
						})
						Diagnostic_virtual_text = true
					end
				end,
				"Virtual text toggle",
			},
			q = {
				name = "Quickfix, Loclist",
				t = {
					"<cmd>QFToggle<CR>",
					"Toggle quickfix list",
				},
				l = {
					"<cmd>LLToggle<CR>",
					"Toggle loclist",
				},
			},
			j = {
				name = "Java",
				o = {
					function()
						require("jdtls").organize_imports()
					end,
					"Organize java imports",
				},
				v = {
					function()
						require("jdtls").extract_variable()
					end,
					"Extract variable",
				},
				V = {
					function()
						require("jdtls").extract_variable(true)
					end,
					"Extract variable in visual",
				},
				c = {
					function()
						require("jdtls").extract_constant()
					end,
					"Extract constant",
				},
				C = {
					function()
						require("jdtls").extract_constant(true)
					end,
					"Extract constant in visual",
				},
				m = {
					function()
						require("jdtls").extract_method(true)
					end,
					"Extract method",
				},
				tc = {
					function()
						require("jdtls").test_class()
					end,
					"Test nearest class",
				},
				tm = {
					function()
						require("jdtls").test_nearest_method()
					end,
					"Test nearest method",
				},
			},
		},
		w = {
			name = "Window",
			p = {
				function()
					local picked_window_id = require("window-picker").pick_window()
					gotoid(picked_window_id)
				end,
				"Navigate to the selected window",
			},
			x = {
				function()
					local picked_window_id = require("window-picker").pick_window()
					vim.api.nvim_win_close(picked_window_id, false)
				end,
				"Close the selected window",
			},
		},
		f = {
			name = "Find",
			r = {
				function()
					require("spectre").toggle()
				end,
				"Replace text in files",
			},
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
			o = {
				"<cmd>call aerial#fzf()<CR>",
				"Toggle fzf with aerial",
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
		g = {
			name = "Generate",
			g = {
				function()
					require("neogen").generate()
				end,
				"Generate annotations",
			},
			f = {
				function()
					require("neogen").generate({ type = "func" })
				end,
				"Generate annotations for function",
			},
			c = {
				function()
					require("neogen").generate({ type = "class" })
				end,
				"Generate annotations for class",
			},
			t = {
				function()
					require("neogen").generate({ type = "type" })
				end,
				"Generate annotations for type",
			},
			b = {
				function()
					require("neogen").generate({ type = "file" })
				end,
				"Generate annotations for  file",
			},
		},
		t = {
			name = "Neotest",
			t = {
				function()
					require("neotest").run.run()
				end,
				"Run nearest test",
			},
			f = {
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				"Run tests in current file",
			},
			d = {
				function()
					require("neotest").run.run({ strategy = "dap" })
				end,
				"Run tests with dap",
			},
			s = {
				function()
					require("neotest").run.stop()
				end,
				"Run tests with dap",
			},
			a = {
				function()
					require("neotest").run.attach()
				end,
				"Run tests with dap",
			},
		},
		r = "Rename",
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
	["<C-c><C-c>"] = "Cut to clipboard",
	["<C-S-v>"] = "Paste from clipboard",
	["<F2>"] = "Format file/range",
	["<F3>"] = "Prompt model",
	[";"] = "Edit arrow file",
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
