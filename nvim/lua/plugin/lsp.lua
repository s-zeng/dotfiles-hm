local lsp_status = require('lsp-status')

lsp_status.register_progress()
vim.api.nvim_set_hl(0, 'LspCodeLens', { link = 'StatusLineNC' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.noremap = true
      opts.buffer = ev.buf
      vim.keymap.set(mode, l, r, opts)
    end

    map('n', 'gD', vim.lsp.buf.declaration, { desc = "Go to declaration" })
    map('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
    map('n', '<leader>lc', vim.lsp.codelens.run, { desc = "Run code lens" })
    map('n', '<leader>lf', function() vim.lsp.buf.format { async = true } end, { desc = "Format" })
    map('n', '<leader>e', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
    map('n', '<leader>E', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
    map('n', '<leader>lt', vim.lsp.buf.type_definition, { desc = "Type definition" })
    map('n', '<leader>ll', function()
      local line_only = { current_line = true }
      local old_value = vim.diagnostic.config().virtual_lines
      if old_value == false then
        vim.diagnostic.config({ virtual_lines = true })
      elseif old_value == true then
        vim.diagnostic.config({ virtual_lines = line_only })
      else
        vim.diagnostic.config({ virtual_lines = false })
      end
    end, { desc = "Toggle lsp_lines" })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" },
      { pattern = "<buffer>", callback = vim.diagnostic.open_float })
  end,
})

-- local default_config_servers = {
--   'bashls',
--   'clojure_lsp',
--   'cmake',
--   'clangd',
--   'cssls',
--   'dhall_lsp_server',
--   'dockerls',
--   'html',
--   'jsonls',
--   'metals',
--   'nil_ls',
--   'ocamllsp',
--   'texlab',
--   'yamlls'
-- }

vim.lsp.config('*', {
  on_attach = lsp_status.on_attach,
  capabilities = lsp_status.capabilities,
  flags = {
    debounce_text_changes = 150,
  }
})

vim.lsp.enable({
  'lua_ls',
  'pyright',
  'ruff',
  'rust_analyzer',
})

vim.api.nvim_create_autocmd({ "Filetype" }, {
  pattern = {
    "typescript",
    "javascript",
    "typescriptreact",
    "javascriptreact"
  },
  callback = function(_)
    require("typescript-tools").setup({
      on_attach = lsp_status.on_attach,
      capabilities = lsp_status.capabilities,
      flags = {
        debounce_text_changes = 150,
      },
      settings = {
        complete_function_calls = false,
        code_lens = "all",
        jsx_close_tag = {
          enable = true,
          filetypes = { "javascriptreact", "typescriptreact" }
        },
      },
    })
  end
})

require('lspkind').init()

vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false,
  update_in_insert = false,
})
