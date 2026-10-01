return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- Настройки внешнего вида (под твой прозрачный стиль)
    preset = "classic",   -- или "modern" / "helix"
    win = {
      border = "rounded", -- Красивые скругленные края
      padding = { 1, 2 }, -- Внутренние отступы
      wo = {
        winblend = 0,     -- 0 для полной прозрачности (если настроено в теме)
      },
    },
    delay = 1000,
    layout = {
      align = "center", -- Выравнивание текста
    },

  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = true })
      end,
      desc = "All hotkeys",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Группируем наши бинды, чтобы они красиво назывались в меню
    wk.add({
      { "<leader>n", group = "Noice" },
      { "<leader>f", group = "Telescope" },
      { "<leader>c", group = "Code and LSP" },
      { "<leader>w", group = "Windows" },
      { "<leader>b", group = "Buffers and Files" },
    })
  end,
}
