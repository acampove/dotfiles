local ls    = require("luasnip")
local snip  = ls.snippet
local text  = ls.text_node

local utils = require("snippets.utils")
local snipf = utils.snippetf

----------------------------------------------------
s_deftt=snipf('deftt', [[
# ----------------------
def {1}({2}) -> {3}:
    '''
    {4}

    Parameters 
    -------------
    {5}
    '''
    {6}
]])
----------------------------------------------------
s_args=snipf('pargs', [[
import argparse

# ----------------------
def _parse_args() -> None:
    parser = argparse.ArgumentParser(description='{1}')
    parser.add_argument('{2}', '{3}' , type=str, help='{4}')
    args = parser.parse_args()
]])
----------------------------------------------------
s_data=snipf('data_class', [[
# ----------------------
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
# ----------------------
{2}
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
]])
----------------------------------------------------
s_deftd=snipf('deftd', [[
# ----------------------
def {1}({2}) -> {3}:
    '''
    Parameters
    -------------
    {4}

    Returns
    -------------
    {5}
    '''
    {6}
]])
----------------------------------------------------
s_test_initializer=snipf('test_initializer', [[
# ----------------------
@pytest.fixture(scope='session', autouse=True)
def initialize():
    '''
    This will run before any test
    '''
    {1}
]])
----------------------------------------------------
return {
    s_main,
    s_logger,
    s_data,
    s_deftd,
    s_deftt,
    s_args,
    s_test_initializer,
}
