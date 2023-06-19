vim.g.mapleader = ','
vim.g.maplocalleader = '-'

-- I don't use relative number because it makes things like 30y or :34m39 harder
vim.opt.number = true
vim.opt.cursorline = true

-- whitespace
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.list = true
vim.opt.listchars = {tab = '>~', trail = '·'}
vim.opt.breakindent = true
vim.opt.showbreak = '\\\\'

-- colors
vim.opt.termguicolors = true

vim.opt.cmdheight = 1

vim.opt.signcolumn = 'yes'

-- undo
vim.opt.undodir = '/tmp//'
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.undoreload = 1000

vim.opt.wildmenu = true
vim.opt.wildignore:append('*/tmp/*,*/log/*,*/.git/*')
vim.opt.wildmode = 'longest,list,full'

-- load changes that happen outside of vim
vim.opt.autoread = true

vim.opt.scrolloff = 5
vim.opt.visualbell = true
vim.opt.clipboard = 'unnamedplus'

-- Make searches case-insensive unless there is a capitalized char in the search
vim.opt.infercase = true
vim.opt.smartcase = true

vim.opt.backupdir = '/tmp/vim-backupdir/'
vim.opt.directory = '/tmp/vim-swap/'

-- sudo write
vim.cmd "ca w!! w !sudo tee >/dev/null '%'"

-- completion
vim.opt.dictionary:append('~/.vim/dictionary.txt')
vim.opt.complete = '.,b,u,],k'
vim.opt.completeopt = 'menu,menuone,noselect'

-- make matching parens more obvious
vim.cmd "highlight MatchParen ctermbg=2"

-- Insert only one space when joining lines that contain
-- sentence-terminating punctuation like `.`.
vim.opt.joinspaces = false

-- Open file at line number for file:number pairs
vim.opt.isfname:append(':')

-- Smaller updatetime for CursorHold & CursorHoldI
vim.opt.updatetime = 300

-- Yank full file path
vim.cmd "command! YFP :let @+ = expand('%')"

-- Yank absolute file path
vim.cmd "command! YFA :let @+ = expand('%:p')"

-- Yank file dir
vim.cmd "command! YFD :let @+ = expand('%:h')"

-- Yank file name only
vim.cmd "command! YFN :let @+ = expand('%:t')"

-- Recursive mkdir for the current file path
vim.cmd "command! Mkdir :execute ':silent !mkdir -p %:h'"

-- allow selecting beyond actual characters in visual mode
vim.opt.virtualedit = "block"

vim.cmd [[
  autocmd FileType qf if (getwininfo(win_getid())[0].loclist != 1) | wincmd J | endif
]]

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 20
