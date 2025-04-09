local api = vim.api

function float()
  local columns = api.nvim_get_option("columns")
  local lines = api.nvim_get_option("lines")

  local height = math.ceil((lines - 2) * 0.6)
  local row = math.ceil((lines - height) / 2)
  local width = math.ceil(columns * 0.6)
  local col = math.ceil((columns - width) / 2)

  local opts = {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal"
  }

  local buf = api.nvim_create_buf(false, true)
  local float_term_win = api.nvim_open_win(buf, true, opts)

  api.nvim_win_set_option(float_term_win, 'winhl', 'Normal:Floating')

  vim.cmd [[terminal]]
  vim.cmd [[startinsert]]
end

return float
