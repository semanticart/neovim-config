return {
    {
        'folke/todo-comments.nvim',
        event = "VeryLazy",
        config = function()
            require("todo-comments").setup {
                keywords = {FLAG = {icon = "⚐ ", color = "hint"}}
            }
        end
    }
}
