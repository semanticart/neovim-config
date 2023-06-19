vim.lsp.set_log_level("DEBUG")

vim.cmd.source(vim.fn.expand("~/.config/nvim/after/ftplugin/javascript.lua"))

DOCO = function()
    local uri = vim.lsp.util.make_range_params(0).textDocument.uri
    vim.lsp.buf_request(0, "textDocument/documentSymbol",
                        {textDocument = {uri = uri}}, function(err, result)

        local file_path = "/tmp/response.json"
        local file, err = io.open(file_path, "w")

        if not file then
            -- If the file could not be opened, print an error message
            print("Error opening file for writing: " .. err)
        else
            -- Write the content to the file
            file:write((vim.fn.json_encode(result)))

            -- Close the file
            file:close()

            P("LGTM")
        end
    end)
end

GOBO = function()
    local loc = vim.lsp.util.make_range_params(0)
    vim.lsp.buf_request(0, "textDocument/definition", {
        textDocument = {uri = loc.textDocument.uri},
        position = {
            line = loc.range.start.line,
            character = loc.range.start.character
        }
    }, function(err, result)

        local file_path = "/tmp/response.json"
        local file, err = io.open(file_path, "w")

        if not file then
            -- If the file could not be opened, print an error message
            print("Error opening file for writing: " .. err)
        else
            -- Write the content to the file
            file:write((vim.fn.json_encode(result)))

            -- Close the file
            file:close()

            P("LGTM")
        end
    end)
end
