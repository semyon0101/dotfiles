return {
  "windwp/nvim-autopairs",
  -- Загружаем плагин только при переходе в режим вставки
  event = "InsertEnter",
  config = function()
    local autopairs = require("nvim-autopairs")

    autopairs.setup({
      check_ts = true,      -- Использовать Treesitter для проверки (чтобы не закрывать скобки в комментариях и т.д.)
      ts_config = {
        lua = { "string" }, -- Не работать в строках в Lua
        javascript = { "template_string" },
      },
    })

    -- Интеграция с nvim-cmp
    -- Чтобы при выборе функции из списка автодополнения скобки ( ) добавлялись сами
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    local cmp_status, cmp = pcall(require, "cmp")
    if cmp_status then
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  end,
}
