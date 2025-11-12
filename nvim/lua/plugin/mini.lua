require('mini.ai').setup()
require('mini.icons').setup()
require('mini.pairs').setup()
require('mini.move').setup()
require('mini.splitjoin').setup()
require('mini.tabline').setup({ set_vim_settings = false })
require('mini.statusline').setup({ set_vim_settings = false })

local miniclue = require('mini.clue')
miniclue.setup({
  triggers = {
    -- Leader triggers
    { mode = 'n', keys = '<Leader>' },
    { mode = 'x', keys = '<Leader>' },

    -- Built-in completion
    { mode = 'i', keys = '<C-x>' },

    -- `g` key
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },

    -- `][` keys
    { mode = 'n', keys = '[' },
    { mode = 'x', keys = '[' },
    { mode = 'n', keys = ']' },
    { mode = 'x', keys = ']' },

    -- Marks
    { mode = 'n', keys = "'" },
    { mode = 'x', keys = "'" },

    -- Registers
    { mode = 'n', keys = '"' },
    { mode = 'x', keys = '"' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'c', keys = '<C-r>' },

    -- Window commands
    { mode = 'n', keys = '<C-w>' },

    -- `z` key
    { mode = 'n', keys = 'z' },
    { mode = 'x', keys = 'z' },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
    { mode = 'n', keys = '<Leader>q', desc = '+Git' },
    { mode = 'x', keys = '<Leader>q', desc = '+Git' },
    { mode = 'n', keys = '<Leader>G', desc = '+Git' },
    { mode = 'x', keys = '<Leader>G', desc = '+Git' },
    { mode = 'n', keys = '<Leader>p', desc = '+Python' },
    { mode = 'x', keys = '<Leader>p', desc = '+Python' },
    { mode = 'n', keys = '<Leader>l', desc = '+Lsp' },
    { mode = 'n', keys = '<Leader>r', desc = '+Dap (Mostly)' },
    { mode = 'n', keys = '<Leader>s', desc = '+Swap' },
  },

  window = {
    delay = 0,
  }
})

local hipatterns = require('mini.hipatterns')
hipatterns.setup({
  highlighters = {
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

local indentscope = require('mini.indentscope')
indentscope.setup({
  symbol = '┃',
  draw = {
    delay = 0,
    animation = indentscope.gen_animation.none()
  },
  options = {
    border = 'top',
  }
})
vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { link = 'Comment' })

local minimap = require('mini.map')
minimap.setup({
  integrations = {
    minimap.gen_integration.builtin_search(),
    minimap.gen_integration.gitsigns(),
    minimap.gen_integration.diagnostic(),
  },
  symbols = {
    encode = minimap.gen_encode_symbols.block('3x2')
  },
  window = {
    focusable = true,
    width = 25,
  }
})
vim.keymap.set('n', '<leader>m', MiniMap.toggle, { desc = "Toggle minimap" })

require('mini.pick').setup({
  mappings = {
    move_down = "<Down>",
    move_up = "<Up>",
  },
})
require('mini.extra').setup()
vim.api.nvim_set_hl(0, 'MiniPickMatchCurrent', { link = 'TelescopeSelection' })
MiniPick.registry.registry = function()
  local items = vim.tbl_keys(MiniPick.registry)
  table.sort(items)
  local source = { items = items, name = 'Registry', choose = function() end }
  local chosen_picker_name = MiniPick.start({ source = source })
  if chosen_picker_name == nil then return end
  return MiniPick.registry[chosen_picker_name]()
end
vim.keymap.set('n', '<leader>q/', MiniExtra.pickers.git_hunks, { desc = "Search hunks" })
vim.keymap.set('n', '<leader>G/', MiniExtra.pickers.git_hunks, { desc = "Search hunks" })
vim.keymap.set('n', '<leader>o', MiniPick.builtin.files, { desc = "Open file (fd)" })
vim.keymap.set('n', '<leader>g', MiniPick.builtin.grep_live, { desc = "Ripgrep" })
vim.keymap.set('n', '<leader>h', MiniPick.builtin.help, { desc = "Vim help" })
vim.keymap.set('n', '<leader><leader>', MiniPick.builtin.resume, { desc = "Resume last picker" })
vim.keymap.set('n', '<leader>/', MiniExtra.pickers.buf_lines, { desc = "Fuzzy find in buffer" })
vim.keymap.set('n', '<leader>:', MiniExtra.pickers.commands, { desc = "Command list" })
vim.keymap.set('n', '<leader><Up>', MiniExtra.pickers.history, { desc = "Command history" })
vim.keymap.set('n', '<leader>z', MiniExtra.pickers.spellsuggest, { desc = "Suggest spelling" })
vim.keymap.set('n', '<leader>?', MiniPick.registry.registry, { desc = "List pickers" })
vim.keymap.set('n', '<F8>', MiniExtra.pickers.explorer, { desc = "File explorer" })
vim.keymap.set('n', '<leader>lr', function() MiniExtra.pickers.lsp({ scope = 'references' }) end,
  { desc = "List references" })
vim.ui.select = MiniPick.ui_select

require('mini.surround').setup({
  mappings = {
    add = 'ys',
    delete = 'ds',
    find = '',
    find_left = '',
    highlight = '',
    replace = 'cs',
    update_n_lines = '',
  },
})
local starter = require('mini.starter')
starter.setup({
  items = {
    starter.sections.recent_files(5, true, true),
    starter.sections.recent_files(5, false, true),
    { name = "Home Manager Config", action = "e ~/.config/home-manager/home.nix", section = "Vim things" },
    { name = "Neogit",              action = "Neogit",                            section = "Vim things" },
    starter.sections.builtin_actions(),
  },
})

local notify = require('mini.notify')
notify.setup()
vim.notify = notify.make_notify({
  ERROR = { duration = 5000 },
  WARN = { duration = 4000 },
  INFO = { duration = 3000 },
})

local gen_loader = require('mini.snippets').gen_loader
require('mini.snippets').setup({
  snippets = {
    -- Load custom file with global snippets first (adjust for Windows)
    gen_loader.from_file('~/.config/nvim/snippets/global.json'),

    -- Load snippets based on current language by reading files from
    -- "snippets/" subdirectories from 'runtimepath' directories.
    gen_loader.from_lang(),
  },
})

-- for plugins not on nix yet
require('mini.deps').setup()

MiniDeps.add({
  source = 'rafikdraoui/jj-diffconflicts',
})

