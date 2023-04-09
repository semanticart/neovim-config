return {
    {
        'github/copilot.vim',
        config = function()
            vim.g.copilot_node_command =
                "/Users/ship/.asdf/installs/nodejs/16.13.1/bin/node"

            vim.cmd(
                [[ autocmd FileType TelescopePrompt let b:copilot_enabled=0 ]])
        end
    }
}
