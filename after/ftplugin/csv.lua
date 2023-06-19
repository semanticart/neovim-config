vim.keymap.set('n', '<leader>R', function()
    require 'plenary.job':new({
        command = 'tmux',
        args = {'neww', 'vd', vim.fn.expand('%')}
    }):sync()
end, {desc = 'Open in visidata', buffer = 0})

local on_attach = require'lsp_config_settings'.on_attach
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.start {
    name = "bash-ls",
    cmd = {"sh", "/Users/ship/src/lsp/language-server-in-bash-3.sh"},
    capabilities = capabilities,
    on_attach = on_attach,
    trace = "verbose",
    on_error = function(err)
        print("ERROR: " .. vim.inspect(err) .. " starting bash-ls")
    end
}
