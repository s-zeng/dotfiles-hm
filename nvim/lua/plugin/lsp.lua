require("neodev").setup({})
local lsp_status = require('lsp-status')
local nvim_lsp = require('lspconfig')

lsp_status.register_progress()
vim.api.nvim_set_hl(0, 'LspCodeLens', { link = 'StatusLineNC' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.noremap = true
      opts.buffer = ev.buf
      vim.keymap.set(mode, l, r, opts)
    end

    map('n', 'gD', vim.lsp.buf.declaration, { desc = "Go to declaration" })
    map('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
    map('n', '<leader>la', vim.lsp.buf.code_action, { desc = "Code action" })
    map('n', '<leader>lc', vim.lsp.codelens.run, { desc = "Run code lens" })
    map('n', '<leader>lS', vim.lsp.buf.signature_help, { desc = "Signature help" })
    map('n', '<leader>lf', function() vim.lsp.buf.format { async = true } end, { desc = "Format" })
    map('n', '<leader>lR', vim.lsp.buf.rename, { desc = "Rename" })
    map('n', '<leader>e', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
    map('n', '<leader>E', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
    map('n', 'gr', vim.lsp.buf.references, { desc = "Get references" })
    map('n', '<leader>lt', vim.lsp.buf.type_definition, { desc = "Type definition" })
    map('n', '<leader>ll', function()
      local line_only = { only_current_line = true }
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

local default_config_servers = {
  'bashls',
  'clojure_lsp',
  'cmake',
  'cssls',
  'dhall_lsp_server',
  'dockerls',
  'html',
  'hls',
  'jsonls',
  'lua_ls',
  'metals',
  'nil_ls',
  'ocamllsp',
  'pyright',
  'rust_analyzer',
  'texlab',
  'vimls',
  'yamlls'
}

for _, lsp in ipairs(default_config_servers) do
  nvim_lsp[lsp].setup({
    on_attach = lsp_status.on_attach,
    capabilities = lsp_status.capabilities,
    flags = {
      debounce_text_changes = 150,
    }
  })
end

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


-- local ht = require('haskell-tools')

-- ht.setup {
--   hls = {
--     -- See nvim-lspconfig's  suggested configuration for keymaps, etc.
--     on_attach = function(client, bufnr)
--       local opts = { noremap = true, buffer = bufnr }
--       -- haskell-language-server relies heavily on codeLenses,
--       -- so auto-refresh (see advanced configuration) is enabled by default
--       vim.keymap.set('n', '<leader>hs', ht.hoogle.hoogle_signature, opts)
--       vim.keymap.set('n', '<leader>ha', ht.lsp.buf_eval_all, opts)
--       -- Toggle a GHCi repl for the current package
--       vim.keymap.set('n', '<leader>hr', ht.repl.toggle, opts)
--       -- Toggle a GHCi repl for the current buffer
--       vim.keymap.set('n', '<leader>hf', function()
--         ht.repl.toggle(vim.api.nvim_buf_get_name(0))
--       end, opts)
--       vim.keymap.set('n', '<leader>hq', ht.repl.quit, opts)
--       return lsp_status.on_attach(client, bufnr) -- if defined, see nvim-lspconfig
--     end,
--     capabilities = lsp_status.capabilities,
--     flags = {
--       debounce_text_changes = 150,
--     }
--   },
-- }
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


nvim_lsp['clangd'].setup({
  on_attach = lsp_status.extensions.clangd.setup,
  capabilities = lsp_status.capabilities,
  flags = {
    debounce_text_changes = 150,
  }
})

require('lspkind').init()
require("lsp_lines").setup()

vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false,
  update_in_insert = false,
})


nvim_lsp["ruff_lsp"].setup({
  on_attach = function(client, bufnr)
    client.server_capabilities.hoverProvider = false
    return lsp_status.on_attach(client, bufnr)
  end,
  capabilities = lsp_status.capabilities,
})
