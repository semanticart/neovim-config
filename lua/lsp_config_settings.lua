LSP.FindDefinitions = {}
LSP.FindReferences = {}
LSP.Hover = {}

LSP.preview_location_here = function()
    return vim.api.nvim_buf_get_name(0) .. ":" ..
               vim.api.nvim_win_get_cursor(0)[1]
end

LSP.preview_location = function(location_string)
    if location_string and location_string ~= "" then
        local parts = vim.split(location_string, ":")

        local file = parts[1]
        local line = parts[2]

        if line == "" or line == nil then line = 1 end

        line = tonumber(line) - 1

        local range = {}

        range['start'] = {character = 0, line = line}
        range['end'] = {character = 0, line = line + 99999999}

        local location = {range = range, uri = vim.uri_from_fname(file)}

        vim.lsp.util.preview_location(location, {border = "rounded"})
    end
end

local find_definition = function(extension)
    if LSP.FindDefinitions[extension] then
        LSP.FindDefinitions[extension]()
    else
        print("No definitions found")
    end
end

local find_references = function(extension)
    if LSP.FindReferences[extension] then
        LSP.FindReferences[extension]()
    else
        print("No references found")
    end
end

local hover = function(extension)
    if LSP.Hover[extension] then
        LSP.Hover[extension]()
    else
        print("Hover not implemented")
    end
end

local goto_in_split_maybe = function(fn, buffer_extension, split_cmd)
    local util = vim.lsp.util
    local api = vim.api

    local handler = function(_, result, _)
        if result == nil or vim.tbl_isempty(result) then
            fn(buffer_extension)
            return nil
        end

        if split_cmd then vim.cmd(split_cmd) end

        if vim.tbl_islist(result) then
            util.jump_to_location(result[1])

            if #result > 1 then
                util.set_qflist(util.locations_to_items(result))
                api.nvim_command("copen")
                api.nvim_command("wincmd p")
            end
        else
            util.jump_to_location(result)
        end
    end

    return handler
end

local lsp_goto_definition = function(buffer_extension, split_cmd)
    return goto_in_split_maybe(find_definition, buffer_extension, split_cmd)
end

local lsp_goto_reference = function(buffer_extension, split_cmd)
    return goto_in_split_maybe(find_references, buffer_extension, split_cmd)
end

local reference_fun = function(client, buffer_extension)
    -- solargraph doesn't behave as I would hope here
    if client.server_capabilities.find_references and client.name ~=
        "solargraph" then
        vim.lsp.handlers["textDocument/references"] = lsp_goto_reference(
                                                          buffer_extension)
        return vim.lsp.buf.references
    else
        return function() find_references(buffer_extension) end
    end
end

local hover_fun = function(client, buffer_extension)
    return function() hover(buffer_extension) end
end

local definition_fun = function(client, buffer_extension)
    if client.server_capabilities.goto_definition then
        vim.lsp.handlers["textDocument/definition"] =
            lsp_goto_definition(buffer_extension)
        return '<Cmd>lua vim.lsp.buf.definition("' .. buffer_extension ..
                   '")<CR>'
    else
        return function() find_definition(buffer_extension) end
    end
end

local split_definition_fun = function(client, buffer_extension)
    if client.server_capabilities.goto_definition then
        return function()
            vim.lsp.buf_request(0, 'textDocument/definition',
                                vim.lsp.util.make_position_params(),
                                lsp_goto_definition(buffer_extension, "split"))
        end
    else
        return function() find_definition(buffer_extension) end
    end
end

local on_attach = function(client, bufnr)
    local buffer_extension = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ":e")

    local buf_set_option = function(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    if client.supports_method('textDocument/completion') then
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
    end

    if client.server_capabilities.colorProvider then
        -- Attach document colour support
        require("document-color").buf_attach(bufnr)
    end

    -- Set autocommands conditional on server_capabilities
    if client.server_capabilities.document_highlight then
        vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
    end

    if not client.supports_method("textDocument/formatting") then
        vim.cmd([[ set formatexpr= ]])
    end

    local keys = {
        {'i', '<c-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>'}, {
            'n', '<c-g><c-d>', split_definition_fun(client, buffer_extension),
            {desc = "Go to Definition in split", buffer = 0}
        }, {
            'n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>',
            {desc = "Code Actions", buffer = 0}
        }, {
            'n', 'gd', definition_fun(client, buffer_extension),
            {desc = "Go to Definition", buffer = 0}
        }, {
            'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>',
            {desc = "Go to Declaration", buffer = 0}
        }, {
            'n', 'gI', '<cmd>lua vim.lsp.buf.implementation()<CR>',
            {desc = "Go to Implementation", buffer = 0}
        }, {
            'n', 'gl', '<cmd>lua vim.diagnostic.setloclist()<CR>',
            {desc = "Location List", buffer = 0}
        }, {
            'n', 'gr', reference_fun(client, buffer_extension),
            {desc = "Go to Reference", buffer = 0}
        }, {'n', 'K', hover_fun(client, buffer_extension), desc = "Hover info"},
        {'n', 'mv', '<Cmd>lua vim.lsp.buf.rename()<CR>', desc = "Rename"}, {
            'n', '<leader>ed', '<cmd>lua vim.diagnostic.open_float()<CR>',
            {desc = "Diagnostics: Float", buffer = 0}
        }, {
            'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>',
            {desc = "Diagnostic: Prev", buffer = 0}
        }, {
            'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>',
            {desc = "Diagnostic: Next", buffer = 0}
        }
    }

    for _, v in ipairs(keys) do vim.keymap.set(unpack(v)) end
end

return {on_attach = on_attach}
