return {
    {
        'neovim/nvim-lspconfig',

        dependencies = {{'vim-ruby/vim-ruby'}},

        config = function()
            local on_attach = require'lsp_config_settings'.on_attach
            local setup_tailwind = function()
                local capabilities = vim.lsp.protocol.make_client_capabilities()

                capabilities.textDocument.colorProvider = {
                    dynamicRegistration = true
                }
                require("lspconfig").tailwindcss.setup({
                    on_attach = on_attach,
                    capabilities = capabilities
                })
            end
            setup_tailwind()

            require'lspconfig'.tsserver.setup {
                capabilities = vim.lsp.protocol.make_client_capabilities(),
                on_attach = on_attach
            }

            require'lspconfig'.solargraph.setup {
                on_attach = on_attach,
                settings = {solargraph = {diagnostics = true}}
            }
        end
    }
}
