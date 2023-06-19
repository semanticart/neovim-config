vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer = 0})
vim.lsp.set_log_level("INFO")

local default_get_input = function(_, req, _, _)
    local input = vim.fn.input(req.title .. ": ", req.defaultValue or "")

    return {input = input, params = req.params}
end

vim.lsp.handlers["$/prefab.getInput"] = default_get_input

vim.lsp.start {
    name = "LSP From Scratch",
    cmd = {
        "npx", "ts-node",
        vim.fn.expand("~/src/lsp-from-scratch/server/src/server.ts")
    },
    capabilities = vim.lsp.protocol.make_client_capabilities()
}

vim.api.nvim_buf_create_user_command(0, "MakeMoreExciting", function(opts)
    local uri = vim.lsp.util.make_range_params(0).textDocument.uri
    local start_line, end_line = opts.line1, opts.line2
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

    local last_line = lines[#lines]

    local range = {
        start = {line = start_line - 1, character = 0},
        ['end'] = {line = end_line - 1, character = string.len(last_line)}
    }

    local arguments = {uri, table.concat(lines, "\n"), range}

    vim.lsp.buf.execute_command({
        command = "lsp-from-scratch/makeMoreExciting",
        arguments = arguments
    })

end, {range = true})

-- vim.lsp.start {
--     name = "CLI LSP",
--     cmd = {
--         'node', '/Users/ship/src/prefab/prefab/bin/run.js', 'language-server',
--         '--stdio'
--     },
--     capabilities = vim.lsp.protocol.make_client_capabilities()
-- }

