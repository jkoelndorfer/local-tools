#!/bin/bash

grub-install --target=i386-pc --recheck --debug /dev/vda
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux
rc=1
while true; do
    salt-call state.highstate
    rc="$?"
    if [ "$rc" -ne 0 ]; then
        echo 'salt-call failed -- accept the key?' >&2
        echo 'Hit enter to try again' >&2
        read
    else
        break
    fi
done
