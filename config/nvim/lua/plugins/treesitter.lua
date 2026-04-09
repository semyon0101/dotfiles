return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- Явно указываем проверенную ветку!
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "c", "go", "bash", "lua", "vim", "markdown" },
      highlight = { 
        enable = true, 
      },
    })
  end,
}
