return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    -- Хоткей для открытия/закрытия терминала (Ctrl + \)
    open_mapping = [[<C-CR>]],

    -- Вид терминала. Рекомендую "float", чтобы он не ломал сплиты nvim-tree и буферы
    -- Доступные варианты: 'vertical' | 'horizontal' | 'tab' | 'float'
    direction = "horizontal",

    -- Оболочка (подхватит твой fish, если он стоит по умолчанию в ОС)
    shell = vim.o.shell,

    -- Динамический размер для не-float режимов
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,

    -- Оформление плавающего окна
    float_opts = {
      border = "curved", -- 'single' | 'double' | 'shadow' | 'curved' | 'solid'
      winblend = 0,
    },

    -- Затемнять окна позади терминала
    shade_terminals = true,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
  end
}
