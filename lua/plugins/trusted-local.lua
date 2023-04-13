return {
    {
        'semanticart/trusted-local.nvim',
        lazy = false,
        config = function() require("trusted-local").setup() end
    }
}
