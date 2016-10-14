#!/bin/bash

# This script configures environment variables for local use.

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
