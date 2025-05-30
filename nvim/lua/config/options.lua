local options = {
  completeopt = "menuone,noinsert,noselect,fuzzy,popup",
  conceallevel = 3,
  confirm = true,
  cursorline = true,
  expandtab = true,
  foldlevel = 99,
  foldmethod = "expr",
  grepprg = "rg --vimgrep",
  guifont = "JetBrainsMono Nerd Font Mono:h13",
  ignorecase = true,
  inccommand = "split",
  laststatus = 3,
  linebreak = true,
  number = true,
  pumblend = 10,
  relativenumber = true,
  scrolloff = 999999,
  shiftwidth = 4,
  shortmess = "aoOTIcF",
  showmatch = true,
  sidescrolloff = 5,
  smartcase = true,
  smartindent = true,
  splitbelow = true,
  splitkeep = "screen",
  splitright = true,
  tabstop = 4,
  timeoutlen = 300,
  undofile = true,
  undolevels = 10000,
  virtualedit = "block",
  winborder = 'rounded',
  wrap = false,
}


for name, value in pairs(options) do
  vim.o[name] = value
end
