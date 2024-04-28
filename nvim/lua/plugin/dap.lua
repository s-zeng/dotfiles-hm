require("dap-python").setup("~/.nix-profile/bin/python3")

require("dapui").setup({
  layouts = { {
    elements = { {
      id = "scopes",
      size = 0.4
    }, {
      id = "breakpoints",
      size = 0.2
    }, {
      id = "stacks",
      size = 0.2
    }, {
      id = "watches",
      size = 0.2
    } },
    position = "left",
    size = 30
  }, {
    elements = { {
      id = "repl",
      size = 1
    },
      -- {
      --   id = "console",
      --   size = 0.5
      -- }
    },
    position = "bottom",
    size = 12
  } },
})

vim.keymap.set('n', '<leader>ru', require("dapui").toggle, { remap = false, desc = 'Toggle DAP' })
vim.keymap.set('n', '<leader>rj', ":DapStepOver<CR>", { remap = false, desc = 'Step Over' })
vim.keymap.set('n', '<leader>rb', ":DapToggleBreakpoint<CR>", { remap = false, desc = 'Toggle breakpoint' })
vim.keymap.set('n', '<leader>re', require("dapui").eval, { remap = false, desc = 'Eval' })
vim.keymap.set('n', '<leader>rl', ":DapStepInto<CR>", { remap = false, desc = 'Step into' })
vim.keymap.set('n', '<leader>rk', ":DapStepOut<CR>", { remap = false, desc = 'Step out' })
vim.keymap.set('n', '<leader>rp', ":DapContinue<CR>", { remap = false, desc = 'Continue/Start debugging' })
vim.keymap.set('n', '<leader>rt', ":DapTerminate<CR>:lua require('dapui').toggle()<CR>",
  { remap = false, desc = 'Terminate debugging' })
