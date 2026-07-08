local M = {}

local function selected_variant()
  local state_home = vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")
  local file = io.open(state_home .. "/warm-burnout/variant", "r")
  if not file then
    return "light"
  end

  local variant = file:read("*l")
  file:close()
  return variant == "dark" and "dark" or "light"
end

function M.load()
  vim.cmd.colorscheme("warm-burnout-" .. selected_variant())
end

function M.setup()
  M.load()

  M.signal = vim.uv.new_signal()
  M.signal:start("sigusr1", function()
    vim.schedule(M.load)
  end)
end

return M
