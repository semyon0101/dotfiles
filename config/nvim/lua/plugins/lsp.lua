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
      ensure_installed = {
        "pyright", -- Умный LSP для Python (от Microsoft)
        "clangd",  -- C и C++
        "gopls",   -- Go
        "ts_ls",   -- JavaScript и TypeScript
        "lua_ls",  -- Lua (для редактирования самого конфига Neovim)
      },
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    vim.lsp.config("pyright", { capabilities = capabilities })
    vim.lsp.enable("pyright")

    vim.lsp.config("clangd", { capabilities = capabilities })
    vim.lsp.enable("clangd")

    vim.lsp.config("gopls", { capabilities = capabilities })
    vim.lsp.enable("gopls")

    vim.lsp.config("bashls", { capabilities = capabilities })
    vim.lsp.enable("bashls")

    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
        },
      },
    })
    vim.lsp.enable("lua_ls")
    vim.diagnostic.config({
      update_in_insert = false,
      float = {
        border = "rounded",
        winhighlight = "FloatBorder:PmenuBorder",
      },
    })
  end,
}
