return {
    {
        'lewis6991/gitsigns.nvim',
        enabled = not SCREENCAST,
        event = "VeryLazy",
        config = function() require('gitsigns').setup() end
    }
}
