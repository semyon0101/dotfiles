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

      hl.Pmenu = { bg = c.bg_statusline }
      hl.PmenuBorder = { fg = c.cyan, bg = c.bg_statusline }

      hl.NvimTreeWinSeparator = { link = "PmenuBorder" }
      hl.WinSeparator = { link = "PmenuBorder" }

      hl.NvimTreeGitDirtyIcon = { fg = "#e2c08d" }   -- Желтый (Modified)
      hl.NvimTreeGitNewIcon = { fg = "#81b88b" }     -- Зеленый (Untracked/Added)
      hl.NvimTreeGitDeletedIcon = { fg = "#c74e39" } -- Красный (Deleted)
      hl.NvimTreeGitStagedIcon = { fg = "#81b88b" }  -- Зеленый (Staged)
      hl.NvimTreeGitIgnoredIcon = { fg = "#6a737d" } -- Серый (Ignored)

      -- 1. Полностью убираем визуальную тень (делаем её прозрачной/пустой)
      hl.FloatShadow = { bg = "none", blend = 100 }
      hl.FloatShadowThrough = { bg = "none", blend = 100 }

      hl.NvimTreeFloatBorder = { link = "PmenuBorder" }

      -- Также убедись, что само содержимое окна имеет плотный фон
      -- hl.NvimTreeNormalFloat = { link = "PmenuBorder" }
    end,
  },
  -- Функция config принимает настройки из opts и применяет их
  config = function(_, opts)
    require("tokyonight").setup(opts)
  end,
}
