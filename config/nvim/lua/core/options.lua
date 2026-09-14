local opt = vim.opt

--opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")

opt.number = true
opt.relativenumber = true
opt.clipboard = "unnamedplus"
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.termguicolors = true
opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true -- Включает подсветку строки, на которой находится курсор
opt.cmdheight = 0 -- Скрываем командную строку, когда она не используется
opt.report = 99999

opt.termguicolors = true
opt.signcolumn = "yes"

opt.mousescroll = "ver:1,hor:3"

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qml", "qmljs" },
	callback = function()
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
		vim.opt.softtabstop = 4
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.expandtab = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("SetCwdOnStartup", { clear = true }),
	callback = function()
		local filepath = vim.api.nvim_buf_get_name(0)

		if filepath ~= "" and vim.fn.isdirectory(filepath) == 0 then
			if vim.bo.buftype == "" then
				local dir = vim.fn.fnamemodify(filepath, ":p:h")

				if vim.fn.isdirectory(dir) == 1 then
					vim.api.nvim_set_current_dir(dir)
				end
			end
		end
	end,
})
