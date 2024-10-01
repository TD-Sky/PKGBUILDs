#!/usr/bin/env nu

use std log

const PUBLISH_HOME = '/tmp/aur/publish'

def 'log pwd' [] {
    log info ('In ' + $env.PWD)
}

# Publish package to AUR
def main [package: path] {
    cd $package
    let pkgbuild = open -r PKGBUILD

    let pkgver = $pkgbuild | parse -r 'pkgver=(?P<ver>.+)' | get ver.0
    let pkgrel = $pkgbuild | parse -r 'pkgrel=(?P<rel>\d+)' | get rel.0 | into int
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
