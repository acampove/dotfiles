local ls    = require("luasnip")
local snip  = ls.snippet
local text  = ls.text_node

local utils = require("snippets.utils")
local snipf = utils.snippetf

----------------------------------------------------
s_data=snipf('data_class', [[
class Data:
    '''
    Class meant to be used to share attributes
    '''
    {1}
]])
----------------------------------------------------
s_logger=snipf('logger', [[
from dmu.logging.log_store import LogStore

log=LogStore.add_logger('{1}')
]])
----------------------------------------------------
s_main=snipf('main', [[
# ----------------------
def main():
    '''
    Entry point
    '''
    {1}
# ----------------------
if __name__ == '__main__':
    main()
# ----------------------
]])
----------------------------------------------------
s_deftd=snipf('deftd', [[
# ----------------------
def {1}() -> None:
    '''
    Parameters
    -------------

    Returns
    -------------

    '''
]])
----------------------------------------------------
s_defstd=snipf('defstd', [[
def {1}(self) -> None:
    '''
    Parameters
    -------------

    Returns
    -------------

    '''
]])
----------------------------------------------------
return {
    s_main,
    s_logger,
    s_data,
    s_deftd,
    s_defstd,
}
