#!/usr/bin/nu

# Check the new version of package and update it.
def main [
    package: path,          # Package going to update
    --release (-r): bool,   # Increase `pkgrel` if `pkgver` is unchanged
    --keep-old: bool,       # Keep old version
] {
    # The actually name for version check
    let project = (
        $package
        | path basename
        | str replace -r '([[:ascii:]]+)-(bin|git)$' '$1'
        # Strip the suffix if there is
    )

    # Check the new verions according to `nvchecker.toml`;
    # if upstream has upgraded, update `new_ver.json`;
    # compare `old_ver.json` and `new_ver.json`, print the differences.
    nvchecker -c nvchecker.toml -l warning --failures -e $project
    nvcmp -c nvchecker.toml

    let old_ver = (open old_ver.json)
    let new_ver = (open new_ver.json)

    cd $package

    let old_ver = ($old_ver | get $project)
    let new_ver = ($new_ver | get $project)

    if $old_ver != $new_ver {
        open -r PKGBUILD
        | str replace -r $"pkgver=($old_ver)" $"pkgver=($new_ver)"
        | str replace -r 'pkgrel=(\d+)' 'pkgrel=1' # Clean `pkgrel` to 1
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

    # Keeping old version allows you to update another
    # package of the same project next time
    if not $keep_old {
        # Update `project` in `old_ver.json` to new version
        nvtake $project -c nvchecker.toml
    }
}
