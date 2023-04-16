return {
    "folke/noice.nvim",
    config = function()
        require("noice").setup({popupmenu = {enabled = false}})
    end
}
