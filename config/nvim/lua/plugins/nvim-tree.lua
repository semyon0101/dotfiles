return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local my_keymaps = require("core.keymaps")

    require("nvim-tree").setup({
      on_attach = my_keymaps.nvim_tree_on_attach, -- Подключаем наши бинды
      view = {
        width = 30,
        side = "left",
      },
      actions = {
        file_popup = {
          open_win_config = {
            border = "rounded", -- Вместо "shadow"
          },
        },
        change_dir = {
          enable = true,
          global = true,
          restrict_above_cwd = false,
        },
      },
      sync_root_with_cwd = true,
      -- Учитывать cwd текущего буфера (полезно при работе с несколькими проектами)
      respect_buf_cwd = true,

      update_focused_file = {
        enable = true,
        -- Автоматически менять корень nvim-tree, если ты открыл файл (например через LSP goto definition),
        -- который находится за пределами текущего корня
        -- update_root = true,
      },
      renderer = {
        highlight_git = "none",
        indent_markers = { enable = true },
        icons = {
          git_placement = "after", -- В VS Code значки Git стоят ПОСЛЕ имени файла
          diagnostics_placement = "right_align",
          glyphs = {
            git = {
              unstaged = "M", -- Modified
              staged = "A",   -- Added/Staged
              unmerged = "!",
              renamed = "R",
              untracked = "U", -- Untracked (самый понятный символ)
              deleted = "D",   -- Deleted
              ignored = "◌",
            },
          },
        },
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true, -- Показывать статус даже на свернутых папках
        show_on_open_dirs = true,
        debounce_delay = 50,
        icons = {
          hint = "󰌵",
          info = "",
          warning = "",
          error = "",
        },
      },
    })
  end,
}
