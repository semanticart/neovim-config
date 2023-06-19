return {
    {
        'nvim-lualine/lualine.nvim',

        enabled = not SCREENCAST,

        dependencies = {'nvim-tree/nvim-web-devicons', 'ThePrimeagen/harpoon'},

        event = "VeryLazy",

        config = function()
            local has_alternate_file = function()
                local alts = vim.fn["projectionist#query"]('alternate')

                if table.getn(alts) > 0 then
                    local path = alts[1][2]

                    if vim.fn.filereadable(path) > 0 then
                        return "A"
                    end
                end

                return ""
            end

            local modified = function()
                if vim.bo.modified then
                    return "[+]"
                else
                    return ""
                end
            end

            require('lualine').setup {
                options = {
                    icons_enabled = true,
                    theme = 'auto',
                    component_separators = {left = '', right = ''},
                    section_separators = {left = '', right = ''},
                    disabled_filetypes = {},
                    always_divide_middle = true,
                    globalstatus = false
                },
                sections = {
                    lualine_a = {
                        function()
                            return vim.fn.expand('%'):gsub('(.*)/(.*/.*)', '%2')
                        end, modified
                    },
                    lualine_b = {
                        {
                            function()
                                return require("helpers").memoize(
                                           "alternate_file_value",
                                           has_alternate_file)
                            end,
                            color = {fg = "orange"}
                        }
                    },
                    lualine_c = {
                        function()
                            if require('harpoon.mark').get_current_index() ~=
                                nil then
                                return "🔱" ..
                                           require('harpoon.mark').get_current_index()
                            end

                            return ""

                        end, 'branch', 'diff', 'diagnostics'
                    },
                    lualine_x = {{'filetype', icon_only = true}},
                    lualine_y = {}, -- {'progress'},
                    lualine_z = {'location'}
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {{'filename', color = {fg = "#dddddd"}}},
                    lualine_x = {'location'},
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {},
                extensions = {}
            }
        end
    }
}
