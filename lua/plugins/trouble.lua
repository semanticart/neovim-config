return {
    {
        'folke/trouble.nvim',
        dependencies = {{'nvim-tree/nvim-web-devicons'}},
        event = "VeryLazy",
        config = function() require('trouble').setup {} end
    }
}
