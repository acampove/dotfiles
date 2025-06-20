require('core')
require('lazy_conf')

-- Custom spell highlighting
vim.cmd [[highlight SpellBad   cterm=underline ctermfg=red    guifg=red   ]]
vim.cmd [[highlight SpellCap   cterm=underline ctermfg=blue   guifg=blue  ]]
vim.cmd [[highlight SpellRare  cterm=underline ctermfg=yellow guifg=yellow]]
vim.cmd [[highlight SpellLocal cterm=underline ctermfg=green  guifg=green ]]

vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

vim.diagnostic.config({
  virtual_text     = true,  -- re-enable inline messages
  signs            = true,
  underline        = true,
  update_in_insert = false,
})

