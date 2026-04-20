return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "famiu/bufdelete.nvim"
  },
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",
        numbers = "none",
        close_command = "Bdelete! %d",
        right_mouse_command = "Bdelete! %d",
        left_mouse_command = "buffer %d",
        indicator = {
          style = "none", -- Скрываем левую полоску, скошенные края сами выделяют вкладку
        },
        buffer_close_icon = '󰅖',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "  File explorer",
            text_align = "center",
            separator = true,
            highlight = "NvimTreeTabHighlight",
          }
        },
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "slant", -- Стильные скошенные вкладки
        always_show_bufferline = true,
      },
      highlights = {
        -- Заливка пустого пространства и области над Explorer (светлее)
        fill = { bg = "#1a1b26" },

        -- Неактивные вкладки (светлый серый фон)
        background = { fg = "#787c99", bg = "#24283b" },
        buffer_visible = { fg = "#787c99", bg = "#24283b" },

        -- Активная вкладка (еще светлее, чтобы выделяться)
        buffer_selected = { fg = "#7aa2f7", bg = "#3b4261", bold = true, italic = false },

        -- Цвета скошенных разделителей
        separator = { fg = "#1a1b26", bg = "#24283b" },
        separator_visible = { fg = "#1a1b26", bg = "#24283b" },
        separator_selected = { fg = "#1a1b26", bg = "#3b4261" },
        offset_separator = { link = "PmenuBorder" },

        -- Иконки закрытия
        close_button = { fg = "#787c99", bg = "#24283b" },
        close_button_visible = { fg = "#787c99", bg = "#24283b" },
        close_button_selected = { fg = "#f7768e", bg = "#3b4261" },

        -- Индикатор несохраненного файла
        modified = { fg = "#e0af68", bg = "#24283b" },
        modified_visible = { fg = "#e0af68", bg = "#24283b" },
        modified_selected = { fg = "#e0af68", bg = "#3b4261" },

        -- Ошибки (Красный)
        error = { fg = "#f7768e", bg = "#24283b" },
        error_visible = { fg = "#f7768e", bg = "#24283b" },
        error_selected = { fg = "#f7768e", bg = "#3b4261", bold = true },
        error_diagnostic = { fg = "#f7768e", bg = "#24283b" },
        error_diagnostic_visible = { fg = "#f7768e", bg = "#24283b" },
        error_diagnostic_selected = { fg = "#f7768e", bg = "#3b4261" },

        -- Предупреждения (Желтый)
        warning = { fg = "#e0af68", bg = "#24283b" },
        warning_visible = { fg = "#e0af68", bg = "#24283b" },
        warning_selected = { fg = "#e0af68", bg = "#3b4261", bold = true },
        warning_diagnostic = { fg = "#e0af68", bg = "#24283b" },
        warning_diagnostic_visible = { fg = "#e0af68", bg = "#24283b" },
        warning_diagnostic_selected = { fg = "#e0af68", bg = "#3b4261" },

        -- Информация (Синий)
        info = { fg = "#0db9d7", bg = "#24283b" },
        info_visible = { fg = "#0db9d7", bg = "#24283b" },
        info_selected = { fg = "#0db9d7", bg = "#3b4261", bold = true },
        info_diagnostic = { fg = "#0db9d7", bg = "#24283b" },
        info_diagnostic_visible = { fg = "#0db9d7", bg = "#24283b" },
        info_diagnostic_selected = { fg = "#0db9d7", bg = "#3b4261" },

        -- Подсказки (Бирюзовый)
        hint = { fg = "#1abc9c", bg = "#24283b" },
        hint_visible = { fg = "#1abc9c", bg = "#24283b" },
        hint_selected = { fg = "#1abc9c", bg = "#3b4261", bold = true },
        hint_diagnostic = { fg = "#1abc9c", bg = "#24283b" },
        hint_diagnostic_visible = { fg = "#1abc9c", bg = "#24283b" },
        hint_diagnostic_selected = { fg = "#1abc9c", bg = "#3b4261" },      }
    })
    -- Задаем базовый цвет при запуске (неактивный)
    vim.api.nvim_set_hl(0, "NvimTreeTabHighlight", { bg = "#1a1b26", fg = "#787c99", bold = false })

    -- Создаем слушатель событий (добавили BufEnter и FileType для надежности)
    vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave", "BufEnter", "FileType" }, {
      callback = function()
        -- vim.schedule откладывает выполнение на один кадр,
        -- чтобы NvimTree успел прогрузить свой filetype
        vim.schedule(function()
          -- Проверяем, существует ли вообще буфер (защита от ошибок)
          if not vim.api.nvim_buf_is_valid(0) then return end

          if vim.bo.filetype == "NvimTree" then
            -- Активное окно
            vim.api.nvim_set_hl(0, "NvimTreeTabHighlight", { bg = "#3b4261", fg = "#7aa2f7", bold = true })
          else
            -- Неактивное окно
            vim.api.nvim_set_hl(0, "NvimTreeTabHighlight", { bg = "#1a1b26", fg = "#787c99", bold = false })
          end
        end)
      end,
    })
  end,
}
