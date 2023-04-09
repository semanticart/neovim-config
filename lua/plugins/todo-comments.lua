return {
    {
        'folke/todo-comments.nvim',
        config = function()
            require("todo-comments").setup {
                keywords = {FLAG = {icon = "⚐ ", color = "hint"}}
            }
        end
    }
}
