vim.g.mapleader = "\\"

local km = vim.keymap -- for conciseness

km.set("i", "jk", "<ESC>")

-- Move line up or down
km.set("n", "+", "ddkkp")
km.set("n", "-", "ddp")

-- Hide highlight
km.set("n", "<leader>c", ":noh<cr>")

-- Remove trailing spaces
km.set("n", "<leader>ss", ":%s/\\s\\+$//<cr>")

-- Go to last file
km.set("n", "<leader>ll", ":e #<cr>")

km.set("n", "<leader>p", "<c-w>p ")
km.set("n", "<leader>q", ":q<cr>")
km.set("n", "<leader>r", ":so $MYVIMRC<cr>")
km.set("n", "<leader>w", ":w<cr>")

-- Map arrow keys to switch panels
km.set("n", "<Up>"   , "<C-W>k")
km.set("n", "<Down>" , "<C-W>j")
km.set("n", "<Right>", "<C-W>l")
km.set("n", "<Left>" , "<C-W>h")

-- Maximize and minimize splits
km.set("n", "<leader>a" , "<C-W>_")
km.set("n", "<leader>s" , "<C-W>=")

-- Lazy
km.set("n", "<leader>z", ":Lazy<cr>")

-- Telescope
km.set("n", "<leader>ff", ":Telescope find_files<cr>", {})
km.set("n", "<leader>fg", ":Telescope live_grep<cr>" , {})
km.set("n", "<leader>fb", ":Telescope buffers<cr>"   , {})
km.set("n", "<leader>fh", ":Telescope help_tags<cr>" , {})

-- Neogit
km.set("n", "<leader>g" , ":Neogit kind=split_below<cr>" , {})

