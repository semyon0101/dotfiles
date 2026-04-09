vim.g.mapleader = " "

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP горячие клавиши',
  callback = function(event)
    local opts = {buffer = event.buf}

    vim.keymap.set('n', '<leader>ck', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>cd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<leader>cf', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  end,
})



vim.keymap.set("n", "<leader>nh", ":Noice history<CR>", { desc = "История уведомлений" })


