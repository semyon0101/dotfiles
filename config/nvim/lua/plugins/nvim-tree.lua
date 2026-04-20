return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Функция для кастомных хоткеев внутри дерева
    local function on_attach(bufnr)
      local api = require("nvim-tree.api")

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- Загружаем стандартные бинды
      -- api.map.on_attach.default(bufnr)

      vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "c", api.node.navigate.parent_close, opts("Close Directory"))
      vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
      vim.keymap.set("n", "h", api.node.open.horizontal, opts("Open: Horizontal Split"))
      vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
      vim.keymap.set("n", "a", api.fs.create, opts("Create"))
      vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
      vim.keymap.set("n", "i", api.node.show_info_popup, opts("Show info"))

      -- НАСТРОЙКА: Space для открытия файлов и папок
      vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
    end

    require("nvim-tree").setup({
      on_attach = on_attach, -- Подключаем наши бинды
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
      },
      renderer = {
        highlight_git = "all",
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
