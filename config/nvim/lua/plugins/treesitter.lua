return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- Явно указываем проверенную ветку!
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "c", "go", "bash", "lua", "vim", "markdown" },

      -- === ДОБАВЛЕННЫЕ ОБЯЗАТЕЛЬНЫЕ ПОЛЯ ===
      sync_install = false, -- Устанавливать парсеры синхронно (блокируя UI)? Обычно false
      auto_install = true, -- Автоматически устанавливать парсер, если открыт файл неизвестного типа
      ignore_install = {},  -- Список парсеров, которые НЕ нужно устанавливать
      modules = {},         -- Пустая таблица для дополнительных модулей

      highlight = {
        enable = true,
      },
    })
  end,
}
