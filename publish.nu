#!/usr/bin/env nu

use std log

const PUBLISH_HOME = '/tmp/aur/publish'

def 'log pwd' [] {
    log info ('In ' + $env.PWD)
}

# Publish package to AUR
def main [package: path] {
    cd $package

    let pkgver = (rg 'pkgver=(.+)$' -r '$1' -m 1 PKGBUILD)
    let pkgrel = rg 'pkgrel=(\d+)' -r '$1' -m 1 PKGBUILD | into int
    let version = $"($pkgver)-($pkgrel)"
    log info ('Version: ' + $version)

    mkdir $PUBLISH_HOME
    cd $PUBLISH_HOME
    log pwd
    let pdir = $package | path basename
    if ($pdir | path exists) {
        log warning $"There was already `($pdir)`, removing it..."
        rm $pdir
    }
    git clone $"ssh://aur@aur.archlinux.org/($pdir).git"

    let remote_package = ($package | path dirname -r $PUBLISH_HOME)
    cp ($package | path join PKGBUILD) ($package | path join .SRCINFO) $remote_package

    cd $remote_package
    log pwd
    git add PKGBUILD .SRCINFO
    git commit -m $version
    git push origin master
}
