local services = {
  -- Core languages
  "pyright",
  "clangd",
  "gopls",
  "bashls",
  "ts_ls",
  "lua_ls",
  "jsonls",
  "rust_analyzer",

  -- Configuration files & Serialization
  "yamlls",    -- YAML (CI/CD, Kubernetes, compose files)
  "taplo",     -- TOML (Cargo.toml, pyproject.toml, app configs)
  "lemminx",   -- XML
  "neocmake",

  -- Build systems & Linux development
  "mesonlsp",                          -- Meson build definition files
  "autotools_ls",                      -- Makefiles, configure scripts, autoconf
  "dockerls",                          -- Dockerfile
  "docker_compose_language_service",   -- docker-compose.yaml

  -- Web development
  "html",                    -- HTML
  "cssls",                   -- CSS / SCSS / LESS
  "tailwindcss",             -- Tailwind CSS utilities and preview
  "emmet_language_server",   -- Emmet abbreviation expansion

  -- Documentation, Data & Scripting
  "marksman",   -- Markdown notes and cross-file reference linking
  "sqlls",      -- SQL queries and schemas
  "awk_ls",     -- AWK scripts
}

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "b0o/SchemaStore.nvim",     -- Provides JSON/YAML schemas
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

      if server == "rust_analyzer" then
        opts.rustfmt = {
          extraArgs = { "+nightly" },
        }
      end

      if server == "jsonls" then
        opts.settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        }
      end

      if server == "yamlls" then
        opts.settings = {
          yaml = {
            schemaStore = {
              enable = false,
              url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
          },
        }
      end

      if server == "clangd" then
        opts.cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
        }
      end

      if server == "cssls" then
        opts.settings = {
          css = {
            validate = false,
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

    -- vim.lsp.config("cmake", {
    --   cmd = { "cmake-language-server" },
    --   filetypes = { "cmake" },
    --   capabilities = capabilities,
    --   root_markers = { "CMakeLists.txt", "CMakeCache.txt", ".git" },
    -- })
    -- vim.lsp.enable("cmake")
    --
    vim.lsp.config("qmlls", {
      on_attach = on_attach,
      cmd = { "/usr/lib/qt6/bin/qmlls" },
      filetypes = { "qml", "qmljs" },
      capabilities = capabilities,
      root_markers = { ".git", "qmldir", "CMakeLists.txt" },
    })

    vim.lsp.enable("qmlls")

    vim.lsp.config("kdl_lsp", {
      cmd = { "kdl-lsp" },
      filetypes = { "kdl" },
      capabilities = capabilities,
      root_markers = { ".git", "*.kdl" },
    })
    vim.lsp.enable("kdl_lsp")

    --vim.lsp.config("qml-language-server", {
    --  capabilities = capabilities,
    --  cmd = { "qml-language-server" },
    --  filetypes = { "qml" },
    --  root_markers = { { "qmldir", "shell.qml" }, ".git" },
    --})

    --vim.lsp.enable("qml-language-server")
  end,
}
