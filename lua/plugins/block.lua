return {
    "HampusHauffman/block.nvim",
    event = "VeryLazy",
    config = function()
        require("block").setup({automatic = false})

        vim.cmd [[
        autocmd FileType markdown BlockOff
        ]]
    end
}
