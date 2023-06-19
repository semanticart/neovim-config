return {
    {
        'sbdchd/neoformat',
        enabled = false,
        event = "VeryLazy",
        config = function()
            vim.g.neoformat_only_msg_on_error = 1
            vim.g.neoformat_enabled_scss = {'prettier'}
            vim.g.neoformat_enabled_ruby = {'rubocop'}

            vim.g.neoformat_enabled_typescript = {'prettierd'}
            vim.g.neoformat_enabled_typescriptreact = {'prettierd'}

            local format_group = vim.api.nvim_create_augroup("FormatGroup",
                                                             {clear = true})

            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = {
                    "*.css", "*.erb", "*.html", "*.js", "*.jsx", "*.lua",
                    "*.scss" --  , "*.ts", "*.tsx"
                },
                command = "silent! undojoin | Neoformat",
                group = format_group
            })
        end
    }
}

