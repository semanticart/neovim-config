local grep_str = function()
    return "(class |def |module |self\\.|::)" .. vim.fn.expand('<cword>') ..
               "\\b"
end

local Job = require('plenary.job')
local live_grep = require('telescope.builtin').live_grep

if LSP then
    LSP.FindDefinitions.rb = function()
        -- NOTE: do not refactor this into the `on_exit` below. It causes the UI to hang (even if wrapped in a defer)
        local results

        Job:new({
            command = 'ag', -- not sure why rg isn't working correctly here
            args = {grep_str()},
            on_exit = function(j, return_val)
                if return_val > 0 then
                    vim.notify(vim.inspect(j), "error")
                end
                results = j:result()
            end
        }):sync()

        if results then
            if table.getn(results) > 1 then
                live_grep {default_text = grep_str()}
            else
                local parts = vim.split(results[1], ":")
                local file = parts[1]
                local line = tonumber(parts[2])

                -- TODO: more-lua way to do this
                vim.cmd("execute \"edit +" .. line .. " " .. file .. "\"", false)
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

vim.keymap.set('n', '<CR>', vim.lsp.buf.code_action, {buffer = 0})
