#!/bin/bash 
set -e 

# Default files
BOOTFS=rpi-sensor1-sensor-bootfs.tar.gz
ROOTFS=rpi-rootfs.tar

function showUsage {
	echo ""
	echo "Usage:"
	echo "     $1 <sd device> [<bootfs-image> [<rootfs-image> [<appfs-image>]]]"
	echo ""
	echo "Default bootfs-image is $BOOTFS"
	echo "Default rootfs-image is $ROOTFS"
	echo "Default appfs-image is $APPFS"
	echo ""
}


function do_info {
	echo ""
	echo "**********************************************"
	echo "  $1"
	echo "**********************************************"
	echo ""
}

function do_exit {
	echo "ERROR: $1"
	exit 1
}

if [ $# -lt 1 -o $# -gt 4 ]; then
	showUsage `basename $0`
	exit 1
fi

MEDIA=$1
PART_BOOTFS="$1"p1
PART_ROOTFS="$1"p2
PART_ROOTFS2="$1"p3
if [ $# -gt 1 ]; then
	BOOTFS=$2
fi
if [ $# -gt 2 ]; then
	ROOTFS=$3
fi

#set -o errexit
[ -r $BOOTFS ] || do_exit "$BOOTFS not found"
[ -n $MEDIA ] || do_exit "$MEDIA not found"
[ -r $ROOTFS ] || do_exit "$ROOTFS not found"
sudo test -w $MEDIA || do_exit "$MEDIA not writable"


#######################
# Get access to media
grep $MEDIA /proc/mounts | awk '{print $1}' | xargs -rn1 sudo umount


do_info "Creating partitions on $MEDIA"

dd if=/dev/zero of=$MEDIA bs=512 count=1
sudo sfdisk -R $MEDIA

sudo sfdisk -uM $MEDIA <<EOF
1,20,0C,*
21,420,83
441,420,83
EOF
sleep 1
sudo sfdisk -R $MEDIA

do_info "Creating filesystems"

mkfs.vfat -n boot $PART_BOOTFS
mkfs.ext4 -L rootfs $PART_ROOTFS
mkfs.ext4 -L rootfs2 $PART_ROOTFS2

do_info "Installing rootfs"
temp=`mktemp -d`
sudo mount -t ext4 $PART_ROOTFS $temp
sudo tar --strip-components=1 -xf $ROOTFS -C $temp
sync
sudo umount $temp
sleep 2

do_info "Installing bootfs"
sudo mount -t vfat $PART_BOOTFS $temp
sudo tar --strip-components=1 -xzf $BOOTFS -C $temp
sync
sudo umount $temp
sleep 2

do_info "Cleaning up"
rm -rf $temp

do_info "SD card created"
