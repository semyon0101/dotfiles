return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        -- Existing configurations...
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        kdl = { "kdlfmt" },

        -- Additions for new domains:
        c = { "clang-format" },
        cpp = { "clang-format" },
        go = { "gofmt" },
        rust = { "rustfmt" },
        json = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        cmake = { "cmakefmt" },

      },
      formatters = {
        kdlfmt = {
          command = "kdlfmt",
          args = {
            "format",
            "--config",
            "/home/semyon/.config/kdlfmt.kdl",
            "--stdin",
          },
        },
        rustfmt = {
          args = { "+nightly", "--emit", "stdout" },
        },
      },
    })
  end,
}
