local options = {
  -- foldmethod="expr";
  completeopt = "menuone,noinsert,noselect",
  conceallevel = 3,
  confirm = true,
  cursorline = true,
  expandtab = true,
  foldexpr = "nvim_treesitter#foldexpr()",
  foldlevel = 99,
  foldmethod = "indent",
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
  shell = "/home/kronicmage/.nix-profile/bin/fish",
  shiftwidth = 4,
  shortmess = "aoOTIcF",
  showmatch = true,
  sidescrolloff = 5,
  smartcase = true,
  smartindent = true,
  splitbelow = true,
  splitright = true,
  tabstop = 4,
  timeoutlen = 300,
  undofile = true,
  undolevels = 10000,
  virtualedit = "block",
  wrap = false,
}


for name, value in pairs(options) do
  vim.o[name] = value
end
