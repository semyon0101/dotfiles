return {
  "folke/noice.nvim",
  --event = "VeryLazy",
  lazy = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("noice").setup({
      -- Настройки внешнего вида
      cmdline = {
        -- 'cmdline' - классический вид снизу (прямо над lualine)
        -- 'cmdline_popup' - модное окно по центру экрана
        view = "cmdline",
      },
      notify = {
        enabled = true,
      },

      presets = {
        bottom_search = true, -- Поиск (/) будет появляться снизу
        command_palette = true, -- Командная строка (:) будет стилизована под палитру
        --long_message_to_split = true, -- Длинные сообщения будут открываться в отдельном окне
        inc_rename = false, 
        lsp_doc_border = true, -- Добавит красивые рамки для документации LSP (когда жмешь K)
      },
      -- Маршрутизация: убираем лишний спам о том, что файл сохранен
     routes = {
        -- Твой старый маршрут про 'written' (сохранение файла)
        {
          filter = { event = "msg_show", kind = "", find = "written" },
          opts = { skip = true },
        },
      },
    })
  end
}
