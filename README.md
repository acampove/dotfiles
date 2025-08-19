# Dotfiles

## Packages that need to be installed

### numlockx

Will disable `numlock` key and allow unmapping it
when used together with `$HOME/.xinitrc`

```bash
sudo dnf install numlockx
```

This will keep the number pad always on.

## Neovim

### Snippets

```python
# classd
# ----------------------
class {1}:
    '''
    {2}
    '''
    # ----------------------
    def __init__(self, {3}):
        '''
        Parameters
        -------------
        {4}
        '''
        {5}

# deftt
# ----------------------
def {1}({2}) -> {3}:
    '''
    {4}

    Parameters 
    -------------
    {5}
    '''
    {6}

# pargs
import argparse

# ----------------------
def _parse_args() -> None:
    parser = argparse.ArgumentParser(description='{1}')
    parser.add_argument('{2}', '{3}' , type=str, help='{4}')
    args = parser.parse_args()

# data_class
# ----------------------
class Data:
    '''
    Class meant to be used to share attributes
    '''
    {1}

# logger
from dmu.logging.log_store import LogStore

log=LogStore.add_logger('{1}')
# ----------------------
{2}

# main
# ----------------------
def main():
    '''
    Entry point
    '''
    {1}
# ----------------------
if __name__ == '__main__':
    main()

# deftd
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

# test_initializer
# ----------------------
@pytest.fixture(scope='session', autouse=True)
def initialize():
    '''
    This will run before any test
    '''
    {1}
```

### Commands 

In neovim, in order to align lines like:

```pyhon
some=thing
herethat=is
not=aligned
```

to column `9` do:

```bash
qq:Align9jk0<DOWN>q
```

which will:

- Start recording in `q`.
- Run the function `Align` with argument `9`
- Exit insert mode (can also do ESC).
- Move to the beginning of the line and down.
- Stop recording on `q`

Then you can repeat this `N` times by running the macro with `N@q`


## Python

### Aliases 

```bash
# Alias to ease the use of `py-spy`:
alias pyspy_json='py-spy record -o profile.json --format speedscope --'
```

### System

```bash
# Check if http proxy is working
check_internet
```

```bash
# Used to synchronize system clock
# This needs http proxy in port 8888
synchronize
```

## (Micro)mamba

In order to deal with micromamba more easily use:

| Command | Description             | Example                    |
| ------- | ----------------------- | -------------------------- |
| `mmn`   | Creates environment     | `mmn env_name python=3.12` |
| `mma`   | Activates environment   | `mma env_name`             |
| `mmd`   | Deactivates environment | `mmd env_name`             |
| `mmu`   | Uninstalls package      | `mmu root`                 |
| `mmc`   | Clones environment      | `mmc old_env new_env`      |
| `mmr`   | Removes environment     | `mmr env_name`             |
| `mmi`   | Installs package        | `mmi python=3.12`          |
| `mml`   | Lists environments      | `mml`                      |


