local TableConcat = function(t1, t2)
    for i = 1, #t2 do t1[#t1 + 1] = t2[i] end
    return t1
end

return {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {'nvim-lua/plenary.nvim'},

        config = function()
            require('telescope').setup {
                extensions = {
                    fzf = {
                        fuzzy = true, -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true, -- override the file sorter
                        case_mode = "smart_case" -- or "ignore_case" or "respect_case"
                        -- the default case_mode is "smart_case"
                    }
                },
                defaults = {
                    mappings = {
                        i = {
                            ["<esc>"] = require('telescope.actions').close, -- close by hitting escape in insert mode. I don't need normal mode for this input.
                            ['<C-u>'] = false -- I want to use c-u to clear the input, but first we have to un-bind it from scrolling up
                        }
                    }
                }
            }

        end,

        keys = function()
            local in_git = (vim.fn.isdirectory('.git') ~= 0)

            local optional = {}

            if in_git then
                local diff_preview = function(cmd, entry, state)
                    local putils = require "telescope.previewers.utils"

                    putils.job_maker(cmd, state.bufnr, {
                        value = entry.value .. "diff",
                        bufname = state.bufname
                    })

                    putils.regex_highlighter(state.bufnr, "diff")
                end

                table.insert(optional, {
                    '<leader>t',
                    ':Telescope git_files<CR>',
                    desc = 'Pick file in repo'
                })

                table.insert(optional, {
                    '<leader>gt',
                    function()
                        local pickers = require("telescope.pickers")
                        local sorters = require('telescope.sorters')
                        local finders = require("telescope.finders")
                        local previewers = require("telescope.previewers")

                        pickers.new {
                            results_title = "Resources",
                            finder = finders.new_oneshot_job({
                                "git", "changed-on-branch"
                            }),
                            sorter = sorters.get_fuzzy_file(),
                            previewer = previewers.new_buffer_previewer {
                                define_preview = function(self, entry, _status)
                                    diff_preview({
                                        'git', '-c', 'core.pager=delta', '-c',
                                        'delta.side-by-side=false', 'diff',
                                        'origin/main', entry.value
                                    }, entry, self.state)
                                end
                            }
                        }:find()
                    end,
                    desc = 'Pick file changed on branch'
                })

                table.insert(optional, {
                    '<leader>gc',
                    '<cmd>Telescope find_files find_command=git-changed-since-commit prompt_prefix=<CR>',
                    desc = 'Pick file changed since commit'
                })
            end

            return TableConcat({
                {'<leader>b', ':Telescope buffers<cr>', desc = 'Pick buffer'},
                {'<leader>t', ':Telescope find_files<cr>', desc = 'Pick file'},
                {'<leader>ff', ':Telescope find_files<cr>', desc = 'Pick file'},
                {
                    '<leader>fl',
                    ":Telescope find_files cwd=<C-R>=fnameescape(expand('%:h')).'/'<cr><CR>",
                    desc = "Pick file in relative directory"
                },
                {'<leader>fg', ':Telescope live_grep<cr>', desc = 'Live grep'},
                {
                    '<leader>fa',
                    ":Telescope live_grep cwd=<C-R>=fnameescape(expand('%:h')).'/'<cr><CR>",
                    desc = "Search in relative directory"
                }, {
                    '<leader>fA',
                    function()
                        require('telescope.builtin').live_grep({
                            cwd = vim.fn.fnameescape(vim.fn.expand('%:h')) ..
                                '/',
                            default_text = vim.fn.expand('<cword>')
                        })
                    end,
                    desc = "Search <cword> in relative directory"
                }, {
                    '<leader>l',
                    ':Telescope live_grep grep_open_files=true<cr>',
                    desc = 'Grep open files'
                },
                {
                    '<leader>T',
                    ':Telescope lsp_workspace_symbols<cr>',
                    desc = 'Pick symbol'
                }, {
                    '<leader>vt',
                    ":Telescope find_files cwd=~/.config/nvim/<CR>",
                    desc = "Pick file in neovim config"
                }, {
                    '<leader>va',
                    ":Telescope live_grep cwd=~/.config/nvim/<CR>",
                    desc = "Search in neovim config"
                },
                {'<leader>vh', ":Telescope help_tags<CR>", desc = "Search Help"},
                {'<leader>gR', '<cmd>Telescope resume<CR>', desc = 'Resume'},
                {
                    '<leader>gr',
                    '<cmd>Telescope lsp_references<CR>',
                    desc = "References"
                }, {
                    '<leader>g/',
                    function()
                        require('telescope.builtin').lsp_dynamic_workspace_symbols(
                            {
                                entry_maker = function(entry)
                                    return {
                                        value = entry,
                                        text = entry.text,
                                        display = entry.text:gsub("%[.-%] ", ""),
                                        ordinal = entry.text,
                                        filename = entry.filename
                                    }
                                end
                            })
                    end,

                    desc = "Workspace symbols"
                }
            }, optional)
        end
    }
}
