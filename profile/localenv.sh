#!/bin/bash

# This script configures environment variables for local use.  Additionally,
# $1 will be executed with the given arguments if $1 is specified.
# The invoked program will be run in the configured environment.
#
# We can change these variables to switch to a development environment.

function pathmunge {
    newcomponent="$1"
    pathvar="$2"

    if ! echo "$pathvar" | grep -q "$newcomponent"; then
        if [ -n "$pathvar" ]; then
            echo -n "$pathvar:"
        fi
        echo "$newcomponent"
    else
        echo "$pathvar"
    fi
}

LOCAL_DIR='/opt/local'
LOCAL_TOOLS="${LOCAL_DIR}/tools"
LOCAL_ETC="${LOCAL_DIR}/etc"
LOCAL_PYTHONPATH="${LOCAL_TOOLS}/lib/python"

PYTHONPATH="$(pathmunge "$LOCAL_PYTHONPATH" "$PYTHONPATH")"

export LOCAL_DIR LOCAL_TOOLS LOCAL_ETC LOCAL_PYTHONPATH PYTHONPATH
