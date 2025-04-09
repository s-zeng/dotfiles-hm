-- ~/.config/nvim/after/ftplugin/haskell.lua
local ht = require('haskell-tools')
local bufnr = vim.api.nvim_get_current_buf()
-- haskell-language-server relies heavily on codeLenses,
-- so auto-refresh (see advanced configuration) is enabled by default
vim.keymap.set('n', '<space>pc', vim.lsp.codelens.run, {desc="Run Codelens", noremap=true, silent=true, buffer=bufnr, })
-- Hoogle search for the type signature of the definition under the cursor
vim.keymap.set('n', '<space>ph', ht.hoogle.hoogle_signature, {desc="Hoogle Signature", noremap=true, silent=true, buffer=bufnr, })
-- Evaluate all code snippets
vim.keymap.set('n', '<space>pe', ht.lsp.buf_eval_all, {desc="Evaluate all code snippets", noremap=true, silent=true, buffer=bufnr, })
-- Toggle a GHCi repl for the current package
vim.keymap.set('n', '<leader>pr', ht.repl.toggle, {desc="Toggle GHCi Repl (Package)", noremap=true, silent=true, buffer=bufnr, })
-- Toggle a GHCi repl for the current buffer
vim.keymap.set('n', '<leader>pb', function()
  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
end, {desc="Toggle GHCi Repl (Buffer)", noremap=true, silent=true, buffer=bufnr, })
vim.keymap.set('n', '<leader>pq', ht.repl.quit, {desc="Quit Repl", noremap=true, silent=true, buffer=bufnr, })
