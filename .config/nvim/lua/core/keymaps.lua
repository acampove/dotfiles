vim.g.mapleader = '\\'

local km = vim.keymap -- for conciseness

km.set('i', 'jk'          ,'<ESC>')
km.set('n', '+',           'ddkkp')
km.set('n', '-',           'ddp')
km.set('n', '<leader>c',   ':noh<cr>')
km.set('n', '<leader>f',   ':FZF<cr>')
km.set('n', '<leader>g',   ':Git<cr>')
km.set('n', '<leader>l',   ':e #<cr>')
km.set('n', '<leader>p',   '<c-w>p ')
km.set('n', '<leader>q',   ':q<cr>')
km.set('n', '<leader>r',   ':so $MYVIMRC<cr>')
km.set('n', '<leader>s',   ':%s/\\s\\+$//<cr>')
km.set('n', '<leader>w',   ':w<cr>')
km.set('n', '<S-j>',       '<nop> ')
km.set('n', '<S-k>',       '<nop> ')
km.set('n', '<S-l>',       '<nop> ')
km.set('n', '<S-h>',       '<nop> ')
km.set('n', '<Up>',        '<nop>')
km.set('n', '<Down>',      '<nop>')
km.set('n', '<Right>',     '<nop>')
km.set('n', '<Left>',      '<nop>')
