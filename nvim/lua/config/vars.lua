local gvars = {
  coq_settings                = {
    clients = {lsp = {always_on_top = {};};};
    auto_start = "shut-up",
    keymap = { jump_to_mark = "<c-m>" }
  },
  gruvbox_filetype_hi_groups  = 0,
  gruvbox_material_palette    = "original",
  indentLine_char             = '┃',
  loaded_2html_plugin         = 0,
  loaded_pkgbuild_plugin      = 0,
  loaded_tutor_mode_plugin    = 0,
  mapleader                   = " ",
  maplocalleader              = ",",
  tex_flavor                  = "latex",
  vista_default_executive     = 'nvim_lsp',
  vista_executive_for         = { vimwiki = 'markdown', pandoc = 'markdown', markdown = 'toc' },
  loaded_python_provider      = 0,
  loaded_ruby_provider        = 0,
  loaded_perl_provider        = 0,
  loaded_node_provider        = 0,
}

for name, value in pairs(gvars) do
  vim.g[name] = value
end
