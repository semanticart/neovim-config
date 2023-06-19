return {
    {
        'mhartington/formatter.nvim',
        -- enabled = false,

        config = function()
            -- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
            require("formatter").setup {
                logging = true,
                log_level = vim.log.levels.ERROR,
                filetype = {
                    html = {
                        require("formatter.filetypes.html").prettier("html")
                    },
                    typescriptreact = {
                        require("formatter.filetypes.typescriptreact").prettierd
                    },
                    typescript = {
                        require("formatter.filetypes.typescript").prettierd
                    },
                    json = {require("formatter.filetypes.json").prettier},

                    javascript = {
                        require("formatter.filetypes.javascript").prettierd
                    },
                    ruby = {require("formatter.filetypes.ruby").rubocop},
                    lua = {require("formatter.filetypes.lua").luaformat},
                    sh = {require("formatter.filetypes.sh").shfmt},
                    markdown = {
                        require("formatter.filetypes.markdown").prettier
                    }
                }
            }

            vim.cmd [[
            augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost * FormatWrite
augroup END
]]
        end
    }
}
