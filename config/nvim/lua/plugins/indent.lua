return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = "VeryLazy",
  config = function()
    -- 1. Определяем список названий групп цветов
    local highlight = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowOrange",
      "RainbowGreen",
      "RainbowViolet",
      "RainbowCyan",
    }

    -- 2. Регистрируем реальные HEX-цвета для этих групп
    local hooks = require "ibl.hooks"
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
      vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
      vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
      vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
    end)

    -- 3. Запускаем плагин с нашими цветами
    require("ibl").setup({
      indent = {
        char = "│",
        -- tab_char = "│",
        -- Применяем радужную палитру к линиям отступа
        highlight = highlight,
      },
      scope = {
        enabled = false,
      },
      exclude = {
        filetypes = { "help", "alpha", "dashboard", "lazy", "mason" },
      },
    })
  end,
}
