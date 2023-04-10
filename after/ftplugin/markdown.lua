local ts = vim.treesitter

local o = vim.opt
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true
o.conceallevel = 1

o.spell = true

local helpers = require('helpers')

local action_state = require "telescope.actions.state"
local actions = require "telescope.actions"

local zettel_dir = vim.fn.getenv("ZETTEL_ROOT")
local zettel_http_root = vim.fn.getenv("ZETTEL_HTTP_ROOT")

-- consider - as part of a word
vim.opt.iskeyword:append("-")

local md_preview = function()
    vim.cmd("update")

    local to_open = vim.fn.expand('%')

    if string.find(vim.fn.expand("%:p"), zettel_dir) then
        to_open = zettel_http_root .. vim.fn.expand("%:t:r")
    end

    vim.fn.system({"open", to_open})
end

local insert_text = helpers.insert_text

local get_root = function()
    local tree = ts.get_parser(0, "markdown"):parse()[1]
    return tree:root()
end

local each_capture = function(query)
    local parsed_query = ts.query.parse("markdown", query)

    local root = get_root()

    return parsed_query:iter_captures(root)
end

local today = function()
    local date = vim.fn.localtime()
    return vim.fn.strftime('%Y-%m-%d - %A', date)
end

local find_or_insert_date_header = function()
    local allowed_headers_before_date_headers = {"TODO"}
    local today_header_copy = today()

    local heading_depth = 2
    local heading_prefix = string.rep('#', heading_depth)

    local new_lines = {heading_prefix .. " " .. today_header_copy, "", "- ", ""}

    local query = "(atx_h" .. heading_depth .. "_marker) @heading_copy"

    local found = false

    for _, node in each_capture(query) do
        local row1, _, row2, col2 = node:range()

        local heading_copy = vim.api.nvim_buf_get_text(0, row1, col2 + 1, row2,
                                                       -1, {})[1]
        -- if we've found the heading, jump to it
        if heading_copy == today_header_copy then
            found = true
            vim.api.nvim_win_set_cursor(0, {row1 + 1, 0})
            return
        end

        -- if we've found a heading that isn't allow-listed, insert our heading before it
        if not vim.tbl_contains(allowed_headers_before_date_headers,
                                heading_copy) then
            vim.api.nvim_buf_set_lines(0, row1, row2, false, new_lines)
            vim.api.nvim_win_set_cursor(0, {row1 + 3, 4})

            vim.cmd("startinsert!")
            found = true
            return
        end
    end

    if not found then
        local row = vim.api.nvim_win_get_cursor(0)[1]

        vim.api.nvim_buf_set_lines(0, row, row, false, new_lines)
        vim.api.nvim_win_set_cursor(0, {row + 3, 4})

        vim.cmd("startinsert!")
    end
end

local zettel_link_under_cursor = function()
    -- get the current cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    vim.api.nvim_command("execute \"normal! \\\"iyi]\"")

    -- restore the cursor position
    vim.api.nvim_win_set_cursor(0, cursor_pos)

    local note = vim.fn.getreg("i"):gsub('\\?|.*', ''):gsub('[%[%]]*', '')
    local path = vim.fn.expand("%:h") .. "/" .. note .. ".md"

    return {path, note}
end

-- TODO: this is messy. Probably should user require/etc so LSP and LSP.Hover always exist
if LSP then
    LSP.Hover = LSP.Hover or {}

    LSP.Hover.md = function()
        local path = zettel_link_under_cursor()[1]

        -- remove prefix ./ (if present)
        path = path:gsub("^%./", "")

        if not string.find(path, "/") then path = zettel_dir .. path end

        LSP.preview_location(path)
    end
end

local open_zettel_link = function(force)
    local info = zettel_link_under_cursor()
    local path = info[1]
    local note = info[2]

    if force == 1 or vim.fn.filereadable(path) > 0 then
        vim.cmd("edit %:h/" .. note .. ".md")
    else
        vim.notify("Could not find " .. path, "error")
    end
end

local markdown_file_title = function(file_name)
    local lines = vim.fn.readfile(file_name)

    for _, line in pairs(lines) do
        if string.sub(line, 1, 2) == "# " then
            return string.sub(line, 3, string.len(line))
        end
    end

    return nil
end

local insert_zettel_link = function()
    local function z_insert_link(prompt_bufnr, _)
        actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local file = action_state.get_selected_entry()[1]
            local link_destination = vim.fn.fnamemodify(file, ":t:r")
            local file_path = zettel_dir .. vim.fn.fnamemodify(file, ":t")
            local link_text = markdown_file_title(file_path)

            if link_destination == link_text then
                insert_text("[[" .. link_destination .. "]]")
            else
                insert_text("[[" .. link_destination .. "|" .. link_text .. "]]")
            end
        end)
        return true -- attach_mappings must always return true
    end

    local opts = {attach_mappings = z_insert_link, cwd = zettel_dir}
    require('telescope.builtin').find_files(opts)
end

local paste_link = function(url)
    local title = vim.fn.system({"url-title", url}):gsub("[\n\r]", " ")

    title = title:gsub(" by semanticart.+", "")

    insert_text("[" .. vim.trim(title) .. "](" .. url .. ")")

    vim.cmd([[
          normal! o
          startinsert
        ]], false)
end

vim.keymap.set('i', '<c-x><c-h>', insert_zettel_link,
               {desc = 'Insert Zettel Link', buffer = 0})
vim.keymap.set('i', '<c-x><c-d>', function() insert_text(today()) end,
               {desc = 'Insert date', buffer = 0})
vim.keymap.set('i', '<c-x><c-c>', function() insert_text('✔') end,
               {buffer = 0})
vim.keymap
    .set('i', '<c-x><C-q>', function() insert_text('¿') end, {buffer = 0})
vim.keymap.set('i', '<c-x><C-x>', function() insert_text('✘') end,
               {buffer = 0})
vim.keymap.set('i', '<c-x><C-s>', function() insert_text('⧖') end,
               {buffer = 0})
vim.keymap.set('i', '<c-x><c-r>', function()
    insert_text("[🧵](" .. vim.fn.getreg('*') .. ")")
end, {desc = 'Insert Thread Link', buffer = 0})
vim.keymap.set('i', '<c-x><c-l>', function() paste_link(vim.fn.getreg('*')) end,
               {desc = 'Paste Link', buffer = 0})

vim.keymap.set('n', '<C-]>', function() open_zettel_link(0) end,
               {desc = 'Open Zettel Link', buffer = 0})
vim.keymap.set('n', '<C-f>', function() open_zettel_link(1) end,
               {desc = 'Open/create Zettel Link', buffer = 0})
vim.keymap.set('n', '<leader><leader>', md_preview,
               {desc = 'Preview', buffer = 0})
vim.keymap.set('n', '<leader>R', md_preview, {desc = 'Preview', buffer = 0})
vim.keymap.set('n', '<leader>d', find_or_insert_date_header,
               {desc = 'Find/insert Today header', buffer = 0})

vim.cmd([[
function! ToggleCheckboxCheck()
	let line = getline('.')
	if(match(line, "- \\[[x -]\\]") == -1)
    return ToggleCheckbox()
  end

	let l:lookup = {" ": "x", "x": "-", "-": " "}
  silent execute ':s/\v\[(.)\]/\="[" . l:lookup[submatch("1")]. "]"/'
endfunction

noremap <buffer> <c-c><c-c> :call ToggleCheckboxCheck()<CR>

function! ToggleCheckbox()
	let line = getline('.')

	if(match(line, "- \\[[x -]\\]") != -1)
		let line = substitute(line, "- \\[[x -]\\]", "-", "")
	else
		let line = substitute(line, "-", "- [ ]", "")
	endif

	call setline('.', line)
endfunction

noremap <buffer> <c-c><c-i> :call ToggleCheckbox()<CR>
]], false)

vim.cmd([[
Abolish recieve receive
iabbrev :think: 🤔
iabbrev :?: ¿
iabbrev :dancer: 💃
iabbrev :tada: 🎉
iabbrev :x: ✘
iabbrev :check: ✔
iabbrev :brain: 🧠
iabbrev :merge: 
iabbrev :meet: 
iabbrev :review: 
iabbrev :log: 
iabbrev :pr: 
iabbrev :task: 
]])

vim.cmd([[
" VIA https://github.com/preservim/vim-markdown/blob/3a9643961233c2812816078af8bd1eaabc530dce/ftplugin/markdown.vim#L546
" Format table under cursor.
"
" Depends on Tabularize.
"
function! s:TableFormat()
    let l:pos = getpos('.')
    normal! {
    " Search instead of `normal! j` because of the table at beginning of file edge case.
    call search('|')
    normal! j
    " Remove everything that is not a pipe, colon or hyphen next to a colon othewise
    " well formated tables would grow because of addition of 2 spaces on the separator
    " line by Tabularize /|.
    let l:flags = (&gdefault ? '' : 'g')
    execute 's/\(:\@<!-:\@!\|[^|:-]\)//e' . l:flags
    execute 's/--/-/e' . l:flags
    Tabularize /|
    " Move colons for alignment to left or right side of the cell.
    execute 's/:\( \+\)|/\1:|/e' . l:flags
    execute 's/|\( \+\):/|:\1/e' . l:flags
    execute 's/|:\?\zs[ -]\+\ze:\?|/\=repeat("-", len(submatch(0)))/' . l:flags
    call setpos('.', l:pos)
endfunction

command! -buffer TableFormat call s:TableFormat()
]])

-- up and down considers wrapped content (but still respect counts)
vim.cmd([[
nnoremap <buffer> <expr> j v:count ? 'j' : 'gj'
nnoremap <buffer> <expr> k v:count ? 'k' : 'gk'
]])

vim.cmd([[
  command! -buffer Marked :silent !open -a "Marked 2" "%"
]])

vim.api.nvim_set_hl(0, "@shortcut_link_text", {fg = "#ffc777"})
