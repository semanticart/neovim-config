local hint_char1_and_then = function(c, and_then_func)
    local hop = require("hop")
    local jump_target = require("hop.jump_target")

    return function()
        local opts = hop.opts
        local generator = jump_target.jump_targets_by_scanning_lines
        hop.hint_with_callback(generator(
                                   jump_target.regex_by_case_searching(c, true,
                                                                       opts)),
                               opts, function(jt)
            hop.move_cursor_to(jt.window, jt.line + 1, jt.column - 1,
                               opts.hint_offset)
            and_then_func()
        end)
    end
end

local feedkeys = function(keys)
    vim.schedule(function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false,
                                                             true), "n", true)
    end)
end

return {
    {
        'phaazon/hop.nvim',

        config = function() require('hop').setup() end,

        keys = function()
            local keys = {
                {
                    '<space>',
                    "<cmd>lua require'hop'.hint_char1({multi_windows = false})<cr>",
                    desc = 'Hop'
                }, {
                    '<leader><space>',
                    "<cmd>lua require'hop'.hint_char1({multi_windows = true})<cr>",
                    desc = 'Hop anywhere'
                }, {
                    '<space>',
                    "<cmd>lua require'hop'.hint_char1({multi_windows = false})<cr>",
                    desc = "Hop",
                    mode = "o"
                }, {
                    '<space>',
                    "<cmd>lua require'hop'.hint_char1({multi_windows = false})<cr>",
                    desc = "Hop",
                    mode = 'v'
                }, {'l', '<cmd>HopChar1CurrentLineAC<cr>', desc = 'Hop right'},
                {'h', '<cmd>HopChar1CurrentLineBC<cr>', desc = 'Hop left'}, {
                    'vo', function()
                        vim.cmd([[:HopLineStart]])
                        feedkeys('o')
                    end
                }, {
                    "vO", function()
                        vim.cmd([[:HopLineStart]])
                        feedkeys('O')
                    end
                }
            }

            local default_text_objects = {
                'w', 'W', 's', 'p', '[', ']', '(', ')', 'b', '>', '<', 't', '{',
                '}', 'B', '"', '\'', '`'
            }

            for _, v in ipairs(default_text_objects) do
                for _, prefix in ipairs({'ci', 'ca'}) do
                    table.insert(keys, {
                        prefix .. 'r' .. v,
                        hint_char1_and_then(v, function()
                            feedkeys(prefix .. v)
                        end)
                    })
                end

                for _, prefix in ipairs({'di', 'da', 'yi', 'ya'}) do
                    table.insert(keys, {
                        prefix .. 'r' .. v, hint_char1_and_then(v, function()
                            vim.api.nvim_feedkeys(vim.api
                                                      .nvim_replace_termcodes(
                                                      prefix .. v, true, false,
                                                      true), "n", true)
                        end)
                    })
                end
            end

            return keys
        end
    }
}
