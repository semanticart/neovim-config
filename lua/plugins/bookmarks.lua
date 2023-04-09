return {
    {
        'MattesGroeger/vim-bookmarks',

        dependencies = {{'tom-anders/telescope-vim-bookmarks.nvim'}},

        config = function()
            vim.g.bookmark_highlight_lines = 1

            vim.api.nvim_exec([[
                highlight BookmarkLine guibg=#0a2a2a
            ]], false)

            require('telescope').load_extension('vim_bookmarks')
        end,

        keys = {
            {'ma', ':Telescope vim_bookmarks all<CR>'},
            {'mDD', ':BookmarkClearAll<CR>'}
        }
    }
}
