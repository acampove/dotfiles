vim.cmd("let g:netrw_liststyle = 3")
vim.cmd("let g:pyindent_open_paren = 'shiftwidth()'")

vim.env.FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop    = 4 -- 4 spaces for tabs (prettier default)
opt.shiftwidth = 4 -- 4 spaces for indent width
opt.expandtab  = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one
opt.foldmethod = 'indent'
opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
local handle = io.popen("hostname")
local hostname = handle:read("*l")
handle:close()

if string.match(hostname, "ihep.ac.cn$") then
  print("Not using system clipboard for IHEP")
else
  opt.clipboard:append("unnamedplus") -- use system clipboard as default register
end

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false
