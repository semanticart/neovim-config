return {
    "folke/flash.nvim",
    ---@type Flash.Config
    opts = {modes = {search = {enabled = false}}},
    keys = {
        {
            "<space>",
            mode = {"n", "x", "o"},
            function()
                require("flash").jump({
                    search = {
                        mode = function(str)
                            if str == "]" or str == "[" or str == "." then
                                return "\\" .. str
                            end

                            if str:match("^[%d]+$") then
                                return str
                            end

                            if str:match("^[%w_]+$") then
                                return "\\<" .. str
                            else
                                return str
                            end
                        end
                    }
                })
            end,
            desc = "Flash"
        }, {
            "<leader><space>",
            mode = {"n", "x", "o"},
            function()
                -- default options: exact mode, multi window, all directions, with a backdrop
                require("flash").jump()
            end,
            desc = "Flash"
        }, {
            "S",
            mode = {"n", "o", "x"},
            function() require("flash").treesitter() end,
            desc = "Flash Treesitter"
        }, {
            "r",
            mode = "o",
            function() require("flash").remote() end,
            desc = "Remote Flash"
        }
    }
}
