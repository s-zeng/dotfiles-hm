require('mini.comment').setup()
require('mini.fuzzy').setup()
require('mini.files').setup()
require('mini.pairs').setup()
require('mini.move').setup()
require('mini.splitjoin').setup()
require('mini.starter').setup()
local hipatterns = require('mini.hipatterns')
hipatterns.setup({
  highlighters = {
    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
