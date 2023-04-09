return {
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            {'neovim/nvim-lspconfig'}, {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-buffer'}, {'hrsh7th/cmp-path'},
            {'hrsh7th/cmp-nvim-lua'}, {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lsp-signature-help', 'onsails/lspkind-nvim'}
        },
        config = function()
            local luasnip = require("luasnip")
            local cmp = require("cmp")
            local lspkind = require('lspkind')

            cmp.setup({
                sources = {
                    {name = 'luasnip'}, {name = 'nvim_lsp'},
                    {name = "nvim_lsp_signature_help"}, {name = 'nvim_lua'},
                    {name = 'path'}, {name = 'buffer', keyword_length = 5}
                },

                snippet = {
                    expand = function(args)
                        require'luasnip'.lsp_expand(args.body)
                    end
                },

                view = {entries = 'native'},

                formatting = {format = lspkind.cmp_format()},

                mapping = {
                    ["<c-k>"] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(1) then
                            luasnip.jump(1)
                        else
                            fallback()
                        end
                    end, {"i", "s"}),

                    ["<c-j>"] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, {"i", "s"}),

                    ['<c-h>'] = cmp.mapping(
                        function(_fallback)
                            if luasnip.choice_active() then
                                luasnip.change_choice(-1)
                            end
                        end, {"i", "s"}),

                    ['<c-l>'] = cmp.mapping(
                        function(_fallback)
                            if luasnip.choice_active() then
                                luasnip.change_choice(1)
                            else
                                if luasnip.expand_or_locally_jumpable() then
                                    luasnip.expand_or_jump()
                                else
                                    cmp.mapping.confirm({select = true})
                                end
                            end
                        end, {"i", "s"}),

                    ['<c-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4),
                                            {'i', 'c'}),
                    ['<c-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4),
                                            {'i', 'c'})
                }
            })
        end
    }
}
