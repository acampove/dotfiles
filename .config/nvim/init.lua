require('core')
require('lazy_conf')

-- Custom spell highlighting
vim.cmd [[highlight SpellBad   cterm=underline ctermfg=red    guifg=red   ]]
vim.cmd [[highlight SpellCap   cterm=underline ctermfg=blue   guifg=blue  ]]
vim.cmd [[highlight SpellRare  cterm=underline ctermfg=yellow guifg=yellow]]
vim.cmd [[highlight SpellLocal cterm=underline ctermfg=green  guifg=green ]]

