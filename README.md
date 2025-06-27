# Dotfiles

## Packages that need to be installed

### numlockx

Will disable `numlock` key and allow unmapping it
when used together with `$HOME/.xinitrc`

```bash
sudo dnf install numlockx
```

This will keep the number pad always on.

## Python

### Dependencies check

The command:

```bash
showdeps src/mypackage rx_
```

will 

- Look for all the module dependencies for the modules in `src/mypackage` (assumming there is an `__init__.py` file inside)
- Filter for only the dependencies living in packages containing `rx_`, e.g. `rx_data`.
- Make a diagram of the dependencies and print it.

The utility uses `pydeps`.
