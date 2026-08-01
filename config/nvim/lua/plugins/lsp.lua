local services = {
  "pyright", -- Умный LSP для Python (от Microsoft)
  "clangd",  -- C и C++
  "gopls",   -- Go
  "bashls",
  "ts_ls",   -- JavaScript и TypeScript
  "lua_ls",  -- Lua (для редактирования самого конфига Neovim)
  "jsonls"
}

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",

    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    -- 1. Инициализируем Mason
    require("mason").setup()

    -- 2. Говорим Mason, какие серверы нужно скачать
    require("mason-lspconfig").setup({
      ensure_installed = services,
    })

    vim.diagnostic.config({
      update_in_insert = false,
      float = {
        border = "rounded",
        winhighlight = "FloatBorder:PmenuBorder",
      },
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    for _, server in ipairs(services) do
      -- Базовые опции, которые нужны каждому серверу
      local opts = {
        capabilities = capabilities,
      }

      -- Специфичные настройки: переопределение opts для конкретных серверов
      if server == "lua_ls" then
        opts.settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        }
      end

      -- Инициализация сервера
      vim.lsp.config(server, opts)
      vim.lsp.enable(server)
    end

    local on_attach = function(client, _)
      -- Отключение семантических токенов для конкретного клиента
      client.server_capabilities.semanticTokensProvider = nil
    end

    vim.lsp.config("qmlls", {
      on_attach = on_attach,
      cmd = { "/usr/lib/qt6/bin/qmlls" },
      filetypes = { "qml", "qmljs" },
      capabilities = capabilities,
      root_markers = { ".git", "qmldir", "CMakeLists.txt" },
    })

    vim.lsp.enable("qmlls")
    --vim.lsp.config("qml-language-server", {
    --  capabilities = capabilities,
    --  cmd = { "qml-language-server" },
    --  filetypes = { "qml" },
    --  root_markers = { { "qmldir", "shell.qml" }, ".git" },
    --})

    --vim.lsp.enable("qml-language-server")
  end,
}
