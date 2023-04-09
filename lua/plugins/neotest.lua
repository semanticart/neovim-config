return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim", "nvim-neotest/neotest-vim-test",
            "nvim-neotest/neotest-plenary"
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-plenary"),
                    require("neotest-vim-test")(
                        {ignore_file_types = {"vim", "lua"}})
                },
                diagnostic = {enabled = true}
            })
        end
    }
}
