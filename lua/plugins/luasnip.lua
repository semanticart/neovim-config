return {
    {
        'L3MON4D3/LuaSnip',
        event = "VeryLazy",
        config = function()
            local ls = require 'luasnip'
            ls.filetype_extend("ruby", {"rails"})
            require 'snippets'

            ls.config.set_config {
                -- This tells LuaSnip to remember to keep around the last snippet.
                -- You can jump back into it even if you move outside of the selection
                history = true,

                -- This one is cool cause if you have dynamic snippets, it updates as you type!
                updateevents = "TextChanged,TextChangedI",

                -- Autosnippets:
                enable_autosnippets = false
            }

            -- set this here instead of in the snippets. We reload snippets
            -- dynamically and executing this multiple times causes snippets to
            -- duplicate.
            ls.filetype_extend("javascriptreact", {"javascript"})
            ls.filetype_extend("typescript", {"javascript"})
            ls.filetype_extend("typescriptreact", {"javascript"})
        end
    }
}
