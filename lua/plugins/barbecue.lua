return {
    {
        "utilyre/barbecue.nvim",
        enabled = not SCREENCAST,
        version = "*",
        dependencies = {"SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons"},
        event = "VeryLazy",
        config = function() require("barbecue").setup() end
    }
}
