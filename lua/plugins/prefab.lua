return {
    {
        "prefab-cloud/prefab.nvim",
        enabled = false,
        dir = "~/src/prefab/prefab.nvim",
        config = function()
            local on_attach = require'lsp_config_settings'.on_attach

            -- vim.lsp.set_log_level("INFO")

            require("prefab").setup({
                on_attach = on_attach,
                cmd = {
                    "prefab-ls", "--stdio"
                    -- "npx", "tsx",
                    -- "/Users/ship/src/prefab/lsp/lsp/server/src/server.ts",
                    -- "--stdio"
                },
                opt_in = {extractString = true},
                alpha = true
            })
        end
    }
}
