#!/usr/bin/env nu

use std/log

const PUBLISH_HOME = '/tmp/aur/publish'

def 'log pwd' [] {
    log info ('In ' + $env.PWD)
}

# Publish package to AUR
def main [package: path] {
    let pkgbuild = open -r ($package | path join PKGBUILD)
    let pkgver = $pkgbuild | parse -r 'pkgver=(?P<ver>.+)' | get ver.0
    let pkgrel = $pkgbuild | parse -r 'pkgrel=(?P<rel>\d+)' | get rel.0 | into int
    let version = $"($pkgver)-($pkgrel)"
    log info ('Version: ' + $version)

    let pdir = $package | path basename
    try {
        rm -rfv ($PUBLISH_HOME | path join $pdir)
    }
    mkdir -v $PUBLISH_HOME
    git clone $"ssh://aur@aur.archlinux.org/($pdir).git" ($PUBLISH_HOME | path join $pdir)

    let remote_package = $package | path dirname -r $PUBLISH_HOME

    git ls-tree -r main --name-only
    | lines
    | where {|s| $s | str starts-with $"($package)/" }
    | each {|f| cp -rfv $f $remote_package }

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
