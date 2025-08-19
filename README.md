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

For a list of snippets check [this](doc/snippets.md)

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


