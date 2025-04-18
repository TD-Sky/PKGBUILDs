#!/usr/bin/env nu

plugin use query

# Check the new version of package and update it.
def main [
    package: path,  # Package going to update
    --release (-r), # Increase `pkgrel` if `pkgver` is unchanged
    --keep (-k),    # Keep old version
] {
    # The actually name for version check
    let dir = $package | path basename
    let project = $dir
        | str strip-suffix '-bin'
        | default ($dir | str strip-suffix '-git')
        | default $dir

    # Check the new verions according to `nvrs.toml`;
    # if upstream has upgraded, update `new_ver.json`;
    # compare `old_ver.json` and `new_ver.json`, print the differences.
    nvrs --config nvrs.toml
    nvrs --config nvrs.toml --cmp

    let old_ver = open -r old_ver.json | query json $"data.($project).version"
    let new_ver = open -r new_ver.json | query json $"data.($project).version"

    cd $package
    let pkgbuild = open -r PKGBUILD

    if $old_ver != $new_ver {
        $pkgbuild
        | str replace -r $"pkgver=($old_ver)" $"pkgver=($new_ver)"
        | str replace -r 'pkgrel=\d+' 'pkgrel=1' # Clean `pkgrel` to 1
        | save -f PKGBUILD
    } else if $old_ver == $new_ver and $release {
        # Increase `pkgrel` by 1
        let pkgrel = $pkgbuild | parse -r 'pkgrel=(?P<rel>\d+)' | get rel.0 | into int
        $pkgbuild
        | str replace -r 'pkgrel=\d+' $"pkgrel=($pkgrel + 1)"
        | save -f PKGBUILD
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
    if not $keep {
        # Update `project` in `old_ver.json` to new version
        nvrs --config nvrs.toml --take $project
    }
}

def 'str strip-suffix' [
    suffix: string
]: string -> string {
    let self = $in
    if ($self | str ends-with $suffix) {
        let i = $self | str index-of -e $suffix
        $self | str substring ..<$i
    }
}
