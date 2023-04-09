return {
    {
        "utilyre/barbecue.nvim",
        version = "*",
        dependencies = {"SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons"},
        config = function() require("barbecue").setup() end
    }
}
