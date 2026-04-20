return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- Плагин для красивых иконок файлов
    "catppuccin/nvim"
  },
  config = function()
    -- Пробуем загрузить lualine
    local status_lualine, lualine = pcall(require, "lualine")
    if not status_lualine then return end

    lualine.setup({
      options = {
        --theme = "catppuccin", -- Lualine сам подхватит наши цвета

        -- Используем красивые разделители в стиле Powerline
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },

        -- Делаем один общий статус-бар в самом низу экрана,
        -- даже если открыто несколько окон (сплитов)
        globalstatus = true,
      },
      sections = {
        -- Слева: Режим (NORMAL/INSERT)
        lualine_a = { 'mode' },

        -- Ближе к центру: ветка Git, изменения и ошибки от языкового сервера
        lualine_b = { 'branch', 'diff', 'diagnostics' },

        -- По центру: Имя файла
        lualine_c = { 'filename' },

        -- Справа: Кодировка, ОС и тип файла (C, Go, Bash и т.д. с иконкой)
        lualine_x = { 'encoding', 'fileformat', 'filetype' },

        -- Процент прокрутки
        lualine_y = { 'progress' },

        -- Текущая строка и столбец
        lualine_z = { 'location' }
      },
    })
  end,
}
