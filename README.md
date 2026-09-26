# dotfiles

Personal Arch Linux setup - dwm, st and zsh, via [LARBS](https://larbs.xyz).

## New machine

Do a minimal Arch base install, then:

```sh
sh larbs.sh \
  -r https://github.com/gasparsequeira/dotfiles.git \
  -p https://raw.githubusercontent.com/gasparsequeira/dotfiles/main/progs.csv
```

> Some packages come from an extra pacman repo; configure it before running.

## Post-install

```sh
curl -fsSL https://raw.githubusercontent.com/gasparsequeira/dotfiles/main/setup.sh | bash
```

Then log out and back in.

## Files

- `progs.csv` — package list for LARBS
- `setup.sh` — extra packages and services
