#!/usr/bin/nu

def main [
    package: path,        # Package going to update
    --release (-r): bool, # Increase `pkgrel` if `pkgver` is unchanged
    --check (-c): bool,   # Check new version before update
] {
    if $check {
        # Check the new verions according to `nvchecker.toml`;
        # if upstream has upgraded, update `new_ver.json`;
        # compare `old_ver.json` and `new_ver.json`, print the differences.
        nvchecker -c nvchecker.toml -l warning --failures
        nvcmp -c nvchecker.toml
    }

    let old_ver = (open old_ver.json)
    let new_ver = (open new_ver.json)

    cd $package

    # Rebind variables with `string`
    let package = (
        $package
        | path basename
        | str replace '([[:ascii:]]+)-(bin|git)$' '$1'
        # Strip the suffix if there is
    )
    let old_ver = ($old_ver | get $package)
    let new_ver = ($new_ver | get $package)

    if $old_ver != $new_ver {
        open -r PKGBUILD
        | str replace $"pkgver=($old_ver)" $"pkgver=($new_ver)"
        | str replace 'pkgrel=(\d+)' 'pkgrel=1' # Clean `pkgrel` to 1
        | save -f PKGBUILD
    } else if $old_ver == $new_ver and $release {
        # Increase `pkgrel` by 1
        let pkgrel = (rg 'pkgrel=(\d+)' -r '$1' -m 1 PKGBUILD | into int)
        sd 'pkgrel=(\d+)' $"pkgrel=($pkgrel + 1)" PKGBUILD
    } else {
        return
    }

    # Fetch the source described by PKGBUILD;
    # shasum it;
    # update `shasum` in PKGBUILD with new shasum.
    updpkgsums

    # Back to PKGBUILDs
    cd ..

    # Update `package` in `old_ver.json` to new version
    nvtake $package -c nvchecker.toml
}
