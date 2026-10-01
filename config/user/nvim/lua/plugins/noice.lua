return {
  "folke/noice.nvim",
  --event = "VeryLazy",
  priority = 1000,
  lazy = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("noice").setup({
      commands = {
        history = {
          view = "split", -- Вид, который мы настроили ранее
          opts = { enter = true, format = "details" },
          filter = {
            any = {
              { event = "notify" },
              { error = true },
              { warning = true },
              -- ДОБАВЛЕНО: "echo" в список kind
              { event = "msg_show" },
              { event = "lsp",     kind = "message" },
            },
          },
        },
      },

      views = {
        split = {
          win_options = {
            winblend = 0,
            winhighlight = {
              Normal = "PMenu",
            },
          },
        }
      },

      -- Настройки внешнего вида
      cmdline = {
        -- 'cmdline' - классический вид снизу (прямо над lualine)
        -- 'cmdline_popup' - модное окно по центру экрана
        view = "cmdline",
        format = {
          -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
          -- view: (default is cmdline view)
          -- opts: any options passed to the view
          -- icon_hl_group: optional hl_group for the icon
          -- title: set to anything or empty string to hide
          search_down = { kind = "search", pattern = "^/", icon = "", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = "", lang = "regex" },
        },
      },

      notify = {
        enabled = true,
      },

      lsp = {
        progress = {
          enabled = false,
        },
      },

      presets = {
        bottom_search = true,   -- Поиск (/) будет появляться снизу
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

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("LspReadyNotify", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
          -- Выводим одну строку через стандартный vim.notify (noice ее перехватит и красиво отрисует)
          vim.notify("LSP: " .. client.name .. " is ready", vim.log.levels.INFO, { title = "LSP" })
        end
      end,
    })
  end,
}
