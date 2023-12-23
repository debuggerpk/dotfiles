require("nvim-treesitter.configs").setup {
  ensure_installed = "all",
  highlight = {
    enable = true,
  },
  rainbow = {
    enable = true,
    extended_mode = true,
  },
}

vim.opt.list = true
vim.opt.listchars:append("eol:↴")