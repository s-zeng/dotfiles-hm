require('gitsigns').setup {
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    -- map('n', ']g', function()
    --   if vim.wo.diff then return ']c' end
    --   vim.schedule(function() gs.next_hunk() end)
    --   return '<Ignore>'
    -- end, { expr = true })
    --
    -- map('n', '[g', function()
    --   if vim.wo.diff then return '[c' end
    --   vim.schedule(function() gs.prev_hunk() end)
    --   return '<Ignore>'
    -- end, { expr = true })
    --
    -- Actions
    map('n', '<leader>qs', gs.stage_hunk, { desc = "Stage hunk" })
    map('n', '<leader>qr', gs.reset_hunk, { desc = "Reset hunk" })
    map('v', '<leader>qs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "Stage hunk" })
    map('v', '<leader>qr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "Reset hunk" })
    map('n', '<leader>qS', gs.stage_buffer, { desc = "Stage buffer" })
    map('n', '<leader>qu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
    map('n', '<leader>qR', gs.reset_buffer, { desc = "Reset buffer" })
    map('n', '<leader>qp', gs.preview_hunk, { desc = "Preview Hunk" })
    map('n', '<leader>qb', function() gs.blame_line { full = true } end, { desc = "Blame line" })
    map('n', '<leader>qB', ':GitBlameToggle<CR>', { desc = "Toggle blame hints" })
    map('n', '<leader>qd', gs.diffthis, { desc = "Diff this" })
    map('n', '<leader>qD', function() gs.diffthis('~') end, { desc = "Diff this" })
    map('n', '<leader>qt', gs.toggle_deleted, { desc = "Toggle deleted" })
    map('n', '<leader>qn', gs.next_hunk, { desc = "Next hunk" })
    map('n', '<leader>qN', gs.next_hunk, { desc = "Previous hunk" })
    map('n', '<leader>qg', ':Neogit<CR>', { desc = 'Neogit' })
    map('n', '<leader>qq', ':Neogit<CR>', { desc = 'Neogit' })
    map('n', '<leader>q<leader>', ':Gitsigns<CR>', { desc = 'Gitsigns action' })
    map('n', '<leader>Gs', gs.stage_hunk, { desc = "Stage hunk" })
    map('n', '<leader>Gr', gs.reset_hunk, { desc = "Reset hunk" })
    map('v', '<leader>Gs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "Stage hunk" })
    map('v', '<leader>Gr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "Reset hunk" })
    map('n', '<leader>GS', gs.stage_buffer, { desc = "Stage buffer" })
    map('n', '<leader>Gu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
    map('n', '<leader>GR', gs.reset_buffer, { desc = "Reset buffer" })
    map('n', '<leader>Gp', gs.preview_hunk, { desc = "Preview Hunk" })
    map('n', '<leader>Gb', function() gs.blame_line { full = true } end, { desc = "Blame line" })
    map('n', '<leader>GB', ':GitBlameToggle<CR>', { desc = "Toggle blame hints" })
    map('n', '<leader>Gd', gs.diffthis, { desc = "Diff this" })
    map('n', '<leader>GD', function() gs.diffthis('~') end, { desc = "Diff this" })
    map('n', '<leader>Gt', gs.toggle_deleted, { desc = "Toggle deleted" })
    map('n', '<leader>Gn', gs.next_hunk, { desc = "Next hunk" })
    map('n', '<leader>GN', gs.next_hunk, { desc = "Previous hunk" })
    map('n', '<leader>Gg', ':Neogit<CR>', { desc = 'Neogit' })
    map('n', '<leader>Gq', ':Neogit<CR>', { desc = 'Neogit' })
    map('n', '<leader>G<leader>', ':Gitsigns<CR>', { desc = 'Gitsigns' })

    -- Text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}
