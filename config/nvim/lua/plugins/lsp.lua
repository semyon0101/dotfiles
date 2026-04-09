return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    -- 1. Инициализируем Mason
    require("mason").setup()
    
    -- 2. Говорим Mason, какие серверы нужно скачать
    require("mason-lspconfig").setup({
      ensure_installed = { 
        "clangd", 
        "gopls",  
        "bashls", 
        "lua_ls", -- Для конфигов Neovim
      },
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    
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



  end,
}
