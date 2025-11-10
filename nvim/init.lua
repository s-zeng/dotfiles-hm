vim.loader.enable()

require('config/autocmds')
require('config/commands')
require('config/options')
require('config/vars')
require('plugin/lsp')
require('plugin/treesitter')
require('plugin/mini')
require('plugin/dap')
require('plugin/gitsigns')

require("leap").add_default_mappings()
vim.cmd.colorscheme "gruvbox"

require('config/maps')

require("neogit").setup()
require("hunk").setup()
