return {
    {
        'mileszs/ack.vim',
        config = function()
            vim.g.ackprg = 'ag --hidden --vimgrep'
            vim.keymap.set('n', '<leader>a', ":Ack ")
            vim.keymap.set('n', '<leader>A', ":Ack <cword><CR>")
        end,
        event = "VeryLazy",
        keys = {{'<leader>a', ':Ack '}, {'<leader>A', ":Ack <cword><CR>"}}
    }
}
