#!/usr/bin/env nu

use std/log

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
        rm -rf $pdir
    }
    git clone $"ssh://aur@aur.archlinux.org/($pdir).git"

    let remote_package = ($package | path dirname -r $PUBLISH_HOME)

    git ls-tree -r main --name-only
    | split row (char newline)
    | where {|s| $s | str starts-with $"($package)/" }
    | each {|f| cp -r $f $remote_package }

    gitignore | save -f ($remote_package | path join '.gitignore')

    cd $remote_package
    log pwd
    git add .
    git commit -m $version
    git ls-tree -r master --name-only | tree -Ca --fromfile
    git push origin master
}

def gitignore []: nothing -> string {
    [
        '*.tar'
        '*.tar.*'
        '*.jar'
        '*.exe'
        '*.msi'
        '*.deb'
        '*.zip'
        '*.tgz'
        '*.log'
        '*.log.*'
        '*.sig'
        ''
        'pkg/'
        'src/'
    ]
    | str join (char newline)
}
