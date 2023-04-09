return {
    {
        -- saves to $HOME/.local/share/nvim/harpoon.json
        "ThePrimeagen/harpoon",

        dependencies = {{'nvim-lua/plenary.nvim'}},

        config = function()
            require("harpoon").setup({
                menu = {width = 100},
                global_settings = {mark_branch = true}
            })
        end,

        keys = function()
            local harpoon_maybe_already_open = function(number)
                return function()
                    -- get the mark
                    local mark =
                        require('harpoon').get_mark_config().marks[number]

                    if mark then
                        require("helpers").focus_file_or_callback(mark.filename,
                                                                  function()
                            -- open it (with harpoon so we get the correct positioning)
                            require("harpoon.ui").nav_file(number)
                        end)
                    else
                        print("No harpoon for " .. number)
                    end
                end
            end

            return {

                {'<a-1>', harpoon_maybe_already_open(1)},
                {'<a-2>', harpoon_maybe_already_open(2)},
                {'<a-3>', harpoon_maybe_already_open(3)},
                {'<a-4>', harpoon_maybe_already_open(4)},
                {'<a-5>', harpoon_maybe_already_open(5)},
                {'<a-j>', '<cmd>lua require("harpoon.ui").nav_next()<CR>'},
                {'<a-k>', '<cmd>lua require("harpoon.ui").nav_prev()<CR>'},
                {
                    '<a-0>',
                    '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>'
                },
                {
                    '<a-`>',
                    '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>'
                },
                {
                    '<a-9>',
                    '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>'
                }, {
                    '<a-\\>', function()
                        require("harpoon.mark").add_file()
                        vim.notify("Harpooned file.")
                    end
                }
            }
        end
    }
}
