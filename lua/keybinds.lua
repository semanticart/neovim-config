-- saving
local update = function()
    vim.api.nvim_input("<esc>")
    vim.cmd([[update]], false)

    SILENTLY(require('luasnip').unlink_current)
end

vim.keymap.set('n', '<c-s>', update)
vim.keymap.set('i', '<c-s>', update)

-- easier jumps/marks
vim.keymap.set('n', "'", "`")
vim.keymap.set('n', "`", "'")

-- forward an underscore
vim.keymap.set('n', '_', 'f_')

-- rename file
local rename_file = function()
    local old_name = vim.fn.expand('%')
    local _, err = pcall(function()
        local new_name = vim.fn.input('New file name: ', vim.fn.expand('%'),
                                      'file')
        if new_name ~= old_name then
            vim.lsp.util.rename(old_name, new_name)
        end
    end)

    if err and err ~= "Keyboard interrupt" then error(err) end
end

vim.keymap.set('n', '<leader>fr', rename_file)
vim.keymap.set('n', '<leader>fp', function() print(vim.fn.expand('%')) end)

-- clear search
vim.keymap.set('n', '\\', '<CMD>silent noh<CR>')

-- easy split navigation
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- split rotations
vim.keymap.set('n', '<leader>H', '<C-w>t <C-w>H <C-w>=')
vim.keymap.set('n', '<leader>V', '<C-w>t <C-w>K <C-w>=')

vim.keymap.set('n', '<leader>[', ':silent tabprevious<CR>')
vim.keymap.set('n', '<leader>]', ':silent tabnext<CR>')

-- alternate file nav
vim.keymap.set('n', '<M-a>', ':A<CR>')
vim.keymap.set('n', '<M-v>', ':AV<CR>')
vim.keymap.set('n', '<M-s>', ':AS<CR>')
vim.keymap.set('n', '<C-v><C-a>', ':A<CR>')
vim.keymap.set('n', '<C-v><C-v>', ':AV<CR>')
vim.keymap.set('n', '<C-v><C-s>', ':AS<CR>')

-- make arrows useful
vim.keymap.set('n', '<up>', ':m-2<CR>==')
vim.keymap.set('n', '<down>', ':m+<CR>==')
vim.keymap.set('n', '<left>', ':vertical resize -5<CR>')
vim.keymap.set('n', '<right>', ':vertical resize +5<CR>')

-- vim.keymap.set('n', '[[', '[m')
-- vim.keymap.set('n', ']]', ']m')

local map_ai_move = function(lhs, textobject_id, direction, desc)
    local rhs = function()
        MiniAi.move_cursor('left', 'a', textobject_id,
                           {search_method = direction})
    end
    vim.keymap.set({'n', 'x', 'o'}, lhs, rhs, {desc = desc})
end

-- Instead of `'f'` use id of textobject you'd like to move.
-- For more info see `:h MiniAi.move_cursor()`.
map_ai_move('[m', 'f', 'prev', 'Jump to prev function')
map_ai_move(']m', 'f', 'next', 'Jump to next function')

-- some per-branch specific search stuff
if vim.fn.isdirectory(".git") ~= 0 then
    local grep_in_changed_on_branch = function(query)
        if query then
            local cmd = "git changed-on-branch | xargs ag --vimgrep " .. query

            vim.cmd("cex system('" .. cmd .. "')")
            vim.cmd("copen")
        end
    end

    vim.api.nvim_create_user_command('Ackb', function(opts)
        grep_in_changed_on_branch(opts.args)
    end, {nargs = 1})

    vim.keymap.set('n', '<leader>ga', function()
        vim.ui.input({prompt = "Enter query: "},
                     function(query) grep_in_changed_on_branch(query) end)
    end)
end

local cleanup_buffer = function()
    -- no thanks, paste mode
    vim.opt.paste = false

    vim.api.nvim_command("silent! %s/\\t/  /")
    vim.api.nvim_command("silent! %s/\\s\\+$//")
    vim.api.nvim_command("silent! %s/\\n\\n\\n/\\r\\r/g")
    vim.api.nvim_command("silent! LspRestart")

    -- close floating windows
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= "" then vim.api.nvim_win_close(win, false) end
    end

    vim.api.nvim_command("update")
    vim.api.nvim_command("silent e")
end

vim.keymap.set('n', '<BS><BS>', cleanup_buffer, {noremap = true})

local new_zettel = function()
    local _, err = pcall(function()
        local sha = vim.fn.trim(vim.fn.system("openssl rand -hex 4"))
        local new_name = vim.fn.input('New file name: ', sha .. ".md", 'file')

        local zettel_root = vim.env.ZETTEL_ROOT or ''
        if zettel_root == '' then
            error('ZETTEL_ROOT environment variable not set.')
        end

        local file_path = zettel_root .. '/' .. new_name

        vim.cmd('vsplit ' .. file_path)
        vim.cmd('redraw!')
    end)

    if err and err ~= "Keyboard interrupt" then error(err) end
end

vim.keymap.set('n', 'gzn', new_zettel, {noremap = true, desc = 'New zettel'})

vim.keymap.set('n', 'gzo', ':Telescope find_files cwd=~/Dropbox/neuron<CR>',
               {desc = 'Open zettel'})
vim.keymap.set('n', 'gza', ':Telescope live_grep cwd=~/Dropbox/neuron<CR>',
               {desc = 'Search zettel'})
vim.keymap.set('n', 'gzj',
               ':edit ~/Dropbox/neuron/' .. vim.fn.strftime("%Y-%m") ..
                   ".md<CR>")

vim.api.nvim_create_user_command('SS', function()
    require('helpers').fsend_to_app("Slack")
end, {nargs = 0})
