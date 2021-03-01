#!/bin/sh
set -e -x

[ "$(grep 'mt7621[ \t]*|' target/linux/ramips/base-files/etc/board.d/02_network | wc -l)" = 1 ]
[ "$(grep 'tew-692gr[ \t]*)' target/linux/ramips/base-files/etc/board.d/02_network | wc -l)" = 1 ]
