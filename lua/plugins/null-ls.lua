return {
    {
        'jose-elias-alvarez/null-ls.nvim',

        dependencies = {
            {'neovim/nvim-lspconfig'}, {'nvim-lua/plenary.nvim'},
            {dir = "~/src/ruby-code-actions.nvim"}
        },

        config = function()
            local null_ls = require("null-ls")
            local ruby_code_actions = require("ruby-code-actions")
            -- register any number of sources simultaneously
            local sources = {
                null_ls.builtins.code_actions.gitsigns,
                null_ls.builtins.diagnostics.luacheck,
                -- null_ls.builtins.formatting.prettier,
                null_ls.builtins.formatting.mix,
                -- null_ls.builtins.formatting.rubocop,
                -- null_ls.builtins.diagnostics.write_good,
                -- null_ls.builtins.diagnostics.rubocop,
                null_ls.builtins.diagnostics.shellcheck,
                -- null_ls.builtins.formatting.standardrb
                -- null_ls.builtins.formatting.rufo -- ruby formatter
                -- null_ls.builtins.formatting.eslint_d,
                -- null_ls.builtins.diagnostics.eslint_d,
                ruby_code_actions.insert_frozen_string_literal,
                ruby_code_actions.autocorrect_with_rubocop
                -- null_ls.builtins.code_actions.eslint_d
            }

            null_ls.setup({
                sources = sources,
                debug = true,
                on_attach = require'lsp_config_settings'.on_attach
            })
        end
    }
}
