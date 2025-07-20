# Dotfiles

## Packages that need to be installed

### numlockx

Will disable `numlock` key and allow unmapping it
when used together with `$HOME/.xinitrc`

```bash
sudo dnf install numlockx
```

This will keep the number pad always on.

## Utilities

### Neovim

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
