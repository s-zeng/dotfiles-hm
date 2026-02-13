local ok_ts, ts = pcall(require, "nvim-treesitter")
if ok_ts then
  ts.setup({})
end

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local started = pcall(vim.treesitter.start, args.buf)
    if started then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

local ok_textobjects = pcall(require, "nvim-treesitter-textobjects")
if ok_textobjects then
  local select = require("nvim-treesitter-textobjects.select")
  local move = require("nvim-treesitter-textobjects.move")
  local swap = require("nvim-treesitter-textobjects.swap")

  require("nvim-treesitter-textobjects").setup({
    move = {
      set_jumps = true,
    },
  })

  vim.keymap.set({ "x", "o" }, "af", function()
    select.select_textobject("@function.outer", "textobjects")
  end)
  vim.keymap.set({ "x", "o" }, "if", function()
    select.select_textobject("@function.inner", "textobjects")
  end)
  vim.keymap.set({ "x", "o" }, "ac", function()
    select.select_textobject("@class.outer", "textobjects")
  end)
  vim.keymap.set({ "x", "o" }, "ic", function()
    select.select_textobject("@class.inner", "textobjects")
  end)

  vim.keymap.set("n", "<leader>sa", function()
    swap.swap_next("@parameter.inner")
  end)
  vim.keymap.set("n", "<leader>sf", function()
    swap.swap_next("@function.outer")
  end)
  vim.keymap.set("n", "<leader>sA", function()
    swap.swap_previous("@parameter.inner")
  end)
  vim.keymap.set("n", "<leader>sF", function()
    swap.swap_previous("@function.outer")
  end)

  vim.keymap.set({ "n", "x", "o" }, "]]", function()
    move.goto_next_start("@function.outer", "textobjects")
  end)
  vim.keymap.set({ "n", "x", "o" }, "][", function()
    move.goto_next_end("@function.outer", "textobjects")
  end)
  vim.keymap.set({ "n", "x", "o" }, "[[", function()
    move.goto_previous_start("@function.outer", "textobjects")
  end)
  vim.keymap.set({ "n", "x", "o" }, "[]", function()
    move.goto_previous_end("@function.outer", "textobjects")
  end)

  vim.keymap.set({ "n", "x", "o" }, "]m", function()
    move.goto_next_start("@class.outer", "textobjects")
  end)
  vim.keymap.set({ "n", "x", "o" }, "]M", function()
    move.goto_next_end("@class.outer", "textobjects")
  end)
  vim.keymap.set({ "n", "x", "o" }, "[m", function()
    move.goto_previous_start("@class.outer", "textobjects")
  end)
  vim.keymap.set({ "n", "x", "o" }, "[M", function()
    move.goto_previous_end("@class.outer", "textobjects")
  end)

  vim.keymap.set({ "n", "x", "o" }, "]w", function()
    move.goto_next_start("@*.outer", "textobjects")
  end)
  vim.keymap.set({ "n", "x", "o" }, "]b", function()
    move.goto_previous_start("@*.outer", "textobjects")
  end)
  vim.keymap.set({ "n", "x", "o" }, "[w", function()
    move.goto_next_start("@*.*", "textobjects")
  end)
  vim.keymap.set({ "n", "x", "o" }, "[b", function()
    move.goto_previous_start("@*.*", "textobjects")
  end)

  local ok_lsp_interop, lsp_interop = pcall(require, "nvim-treesitter-textobjects.lsp_interop")
  if ok_lsp_interop and lsp_interop.peek_definition_code then
    vim.keymap.set("n", "<leader>lk", function()
      lsp_interop.peek_definition_code("@function.outer")
    end, { desc = "Peek function definition" })
    vim.keymap.set("n", "<leader>lK", function()
      lsp_interop.peek_definition_code("@class.outer")
    end, { desc = "Peek class definition" })
  end
end

vim.keymap.set("n", "<leader>k", function()
  require("treesitter-context").go_to_context()
end, { silent = true, desc = "Jump to parent" })

local ok_repeat, ts_repeat_move = pcall(require, "nvim-treesitter-textobjects.repeatable_move")
if ok_repeat then
  vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
  vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
  if ts_repeat_move.builtin_f_expr then
    vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
  elseif ts_repeat_move.builtin_f then
    vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
  end
  if ts_repeat_move.builtin_F_expr then
    vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
  elseif ts_repeat_move.builtin_F then
    vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
  end
  if ts_repeat_move.builtin_t_expr then
    vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
  elseif ts_repeat_move.builtin_t then
    vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
  end
  if ts_repeat_move.builtin_T_expr then
    vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
  elseif ts_repeat_move.builtin_T then
    vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
  end

  local gs = require("gitsigns")
  if ts_repeat_move.make_repeatable_move_pair then
    local next_hunk_repeat, prev_hunk_repeat = ts_repeat_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
    vim.keymap.set({ "n", "x", "o" }, "]h", next_hunk_repeat)
    vim.keymap.set({ "n", "x", "o" }, "[h", prev_hunk_repeat)
  elseif ts_repeat_move.make_repeatable_move then
    vim.keymap.set({ "n", "x", "o" }, "]h", ts_repeat_move.make_repeatable_move(gs.next_hunk))
    vim.keymap.set({ "n", "x", "o" }, "[h", ts_repeat_move.make_repeatable_move(gs.prev_hunk))
  end
end
