# anyenv-aur
Toolchain for [anyenv](https://github.com/anyenv/anyenv) AUR package maintainer

## Installation

### AUR Settings

Register your ssh key on AUR.

https://aur.archlinux.org/

Be sure `.ssh/config`, such as:

```
Host aur.archlinux.org
    IdentityFile ~/.ssh/aur
    User aur
```

### Install Dependencies

```shell
git clone https://github.com/usagiga/anyenv-aur
cd ./anyenv-aur
./scripts/initialize.sh
```

## How to maintain anyenv

Just edit PKGBUILD.

When you run `git commit`, git hooks run test and finalize automatically! :tada:

## LICENSE

MIT
