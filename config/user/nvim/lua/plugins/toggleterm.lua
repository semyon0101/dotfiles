local function resize_terminal(term)
  if term.direction == "vertical" and term.window and vim.api.nvim_win_is_valid(term.window) then
    local target_width = math.floor(vim.o.columns * 0.4)
    vim.api.nvim_win_set_width(term.window, target_width)
  end
end

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    open_mapping = nil,
    direction = "vertical",
    shell = vim.o.shell,
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
    float_opts = {
      border = "curved",
      winblend = 0,
    },
    shade_terminals = true,
    on_open = function(term)
      resize_terminal(term)
    end,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    vim.api.nvim_create_autocmd("VimResized", {
      group = vim.api.nvim_create_augroup("ToggleTermDynamicResize", { clear = true }),
      callback = function()
        local terms = require("toggleterm.terminal").get_all()
        for _, t in pairs(terms) do
          resize_terminal(t)
        end
      end,
    })
  end,
}
