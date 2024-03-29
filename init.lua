SCREENCAST = os.getenv("SCREENCAST") ~= nil

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", -- latest stable release
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

LSP = {}

P = function(v)
    print(vim.inspect(v))
    return v
end

PP = function(v)
    vim.api.nvim_exec([[
messages clear
]], false)
    P(v)
end

RELOAD = function(...) return require("plenary.reload").reload_module(...) end

R = function(name)
    RELOAD(name)
    return require(name)
end

SILENTLY = function(fn)
    local original_print = print
    print = function() end
    pcall(fn)
    print = original_print
end

require("settings")
require("keybinds")

require("lazy").setup("plugins")

-- jump to last position in file
vim.api.nvim_create_autocmd("BufReadPost", {
    command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]]
})
