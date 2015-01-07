#!/bin/bash

# Sets XDG base directories per
# http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-"/run/user/$USER"}
XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-/etc/xdg}
XDG_DATA_DIRS=${XDG_DATA_DIRS:-/usr/local/share:/usr/share}
