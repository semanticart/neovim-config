return {
    {
        'mileszs/ack.vim',
        config = function()
            vim.g.ackprg = 'ag --vimgrep'
            vim.keymap.set('n', '<leader>a', ":Ack ")
            vim.keymap.set('n', '<leader>A', ":Ack <cword><CR>")
        end,
        keys = {{'<leader>a', ':Ack '}, {'<leader>A', ":Ack <cword><CR>"}}
    }
}
