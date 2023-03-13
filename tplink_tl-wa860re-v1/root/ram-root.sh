#!/bin/sh
#
# @see https://forum.openwrt.org/t/extroot-using-z-ram-drive-with-the-backup-restore-option-over-nfs-share/32725
NEW_OVERLAY=/tmp/overlay
NEW_ROOT=/tmp/root
OLD_ROOT=$1

do_logger() {
  logger -t ram-root "$1"
}

# @see https://stackoverflow.com/a/67458/35946
[ -n "$OLD_ROOT" ] || {
    echo "Error: missing OLD_ROOT parameter."
    exit 1
}

# Avoid multiple ram-roots.
[ ! -d "$OLD_ROOT" ] || {
    echo "Error: OLD_ROOT already exists."
    exit 1
}

# Engage.
STEPS=6

# Step 1, start.
do_logger "[1/${STEPS}] Setup overlay"
mount -t tmpfs -o rw,nosuid,noatime tmpfs $NEW_OVERLAY
mkdir $NEW_ROOT ${NEW_OVERLAY}/upper ${NEW_OVERLAY}/work
mount -t overlay -o noatime,lowerdir=/,upperdir=${NEW_OVERLAY}/upper,workdir=${NEW_OVERLAY}/work ram-root $NEW_ROOT

# Step 2.
do_logger "[2/${STEPS}] Bind old root to ${OLD_ROOT}"
mkdir ${NEW_ROOT}${OLD_ROOT}
mount -o bind / ${NEW_ROOT}${OLD_ROOT}

# Step 3.
do_logger "[3/${STEPS}] Pivot into ${NEW_ROOT}"
mount -o noatime,nodiratime,move /proc ${NEW_ROOT}/proc
pivot_root $NEW_ROOT ${NEW_ROOT}${OLD_ROOT}

# Step 4.
do_logger "[4/${STEPS}] Move system directory mounts"
for dir in /dev /sys /tmp; do
    mount -o noatime,nodiratime,move ${OLD_ROOT}${dir} ${dir};
done

# Step 5.
do_logger "[5/${STEPS}] Mount new overlay"
mount -o noatime,nodiratime,move $NEW_OVERLAY /overlay

# Step 6, done.
do_logger "[6/${STEPS}] Clean up"
rmdir $NEW_ROOT $NEW_OVERLAY
