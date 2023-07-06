local lsp_status = require('lsp-status')
local nvim_lsp = require('lspconfig')

lsp_status.register_progress()

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    local opts = { noremap = true, buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>lc', vim.lsp.codelens.run, opts)
    vim.keymap.set('n', '<leader>lS', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>lf', function() vim.lsp.buf.format { async = true } end, opts)
    -- vim.keymap.set('v', '<leader>lF', vim.lsp.formatexpr({},{0,0},{vim.fn.line("$"),0}), opts)
    vim.keymap.set('n', '<leader>ld', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', 'g0', vim.lsp.buf.document_symbol, opts)
    -- vim.keymap.set('n', 'gW', vim.lsp.buf.workplace_symbol, opts)
    vim.keymap.set('n', '[c', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']c', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>E', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>lt', require 'lsp_extensions'.inlay_hints, opts)
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" },
      { pattern = "<buffer>", callback = vim.diagnostic.open_float })
  end,
})

local configs = require 'lspconfig/configs'
local util = require 'lspconfig/util'

local default_config_servers = {
  'bashls',
  'clojure_lsp',
  'cmake',
  'cssls',
  'dhall_lsp_server',
  'dockerls',
  'html',
  'jsonls',
  'lua_ls',
  'metals',
  'ocamllsp',
  'pyright',
  'rnix',
  'rust_analyzer',
  'texlab',
  'tsserver',
  'vimls',
  'yamlls'
}

for _, lsp in ipairs(default_config_servers) do
  nvim_lsp[lsp].setup {
    on_attach = lsp_status.on_attach,
    capabilities = lsp_status.capabilities,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

local ht = require('haskell-tools')

ht.setup {
  hls = {
    -- See nvim-lspconfig's  suggested configuration for keymaps, etc.
    on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }
      -- haskell-language-server relies heavily on codeLenses,
      -- so auto-refresh (see advanced configuration) is enabled by default
      vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, opts)
      lsp_status.on_attach(client, bufnr) -- if defined, see nvim-lspconfig
    end,
  },
}

nvim_lsp['clangd'].setup {
  on_attach = lsp_status.extensions.clangd.setup,
  capabilities = lsp_status.capabilities,
  flags = {
    debounce_text_changes = 150,
  }
}

require('lspkind').init()

vim.diagnostic.config({
  -- underline = {
  --   severity = { max = vim.diagnostic.severity.INFO }
  -- },
  virtual_text = {
    severity = { min = vim.diagnostic.severity.ERROR }
  }
})
