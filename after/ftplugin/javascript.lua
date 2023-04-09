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

    P(vim.fn.match(line, ".only("))

    if (vim.fn.match(line, ".only(") == -1) then
        line = vim.fn.substitute(line, "(", ".only(", "")
    else
        line = vim.fn.substitute(line, ".only(", "(", "")
    end

    vim.fn.setline('.', line)
end

vim.keymap.set("n", ",o", toggle_only, {buffer = 0})

vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer = 0})
