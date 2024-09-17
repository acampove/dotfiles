vim.g.mapleader = "\\"

local km = vim.keymap -- for conciseness

km.set("i", "jk", "<ESC>")
km.set("n", "+", "ddkkp")
km.set("n", "-", "ddp")
km.set("n", "<leader>c", ":noh<cr>")
km.set("n", "<leader>g", ":Git<cr>")
km.set("n", "<leader>l", ":e #<cr>")
km.set("n", "<leader>p", "<c-w>p ")
km.set("n", "<leader>q", ":q<cr>")
km.set("n", "<leader>r", ":so $MYVIMRC<cr>")
km.set("n", "<leader>s", ":%s/\\s\\+$//<cr>")
km.set("n", "<leader>w", ":w<cr>")
km.set("n", "<leader>z", ":Lazy<cr>")

-- Map arrow keys to switch panels 
km.set("n", "<Up>"   , "<C-W>j")
km.set("n", "<Down>" , "<C-W>k")
km.set("n", "<Right>", "<C-W>l")
km.set("n", "<Left>" , "<C-W>h")

-- Telescope
km.set("n", "<leader>ff", ":Telescope find_files<cr>", {})
km.set("n", "<leader>fg", ":Telescope live_grep<cr>" , {})
km.set("n", "<leader>fb", ":Telescope buffers<cr>"   , {})
km.set("n", "<leader>fh", ":Telescope help_tags<cr>" , {})
