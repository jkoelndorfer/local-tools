#!/bin/bash

BOOTSTRAP_DIR='/mnt'
DOMAIN=ad.koelndorfer.com
SALT_MASTER=salt
DNS_SERVER=10.0.0.1

fqdn="$1"
root_disk_blockdev_size='52428800'
target_blockdev=''

if [ -z "$fqdn" ]; then
    echo 'FQDN must be specified' 1>&2
    exit 1
fi

pacman-key --refresh-keys
hostname "$fqdn"

for blockdev in /sys/class/block/*; do
    sz="$(cat "$blockdev/size")"
    if [ "$sz" -eq "$root_disk_blockdev_size" ]; then
        target_blockdev="/dev/$(basename "$blockdev")"
        break
    fi
done

while read parted_cmd; do
    parted -s "$target_blockdev" $parted_cmd
done <<EOF
    mktable gpt
    mkpart primary    2048s  2097152s
    mkpart primary 3145728s 52426752s
    set 1 bios_grub on
    set 2 lvm       on
EOF

pvcreate "$target_blockdev"2
vgcreate vg00 "$target_blockdev"2
lvcreate -n root   -L 10G vg00
lvcreate -n var    -L 10G vg00
lvcreate -n boot   -L 1G  vg00
lvcreate -n swap00 -l 639 vg00

for vol in /dev/mapper/vg00-{root,var,boot}; do
    mkfs.ext4 "$vol"
done

mount /dev/mapper/vg00-root $BOOTSTRAP_DIR
mkdir $BOOTSTRAP_DIR/var;  mount /dev/mapper/vg00-var  $BOOTSTRAP_DIR/var
mkdir $BOOTSTRAP_DIR/boot; mount /dev/mapper/vg00-boot $BOOTSTRAP_DIR/boot
mkswap /dev/mapper/vg00-swap00
swapon /dev/mapper/vg00-swap00

curl "http://$SALT_MASTER/arch-mirrorlist" > /etc/pacman.d/mirrorlist
pacstrap $BOOTSTRAP_DIR base grub salt-zmq

genfstab -p $BOOTSTRAP_DIR >> $BOOTSTRAP_DIR/etc/fstab
cat > $BOOTSTRAP_DIR/etc/mkinitcpio.conf << EOF
MODULES=""
BINARIES=""
FILES=""
HOOKS="base udev autodetect modconf block lvm2 filesystems keyboard fsck"
EOF
echo "nameserver $DNS_SERVER" > $BOOTSTRAP_DIR/etc/resolv.conf
echo "search $DOMAIN" >> $BOOTSTRAP_DIR/etc/resolv.conf
echo "$fqdn" > $BOOTSTRAP_DIR/etc/hostname
echo "$fqdn" > $BOOTSTRAP_DIR/etc/salt/minion_id

curl "http://$SALT_MASTER/arch-chrootstrap.sh" > "$BOOTSTRAP_DIR/chrootstrap"
chmod +x "$BOOTSTRAP_DIR/chrootstrap"
arch-chroot "$BOOTSTRAP_DIR" '/chrootstrap'
rm -f "$BOOTSTRAP_DIR/chrootstrap"
