-- saving
local update = function()
    vim.api.nvim_input("<esc>")
    vim.cmd([[update]], false)
    require('luasnip').unlink_current()
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
vim.keymap.set('n', '\\', ':noh<CR>')

-- easy split navigation
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- split rotations
vim.keymap.set('n', '<leader>H', '<C-w>t <C-w>H <C-w>=')
vim.keymap.set('n', '<leader>V', '<C-w>t <C-w>K <C-w>=')

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

vim.cmd([[
  function! NewZettel()
    let sha = trim(system("openssl rand -hex 4"))
    let new_name = input('New file name: ', sha . ".md", 'file')

    exec ':vsplit /Users/ship/Dropbox/neuron/' . new_name
    redraw!
  endfunction
  nnoremap gzn :call NewZettel()<cr>
]])

vim.keymap.set('n', 'gzo', ':Telescope find_files cwd=~/Dropbox/neuron<CR>')
vim.keymap.set('n', 'gza', ':Telescope live_grep cwd=~/Dropbox/neuron<CR>')
vim.keymap.set('n', 'gzj',
               ':edit ~/Dropbox/neuron/' .. vim.fn.strftime("%Y-%m") ..
                   ".md<CR>")
