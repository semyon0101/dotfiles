return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("telescope").setup({
      pickers = {
        find_files = {
          hidden = true,
          no_ignore = true,
        },
      },
      defaults = {
        get_selection_window = function()
          local current_win = vim.api.nvim_get_current_win()
          -- If current window isn't fixed, use it
          if not vim.wo[current_win].winfixbuf then
            return current_win
          end

          -- Otherwise, find the first unlocked, editable window
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_is_valid(win) and not vim.wo[win].winfixbuf then
              return win
            end
          end

          return 0
        end,
      },
    })
  end,
}
