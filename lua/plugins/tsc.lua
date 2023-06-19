return {
    {
        'dmmulroy/tsc.nvim',
        event = "VeryLazy",
        config = function()
            require('tsc').setup({enable_progress_notifications = false})
        end
    }
}
