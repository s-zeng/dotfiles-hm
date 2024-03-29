local ts = require'nvim-treesitter.configs'

ts.setup {
    ensure_installed = {},
    highlight = {
        enable = true,            -- false will disable the whole extension
        -- disable = {"haskell"}
    },
    indent = {
        enable = true,
        -- https://www.reddit.com/r/neovim/comments/l3mpiv/i_just_discovered_treesitter_was_the_reason_my/
        disable = {"python"}
    },
    rainbow = {
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
                ["<leader>s"] = "@parameter.inner",
            },
            swap_previous = {
                ["<leader>S"] = "@parameter.inner",
            },
        },
        move = {
            enable = true,
            goto_next_start = {
                ["]]"] = "@function.outer",
                ["]m"] = "@class.outer",
            },
            goto_next_end = {
                ["]["] = "@function.outer",
                ["]M"] = "@class.outer",
            },
            goto_previous_start = {
                ["[["] = "@function.outer",
                ["[m"] = "@class.outer",
            },
            goto_previous_end = {
                ["[]"] = "@function.outer",
                ["[M"] = "@class.outer",
            },
        },
    },
}

vim.keymap.set("n", "<leader>k", function()
  require("treesitter-context").go_to_context()
end, { silent = true })
