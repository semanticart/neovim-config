vim.keymap.set('n', '<CR>', function()
    vim.lsp.codelens.run()

    pcall(function()
        vim.lsp.inlay_hint.enable(0, false)
        vim.lsp.inlay_hint.enable(0, true)
    end)

end, {buffer = 0})

local grep_str = function()
    -- return "(class |def |module |self\\.|::)" .. vim.fn.expand('<cword>') ..
    return "(class |def |module |self\\.)" .. vim.fn.expand('<cword>') .. "\\b"
end

if LSP then
    local live_grep = require('telescope.builtin').live_grep

    LSP.FindDefinitions.rb = function()
        local result =
            vim.system({'rg', '--vimgrep', grep_str()}, {text = true}):wait()

        local results = vim.split(vim.trim(result.stdout), "\n")

        if results then
            if table.getn(results) > 1 then
                live_grep {default_text = grep_str()}
            else
                if results[1] ~= "" then
                    local parts = vim.split(results[1], ":")
                    local file = parts[1]
                    local line = tonumber(parts[2])

                    -- TODO: more-lua way to do this
                    vim.cmd("execute \"edit +" .. line .. " " .. file .. "\"",
                            false)
                end
            end
        end
    end

    LSP.FindReferences.rb = function()
        -- TODO: jump to single reference like above
        live_grep {default_text = vim.fn.expand('<cword>')}
    end
end

local escape_regex = function(pattern)
    return pattern:gsub("'", "\\'"):gsub("%(", "\\("):gsub("%)", "\\)"):gsub(
               "%?", "\\?")
end

local definition_preview = function()
    local tags = vim.fn.taglist(vim.fn.expand('<cword>'))

    -- filter tags to ruby only
    local ruby_tags = {}

    for _, tag in ipairs(tags) do
        if vim.endswith(tag.filename, ".rb") then
            table.insert(ruby_tags, tag)
        end
    end

    if ruby_tags[1] then
        -- remove the leading and trailing slash
        local pattern = ruby_tags[1].cmd:sub(2, -2)

        if pattern and pattern ~= nil then
            local cmd = 'rg --with-filename --no-heading --line-number \'' ..
                            escape_regex(pattern) .. '\' ' ..
                            ruby_tags[1].filename .. " | cut -d ':' -f1-2"

            local matches = vim.split(vim.trim(vim.fn.system(cmd)), "\n")

            LSP.preview_location(matches[1])
        end
    else
        local cmd = "sh -c 'rg -t ruby --no-heading --line-number \"" ..
                        grep_str() .. "\" $(pwd) | cut -d \\':\\' -f1-2'"

        local matches = vim.split(vim.trim(vim.fn.system(cmd)), "\n")

        LSP.preview_location(matches[1])
    end
end

vim.keymap.set("n", "H", definition_preview,
               {buffer = 0, desc = "Definition Preview"})

-- vim.lsp.set_log_level("DEBUG")
-- -- vim.cmd [[ set nonumber ]]
