return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter", -- Загружаем плагин только когда переходим в режим вставки (оптимизация)
  dependencies = {
    -- Движок сниппетов (обязателен для работы LSP)
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets", -- Готовая база сниппетов для разных языков

    -- Источники автодополнения
    "hrsh7th/cmp-nvim-lsp", -- Из LSP серверов (функции, переменные)
    "hrsh7th/cmp-buffer",   -- Из текущего текста в файле
    "hrsh7th/cmp-path",     -- Пути к файлам (когда пишешь /home/...)
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Загружаем готовые сниппеты (например, пишешь "for" -> разворачивается в цикл)
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Иконки для меню автодополнения
    local kind_icons = {
      Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "",
      Field = "󰜢", Variable = "󰀫", Class = "󰠱", Interface = "",
      Module = "", Property = "󰜢", Unit = "󰑭", Value = "󰎠",
      Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
      File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
      Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕",
      TypeParameter = "󰅲",
    }

    cmp.setup({
      snippet = {
        -- Говорим cmp использовать LuaSnip для развертывания сниппетов
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      -- Горячие клавиши для управления меню
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- Предыдущая подсказка (Ctrl+k)
        ["<C-j>"] = cmp.mapping.select_next_item(), -- Следующая подсказка (Ctrl+j)
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),    -- Пролистать документацию вверх
        ["<C-f>"] = cmp.mapping.scroll_docs(4),     -- Пролистать документацию вниз
        ["<C-Space>"] = cmp.mapping.complete(),     -- Вызвать меню принудительно
        ["<C-e>"] = cmp.mapping.abort(),            -- Закрыть меню
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Подтвердить выбор (Enter)
      }),
      -- Настройка внешнего вида меню
      formatting = {
        format = function(entry, vim_item)
          -- Добавляем иконки
          vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
          -- Показываем, откуда пришла подсказка
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
          })[entry.source.name]
          return vim_item
        end,
      },
      -- Порядок источников (кто важнее)
      sources = cmp.config.sources({
        { name = "nvim_lsp" }, -- Подсказки от серверов (C, Go, Bash) важнее всего
        { name = "luasnip" },  -- Затем сниппеты
      }, {
        { name = "path" },     -- И пути к файлам
      }, {
        { name = "buffer" },   -- Если ничего нет, предлагаем просто слова из файла
      }
    ),
    })
  end,
}
