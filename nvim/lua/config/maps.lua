local maps = {
  n = {
    ["<F10>"] = { ":10sp term://fish<CR>i", "Terminal split" },
    ["<F1>"] = "<nop>",
    ["<F9>"] = { ":Vista!!<CR>", "Tagbar" },
    ["<c-h>"] = { "<c-w>h", "Focus right" },
    ["<c-j>"] = { "<c-w>j", "Focus down" },
    ["<c-k>"] = { "<c-w>k", "Focus up" },
    ["<c-l>"] = { "<c-w>l", "Focus left" },
    ["<leader>>"] = { "0i     <ESC>A", "Indent right (forced)" },
    ["<leader><"] = { "V3<", "Deindent thrice" },
    ["<leader>c"] = { ":noh<CR>hl", "Clear search" },
    ["\\"] = { ":noh<CR>hl", "Clear search" },
    ["<leader>d"] = { ":lcd %:p:h<CR>", "Set working dir at current file" },
    ["<leader>O"] = { ":tabnew<CR>", "Open new tab" },
    ["<leader>v"] = { ":vsp<CR>", "Visual split" },
    ["<leader>0"] = { ":tablast<cr>", "Most recent tab" },
    ["<leader>1"] = { "1gt", "Tab 1" },
    ["<leader>2"] = { "2gt", "Tab 2" },
    ["<leader>3"] = { "3gt", "Tab 3" },
    ["<leader>4"] = { "4gt", "Tab 4" },
    ["<leader>5"] = { "5gt", "Tab 5" },
    ["<leader>6"] = { "6gt", "Tab 6" },
    ["<leader>7"] = { "7gt", "Tab 7" },
    ["<leader>8"] = { "8gt", "Tab 8" },
    ["<leader>9"] = { "9gt", "Tab 0" },
    ["<leader>t"] = { ":tabnew<CR>", "Open new tab" },
    ["<leader>T"] = { "<c-w>T", "Move buffer to newtab" },
    ["<leader>rr"] = { ":e!<CR>", "Refresh buffer" },
    ["<leader>ql"] = { ":tabnew term://lazygit<CR>", "Lazygit" },
    ["<leader>Gl"] = { ":tabnew term://lazygit<CR>", "Lazygit" },
    ["<leader>qf"] = { "<c-w>h:%!ruff format - -q<CR><c-w>l:%!ruff format - -q<CR>", "Format diff (python)" },
    ["<leader>Gf"] = { "<c-w>h:%!ruff format - -q<CR><c-w>l:%!ruff format - -q<CR>", "Format diff (python)" },
    ["<leader>pf"] = { ":%!ruff format - -q<CR>", "Ruff format" },
    ["<leader>F"] = { ":let @+=@%<CR>", "Copy current file relative path" },
    ["<leader>li"] = { ":LspInfo<CR>", "Lsp Info" },
    ["<leader>y"] = { '"+y', "Copy to clipboard" },
    ["gh"] = { "0", "Home" },
    ["gl"] = { "$", "End" },
    ["Q"] = "<nop>",
    ["`"] = { "<cmd>lua require'lib/float'()<CR>", "Open terminal (floating)" },
    ["gj"] = "j",
    ["gk"] = "k",
    ["ge"] = "G",
    ["j"] = { "gj", "Go down true line" },
    ["k"] = { "gk", "Go up true line" },
  },
  i = {
    ["<S-Tab>"] = { [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], nil, { noremap = true, expr = true } },
    ["<Tab>"] = { [[pumvisible() ? "\<C-n>" : "\<Tab>"]], nil, { noremap = true, expr = true } },
    ["<Up>"] = { [[pumvisible() ? "\<C-p>" : "\<Up>"]], nil, { noremap = true, expr = true } },
    ["<Down>"] = { [[pumvisible() ? "\<C-n>" : "\<Down>"]], nil, { noremap = true, expr = true } },
    ["<c-c>"] = "<ESC>",
    ["<D-v>"] = "<C-R>+",
    ["<cr>"] = { [[pumvisible() ? "\<C-y>" : "\<cr>"]], nil, { noremap = true, expr = true } },
    ["jjfa"] = '∀',
    ["jjla"] = 'λ',
    ["jjra"] = '→',
    ["kj"] = '<ESC>',
  },
  t = {
    ["<Esc>"] = [[<C-\><C-n>]],
  },
  c = {
  },
  v = {
    ["<leader>pf"] = { ":!ruff format - -q<CR>", "Ruff format" },
    ["<leader>y"] = { '"+y', "Copy to clipboard" },
  }
}

for mode, mappings in pairs(maps) do
  for keys, mapping in pairs(mappings) do
    if type(mapping) == "string" then
      vim.keymap.set(mode, keys, mapping, { remap = false })
    else
      local opts = mapping[3] or {}
      opts.remap = false
      opts.desc = mapping[2]
      vim.keymap.set(mode, keys, mapping[1], opts)
    end
  end
end

