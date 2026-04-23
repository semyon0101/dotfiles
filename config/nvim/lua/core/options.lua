local opt = vim.opt

--opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")

opt.number = true
opt.relativenumber = true
opt.clipboard = "unnamedplus"
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.termguicolors = true
opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true -- Включает подсветку строки, на которой находится курсор
opt.cmdheight = 0 -- Скрываем командную строку, когда она не используется
opt.report = 99999

opt.termguicolors = true
opt.signcolumn = "yes"
