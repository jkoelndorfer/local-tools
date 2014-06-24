#!/bin/bash

# This script configures environment variables for local use.
#
# We can change these variables to switch to a development environment.

LOCAL_DIR='/opt/local'
LOCAL_TOOLS="${LOCAL_DIR}/tools"
LOCAL_ETC="${LOCAL_DIR}/etc"
LOCAL_PYTHONPATH="${LOCAL_TOOLS}/lib/python"

PYTHONPATH="${LOCAL_PYTHONPATH}${PYTHONPATH:+:$PYTHONPATH}"

export LOCAL_DIR LOCAL_TOOLS LOCAL_ETC LOCAL_PYTHONPATH PYTHONPATH
