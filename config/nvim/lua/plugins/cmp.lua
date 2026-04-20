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

    local my_keymaps = require("core.keymaps")

    -- Загружаем готовые сниппеты (например, пишешь "for" -> разворачивается в цикл)
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Иконки для меню автодополнения
    local kind_icons = {
      Text = "󰉿",
      Method = "󰆧",
      Function = "󰊕",
      Constructor = "",
      Field = "󰜢",
      Variable = "󰀫",
      Class = "󰠱",
      Interface = "",
      Module = "",
      Property = "󰜢",
      Unit = "󰑭",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "󰈇",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰏿",
      Struct = "󰙅",
      Event = "",
      Operator = "󰆕",
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
      mapping = cmp.mapping.preset.insert(my_keymaps.get_cmp_mappings(cmp)),

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
        {
          name = "nvim_lsp",

          entry_filter = function(entry, _)
            return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
          end
        },                    -- Подсказки от серверов (C, Go, Bash) важнее всего
        { name = "luasnip" }, -- Затем сниппеты
      }, {
        { name = "path" },    -- И пути к файлам
      }, {
        { name = "buffer" },  -- Если ничего нет, предлагаем просто слова из файла
      }),
      window = {
        -- Настройки для списка вариантов
        completion = cmp.config.window.bordered({
          -- Принудительно используем группу Pmenu (плотный фон) вместо прозрачного Normal
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
        }),
        -- Настройки для окна документации (как на твоем скриншоте)
        documentation = cmp.config.window.bordered({
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
        }),
      }
    })
  end,
}
