#!/bin/bash

# Prints the hostname of the system and its system role as
# defined in /etc/system-role

echo "$(hostname -s)" | tr '[:lower:]' '[:upper:]' | banner -w 100 -c '#'
cat /etc/system-role
echo
