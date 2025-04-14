<h1 align="center">PKGBUILDs</h1>
<p align="center">
    <a href="https://aur.archlinux.org/packages?SeB=M&K=TD-Sky">
        <img src="https://img.shields.io/static/v1?style=flat-square&label=aur&message=TD-Sky&color=blue&logo=archlinux" alt="Packages maintained by TD-Sky" />
    </a>
</p>

## Powered by

- [nvrs](https://github.com/adamperkowski/nvrs)
- [nushell](https://github.com/nushell/nushell)
- [pacman-contrib](https://gitlab.archlinux.org/pacman/pacman-contrib): updpkgsums
- [aurpublish](https://github.com/eli-schwartz/aurpublish)



## Setup

First of all, you need to initialize the repository to equip with githooks helping you manage packages:

```bash
$ aurpublish setup
```

Then install nushell plugin [nu_plugin_query](https://crates.io/crates/nu_plugin_query) using nushell:

```nushell
$ plugin add <path/to/nu_plugin_query>
```



## Usage

When you make sure the upstream has upgraded, use `update.nu` to update the specified package:

```bash
# Check and update
$ ./update.nu <package-in-the-repository>
```

> You can read the help of `update.nu`:
>
> ```bash
> $ ./update.nu -h
> ```

If the update process works, you can add and commit with automatical:
1. compiling `.SRCINFO`,
2. checking *shasum* ,
3. generating message

provided by `aurpublish`.

```bash
$ git add <package>
$ git commit -m ''
```



## License

GNU General Public License v3.0 ([GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.txt))
