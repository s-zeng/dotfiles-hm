local autocmds = {
  { cond = "BufNewFile",   cmd = { pattern = "*.ghci", command = "set filetype=haskell" } },
  { cond = "BufRead",      cmd = { pattern = "*.ghci", command = "set filetype=haskell" } },
  { cond = "CompleteDone", cmd = { pattern = "*", command = "silent! pclose!" } },
  { cond = "FileType",     cmd = { pattern = "json", command = [[syntax match Comment +\/\/.\+$+]] } },
  { cond = "FileType",     cmd = { pattern = { "lisp", "clojure", "scheme", "racket" }, command = "set lisp" } },
  {
    cond = "Filetype",
    cmd = {
      pattern = "markdown",
      command = "set tw=80 formatoptions+=wn2 spell shiftwidth=2 tabstop=2"
    }
  },
  { cond = "Filetype",  cmd = { pattern = "scheme", command = "set lispwords+=match lispwords-=if" } },
  { cond = "Filetype",  cmd = { pattern = "tex", command = "set tw=80 formatoptions+=wn2 spell" } },
  { cond = "Filetype",  cmd = { pattern = { "ruby", "lua" }, command = "set shiftwidth=2 tabstop=2" } },
  { cond = "TabLeave",  cmd = { pattern = "*", command = "let g:lasttab = tabpagenr()" } },
  { cond = "TermEnter", cmd = { pattern = "*", command = "setlocal scrolloff=0" } },
  { cond = "TermLeave", cmd = { pattern = "*", command = "setlocal scrolloff=999999" } },
  {
    cond = "TextYankPost",
    cmd = {
      pattern = "*",
      command = "silent! lua return (not vim.v.event.visual) and require'vim.hl'.on_yank{timeout=300}"
    }
  },
}

for _, cmd in ipairs(autocmds) do
  vim.api.nvim_create_autocmd(cmd.cond, cmd.cmd)
end
