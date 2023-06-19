-- this could be js, jsx, etc. depending on how we are sourced
local extension = vim.fn.expand("%:e")

local grep_str = function()
    return "(const|function|type|interface) " .. vim.fn.expand('<cword>') ..
               "\\b"
end

if LSP then
    LSP.FindDefinitions[extension] = function()
        local cmd = "sh -c 'rg --no-heading --line-number \"" .. grep_str() ..
                        "\" $(pwd) | cut -d \\':\\' -f1-2'"

        local matches = vim.split(vim.trim(vim.fn.system(cmd)), "\n")

        if table.getn(matches) > 1 then
            require('telescope.builtin').live_grep {default_text = grep_str()}
        else
            vim.cmd("edit " .. matches[1])
        end
    end

    LSP.FindReferences[extension] = function()
        require('telescope.builtin').live_grep {
            default_text = vim.fn.expand('<cword>')
        }
    end

    local definition_preview = function()
        local cmd = "sh -c 'rg --no-heading --line-number \"" .. grep_str() ..
                        "\" $(pwd) | cut -d \\':\\' -f1-2'"

        local matches = vim.split(vim.trim(vim.fn.system(cmd)), "\n")

        -- TODO: prefer a match from the current file

        LSP.preview_location(matches[1])
    end

    vim.keymap.set("n", "H", definition_preview, {buffer = 0})
end

local toggle_only = function()
    local line = vim.fn.getline('.')

    local things_to_match = {
        {"describe(", "describe.only(", "describe.skip(", "describe.todo("},
        {" it(", " it.only(", " it.skip(", " it.todo("},
        {" test(", " test.only(", " test.skip(", " test.todo("}
    }

    for _, thing in ipairs(things_to_match) do
        for i = 1, #thing do
            local item1 = thing[i]
            local item2 = thing[i + 1]

            if (item2 == nil) then item2 = thing[1] end

            if (vim.fn.match(line, item1) ~= -1) then
                line = vim.fn.substitute(line, item1, item2, "")
                vim.fn.setline('.', line)
                return
            end
        end
    end
end

vim.keymap.set("n", ",o", toggle_only, {buffer = 0})

vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer = 0})
