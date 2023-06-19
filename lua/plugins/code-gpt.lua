return {
    {
        "dpayne/CodeGPT.nvim",
        event = "VeryLazy",
        dependencies = {'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim'},
        config = function() require("codegpt.config") end
    }
}
