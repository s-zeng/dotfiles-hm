require('mini.comment').setup()
require('mini.fuzzy').setup()
require('mini.files').setup()
require('mini.pairs').setup()
require('mini.move').setup()
require('mini.splitjoin').setup()
require('mini.surround').setup({
  mappings = {
    add = 'ys',
    delete = 'ds',
    find = '',
    find_left = '',
    highlight = '',
    replace = '',
    update_n_lines = '',
  },
})
local hipatterns = require('mini.hipatterns')
hipatterns.setup({
  highlighters = {
    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
