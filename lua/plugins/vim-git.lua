return {
    {
        'tpope/vim-git',
        dependencies = {{'tpope/vim-fugitive'}, {'tpope/vim-rhubarb'}},
        config = function()
            vim.opt.diffopt:append('vertical')
            vim.api.nvim_exec([[
       cabbrev GVsplit Gvsplit
       cabbrev GSplit Gsplit
        autocmd BufNewFile,BufRead COMMIT_EDITMSG setlocal spell complete+=kspell
        " make neovim-remote successfully know when our commit message is done, etc.
        autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
       function! Gamend()
         :Gwrite
          :Git commit --amend --no-edit
       endfunction
        command! Gamend call Gamend()
        command! Greword :Git commit --amend
     ]], false)
        end,

        keys = {
            {'<leader>gs', ':Git <bar> wincmd T<CR>'},
            {'<leader>gb', ':Git blame<CR>'}
        }
    }
}
