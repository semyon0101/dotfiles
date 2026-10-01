return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
        -- Установка нужных парсеров
        local ts = require("nvim-treesitter")
        ts.setup({
            -- базовые опции ветки main (если нужны)
        })

        -- Автоустановка парсеров в ветке main
        local ensure_installed = { "c", "go", "bash", "lua", "vim", "markdown" }

        for _, parser in ipairs(ensure_installed) do
            if not vim.treesitter.language.add(parser) then
                vim.cmd("TSInstall " .. parser)
            end
        end
    end,
}
