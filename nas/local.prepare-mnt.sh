#!/bin/sh
set -eu

is_mounted() {
    /sbin/mount | /usr/bin/grep -Fq " on $1 ("
}

# /mnt 本身已存在；tmpfs 和子目录需要在每次开机时重建。
if ! is_mounted /mnt; then
    /sbin/mount_tmpfs -s 8m -n 128 -o nosuid,nodev,nobrowse /mnt
    /bin/chmod 755 /mnt
fi

# 每次补建缺失目录；已有目录和已挂载共享保持不变。
for target in /mnt/x /mnt/z /mnt/y /mnt/o; do
    is_mounted "$target" && continue
    [ -d "$target" ] && continue
    /bin/mkdir -m 755 "$target"
    is_mounted "$target" || /usr/sbin/chown "$1:$2" "$target"
done

# 所有共享由用户级 local.mount-kong-nas 通过 SMB3 挂载。
