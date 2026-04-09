return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  -- Все настройки передаются в таблицу opts
  opts = {
    transparent = true,
    styles = {
      sidebars = "transparent",
      floats = "transparent",
    },
    on_highlights = function(hl, c)
      hl.MsgArea = { bg = c.bg_statusline }
    end,
  },
  -- Функция config принимает настройки из opts и применяет их
  config = function(_, opts)
    require("tokyonight").setup(opts)
  end,
}
