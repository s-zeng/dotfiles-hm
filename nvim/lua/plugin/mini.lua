require('mini.comment').setup()
require('mini.fuzzy').setup()
require('mini.files').setup()
require('mini.pairs').setup()
require('mini.move').setup()
local hipatterns = require('mini.hipatterns').setup()
hipatterns.setup({
  highlighters = {
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
