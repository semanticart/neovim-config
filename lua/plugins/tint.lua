return {
    {
        'levouh/tint.nvim',
        config = function()
            require("tint").setup({
                bg = false, -- Tint background portions of highlight groups
                amt = -30 -- Darken colors, use a positive value to brighten
            })

            -- Disable when nvim loses focus
            vim.api.nvim_exec([[
  augroup WindowManagement
    autocmd!
    autocmd FocusLost * lua require("tint").disable()
    autocmd FocusGained * lua require("tint").enable()
  augroup END
]], false)
        end
    }
}
