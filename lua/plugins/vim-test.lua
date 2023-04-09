return {
    {
        "vim-test/vim-test",

        config = function()
            vim.g.test_strategy = "neovim"
            vim.g.test_neovim_start_normal = 1
            vim.g.test_javascript_runner = "jest"

            local TabTermStrategy = function(cmd)
                vim.cmd("tabe term://" .. cmd ..
                            " | nmap <buffer> <c-w>q :bd<CR> | nmap <buffer> <c-w><c-q> :bd<CR>")
            end

            vim.g.test_custom_strategies = {tabterm = TabTermStrategy}
            vim.g.test_strategy = "tabterm"

        end,

        keys = {
            {"<Esc>", "<C-\\><C-n>", mode = 't'},
            {"<leader>r", ":silent update | silent TestNearest<cr>"},
            {"<leader>R", ":silent update | silent TestFile<cr>"},
            {"<leader><leader>", ":silent update | silent TestLast<cr>"},
            {"<leader>v", ":silent update | silent TestVisit<cr>"}
        }
    }
}
