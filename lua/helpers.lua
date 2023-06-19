local M = {}

-- insert text at cursor and move to position after insertion
M.insert_text = function(text)
    local pos = vim.api.nvim_win_get_cursor(0)
    local row = pos[1]
    local col = pos[2]

    local line = vim.api.nvim_get_current_line()
    local nline = line:sub(0, col) .. text .. line:sub(col + 1)

    vim.api.nvim_set_current_line(nline)

    vim.api.nvim_win_set_cursor(0, {row, col + string.len(text)})
end

M.focus_file_or_callback = function(filename, callback)
    -- get the open window id for the file if any
    local winid = vim.fn.win_findbuf(vim.fn.bufnr(filename))[1]

    if winid then
        -- focus it
        vim.fn.win_gotoid(winid)
    else
        callback()
    end
end

M.map = function(tbl, fun)
    local t = {}

    for _, item in pairs(tbl) do table.insert(t, fun(item)) end

    return t
end

M.memoize = function(name, fun)
    if vim.fn.exists('b:' .. name) == 0 then
        vim.api.nvim_buf_set_var(0, name, fun())
    end

    return vim.api.nvim_buf_get_var(0, name)
end

M.unmemoize = function(name) vim.api.nvim_buf_del_var(0, name) end

local terminal_app = "Kitty"

local send_to_app = function(application, refocus_terminal)
    local output_file = "/tmp/send-to-app.scpt"
    local content = vim.trim(table.concat(
                                 vim.api.nvim_buf_get_lines(0, 0, -1, false),
                                 "\n"))
    vim.fn.setreg('*', content)

    local output_io = io.open(output_file, "w")

    io.output(output_io)
    io.write("activate application \"" .. application .. "\"" .. "\n")
    io.write(
        "tell application \"System Events\" to keystroke \"v\" using {command down}" ..
            "\n")

    if refocus_terminal then
        io.write("delay 0.1" .. "\n")
        io.write("tell application \"System Events\" to keystroke return" ..
                     "\n")
        io.write("activate application \"" .. terminal_app .. "\"" .. "\n")
    end

    io.close()

    vim.fn.system("osascript " .. output_file)
end

M.send_to_app = function(application) send_to_app(application, true) end

-- send to app but keep focus on the app
M.fsend_to_app = function(application) send_to_app(application, false) end

M.time = function(callback)
    local start = os.clock()

    local result = callback()

    print(string.format("elapsed time: %.2f\n", os.clock() - start))
    return result
end

return M
