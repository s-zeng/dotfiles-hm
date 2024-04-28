local ts = require 'nvim-treesitter.configs'

ts.setup {
  ensure_installed = {},
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<Enter>",
      node_incremental = "<Enter>",
      scope_incremental = "+",
      node_decremental = "<BS>",
    },
  },
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>sa"] = "@parameter.inner",
        ["<leader>sf"] = "@function.outer",
      },
      swap_previous = {
        ["<leader>sA"] = "@parameter.inner",
        ["<leader>sF"] = "@function.outer",
      },
    },
    move = {
      enable = true,
      goto_next_start = {
        ["]]"] = "@function.outer",
        ["]m"] = "@class.outer",
        ["]w"] = "@*.outer",
      },
      goto_next_end = {
        ["]["] = "@function.outer",
        ["]M"] = "@class.outer",
      },
      goto_previous_start = {
        ["[["] = "@function.outer",
        ["[m"] = "@class.outer",
        ["]b"] = "@*.outer",
      },
      goto_previous_end = {
        ["[]"] = "@function.outer",
        ["[M"] = "@class.outer",
      },
      goto_next = {
        ["[w"] = "@*.*",
      },
      goto_previous = {
        ["[b"] = "@*.*",
      },
    },
    lsp_interop = {
      enable = true,
      border = 'none',
      floating_preview_opts = {},
      peek_definition_code = {
        ["<leader>lk"] = "@function.outer",
        ["<leader>lK"] = "@class.outer",
      },
    },
  },
}

vim.keymap.set("n", "<leader>k", function()
  require("treesitter-context").go_to_context()
end, { silent = true, desc = "Jump to parent" })

local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"

vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)

-- gitsigns
local gs = require("gitsigns")
local next_hunk_repeat, prev_hunk_repeat = ts_repeat_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
vim.keymap.set({ "n", "x", "o" }, "]h", next_hunk_repeat)
vim.keymap.set({ "n", "x", "o" }, "[h", prev_hunk_repeat)
