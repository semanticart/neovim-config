return {
    {
        'mechatroner/rainbow_csv',
        config = function()
            vim.api.nvim_exec([[
              let g:rbql_with_headers = 1
              let g:disable_rainbow_csv_autodetect = 1
            ]], false)
        end
    }
}
