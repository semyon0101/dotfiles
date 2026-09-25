return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        -- Existing configurations...
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_format" },
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
            vim.fn.expand("~/.config/kdlfmt.kdl"),
            "--stdin",
          },
        },
        ["clang-format"] = {
          prepend_args = { "-style={BasedOnStyle: LLVM, IndentWidth: 2, TabWidth: 2, UseTab: Never}" },
        },
      },
    })
  end,
}
