vim.keymap.set('n', '<leader>R', function()
    require 'plenary.job':new({
        command = 'tmux',
        args = {'neww', 'vd', vim.fn.expand('%')}
    }):sync()
end, {desc = 'Open in visidata', buffer = 0})
