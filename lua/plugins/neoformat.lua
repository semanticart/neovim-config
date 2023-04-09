return {
    {
        'sbdchd/neoformat',
        config = function()
            vim.g.neoformat_only_msg_on_error = 1
            vim.g.neoformat_enabled_scss = {'prettier'}
            vim.g.neoformat_enabled_ruby = {'rubocop'}

            local format_group = vim.api.nvim_create_augroup("FormatGroup",
                                                             {clear = true})

            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = {
                    "*.css", "*.erb", "*.html", "*.js", "*.jsx", "*.lua",
                    "*.rb", "*.scss", "*.ts", "*.tsx"
                },
                command = "silent! Neoformat",
                group = format_group
            })
        end
    }
}

