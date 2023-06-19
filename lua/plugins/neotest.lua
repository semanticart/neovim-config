return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-vim-test", "nvim-neotest/neotest-plenary",
            'haydenmeade/neotest-jest', 'marilari88/neotest-vitest'

        },
        event = "VeryLazy",
        config = function()
            require("neotest").setup({
                log_level = 1,
                output = {enabled = true, open_on_run = "short"},

                adapters = {
                    require("neotest-plenary"),
                    require("neotest-vim-test")(
                        {ignore_file_types = {"vim", "lua"}}),

                    require('neotest-jest')({jestCommand = "npm test --"}),
                    require('neotest-vitest')({command = "npm test --"})
                },
                diagnostic = {enabled = true}
            })
        end
    }
}
