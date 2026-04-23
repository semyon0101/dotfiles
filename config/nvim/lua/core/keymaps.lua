vim.g.mapleader = " "

local function escape(str)
  local escape_chars = [[;,."|\]]
  return vim.fn.escape(str, escape_chars)
end

local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]
local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm]]
local ru = [[ёйцукенгшщзхъфывапролджэячсмить]]
local en_full = [[~QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?`qwertyuiop[]asdfghjkl;'zxcvbnm,./]]
local ru_full = [[ËЙЦУКЕНГШЩЗХЪ/ФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,ёйцукенгшщзхъфывапролджэячсмитьбю.]]

-- 1. Настройка встроенного langmap (для d, y, w, f и т.д.)
vim.opt.langmap = vim.fn.join({
  escape(ru_shift) .. ';' .. escape(en_shift),
  escape(ru) .. ';' .. escape(en),
}, ',')

-- 2. Перевод комбинаций Ctrl+ через встроенный nvim_feedkeys
local function map_translated_ctrls()
  local en_list = vim.split(en_full:gsub('%u', ''), '')
  local modes = { 'n', 'o', 'i', 'c', 't', 'v' }
  for _, char in ipairs(en_list) do
    local keycode = '<C-' .. char .. '>'
    local tr_char = vim.fn.tr(char, en_full, ru_full)
    local tr_keycode = '<C-' .. tr_char .. '>'
    if not en_full:find(tr_char, 1, true) then
      local term_keycodes = vim.api.nvim_replace_termcodes(keycode, true, true, true)
      vim.keymap.set(modes, tr_keycode, function()
        vim.api.nvim_feedkeys(term_keycodes, 'm', true)
      end, {desc = "which_key_ignore"})
    end
  end
end
map_translated_ctrls()

-- 3. Функция разбора и перевода сложных комбинаций 
local function translate_keycode(lhs)
  if type(lhs) ~= "string" then return lhs end
  local res, i = "", 1
  while i <= #lhs do
    local c = lhs:sub(i, i)
    if c == "<" then
      local e = lhs:find(">", i)
      if e then
        local inside = lhs:sub(i + 1, e - 1)
        if inside:match("^%a%-") then
          local dash = inside:match("^.*%-()")
          local pref = inside:sub(1, dash - 1)
          local key = inside:sub(dash)
          local tr_key = #key == 1 and vim.fn.tr(key, en_full, ru_full) or key
          res = res .. "<" .. pref .. tr_key .. ">"
        else
          res = res .. "<" .. inside .. ">"
        end
        i = e + 1
      else
        res = res .. vim.fn.tr(c, en_full, ru_full)
        i = i + 1
      end
    else
      res = res .. vim.fn.tr(c, en_full, ru_full)
      i = i + 1
    end
  end
  return res
end

-- 4. Перехват API Neovim для глобальных и локальных маппингов (вкл. плагины)
local disable_modes = { 'i', 'c', 't' }

local original_set_keymap = vim.api.nvim_set_keymap
---@diagnostic disable-next-line: duplicate-set-field
vim.api.nvim_set_keymap = function(mode, lhs, rhs, opts)
  original_set_keymap(mode, lhs, rhs, opts)
  if not vim.tbl_contains(disable_modes, mode) then
    local tr_lhs = translate_keycode(lhs)
    if tr_lhs ~= lhs then
      local tr_opts = vim.tbl_extend("force", {}, opts or {})
      tr_opts.desc = "which_key_ignore"
      original_set_keymap(mode, tr_lhs, rhs, tr_opts)
    end
  end
end

local original_buf_set_keymap = vim.api.nvim_buf_set_keymap
---@diagnostic disable-next-line: duplicate-set-field
vim.api.nvim_buf_set_keymap = function(bufnr, mode, lhs, rhs, opts)
  original_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
  if not vim.tbl_contains(disable_modes, mode) then
    local tr_lhs = translate_keycode(lhs)
    if tr_lhs ~= lhs then
      local tr_opts = vim.tbl_extend("force", {}, opts or {})
      tr_opts.desc = "which_key_ignore"
      original_buf_set_keymap(bufnr, mode, tr_lhs, rhs, tr_opts)
    end
  end
end


vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP hotkeys',
  callback = function(event)
    local ts = require('telescope.builtin')

    vim.keymap.set('n', '<leader>ch', vim.lsp.buf.hover, { buffer = event.buf, desc = "hover" })
    vim.keymap.set('n', '<leader>cd', ts.lsp_definitions, { buffer = event.buf, desc = "definition" })
    vim.keymap.set('n', '<leader>cf', ts.lsp_references, { buffer = event.buf, desc = "references" })
    vim.keymap.set('n', "<leader>ci", ts.lsp_implementations, { buffer = event.buf, desc = "implementations" })
    vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, { buffer = event.buf, desc = "rename" })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = event.buf, desc = "code action" })
    vim.keymap.set("n", "<leader>ce", vim.diagnostic.open_float, { desc = "Open diagnostic" })

    -- Прыжок к следующей ошибке
    vim.keymap.set("n", "<leader>n", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, { desc = "Next error" })

    -- Прыжок к предыдущей ошибке
    vim.keymap.set("n", "<leader>N", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, { desc = "Previous error" })

    -- 3. Открыть список всех проблем в проекте через Telescope
    vim.keymap.set("n", "<leader>cx", ts.diagnostics, { desc = "List of diagnositcs" })
  end,
})

vim.keymap.set({ "n", "v" }, "<leader>cl", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Autoformat code" })

vim.keymap.set("n", "<leader>nh", ":Noice history<CR>", { desc = "Noice history" })

-- don't use buffer
vim.keymap.set("n", "x", '"_x')

vim.keymap.set({ "n", "v" }, "d", '"_d')
vim.keymap.set({ "n", "v" }, "D", '"_D')

vim.keymap.set({ "n", "v" }, "c", '"_c')
vim.keymap.set({ "n", "v" }, "C", '"_C')

vim.keymap.set("v", "p", '"_dP')

-- Вырезание (традиционное d) через leader
vim.keymap.set({ "n", "v" }, "<leader>d", "d", { desc = "Delete and copy to the buf" })
vim.keymap.set({ "n", "v" }, "<leader>D", "D", { desc = "Delete line and copy to the buf" })

-- В keymaps.lua
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "File explorer" })

-- === ТЕЛЕСКОП (ПОИСК) ===
vim.keymap.set('n', '<leader>ff', function()
  require('telescope.builtin').find_files()
end, { desc = "Find file" })

vim.keymap.set('n', '<leader>fg', function()
  require('telescope.builtin').live_grep()
end, { desc = "Grep text" })

vim.keymap.set('n', '<leader>fb', function()
  require('telescope.builtin').buffers()
end, { desc = "Buffers" })

vim.keymap.set('n', '<leader>fh', function()
  require('telescope.builtin').help_tags()
end, { desc = "Help tags" })
-- Windows
-- 1. Навигация между окнами (Ctrl + h/j/k/l вместо Ctrl+w -> h/j/k/l)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to left window" })

-- 2. Создание и закрытие сплитов (через пробел/leader)
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertical)" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window orizontal)" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Split window equal)" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close window" })

vim.keymap.set("n", "<leader>w", "<cmd>bdelete<cr>", { desc = "Close window" })



-- Навигация по вкладкам (буферам)
vim.keymap.set("n", "J", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous tab" })
vim.keymap.set("n", "K", "<cmd>BufferLineCycleNext<cr>", { desc = "Next tab" })

-- Быстрое перемещение вкладок местами
vim.keymap.set("n", "gJ", "<cmd>BufferLineMovePrev<cr>", { desc = "Move tab forward" })
vim.keymap.set("n", "gK", "<cmd>BufferLineMoveNext<cr>", { desc = "Move tab backward" })

vim.keymap.set("n", "<leader>sw", function()
  require("bufdelete").bufdelete(0, true)
end, { desc = "Close tab" })


-- Выделение всего содержимого файла
vim.keymap.set("n", "<leader>va", function()
  -- 1. Сохраняем текущую позицию в jumplist (список прыжков)
  vim.cmd("normal! m'")

  -- 2. gg (в начало) -> V (визуальный режим линий) -> G (в конец)
  vim.cmd("normal! gg0VG)")

  -- 3. Нажимаем 'o', чтобы переместить курсор на верхнюю границу выделения.
  -- Экран прыгнет к началу файла, что обычно удобнее, чем смотреть на пустые строки в конце.
  vim.cmd("normal! o")
end, { desc = "Select all file" })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = "Exit terminal mode" })

-- For cmp binds
local M = {}

-- Эта функция принимает плагин cmp как аргумент и возвращает таблицу с биндами
M.get_cmp_mappings = function(cmp)
  return {
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }
end

-- Важно: если в твоем keymaps.lua в конце нет return, добавь его,
-- чтобы другие файлы могли читать эти функции
return M
