local function clone_paq()
  local path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
  local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0
  if not is_installed then
    vim.fn.system { "git", "clone", "--depth=1", "https://github.com/savq/paq-nvim.git", path }
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

bootstrap_paq {
  "savq/paq-nvim",
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  "windwp/nvim-ts-autotag",
}

require 'nvim-treesitter.configs'.setup {
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
      local max_filesize = 100 * 1024
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true
  },
  autotag = {
    enable = true,
    filetypes = { "html", "xml", "php", "vue", "svelte" },
  },
}

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false
