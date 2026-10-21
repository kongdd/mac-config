#!/bin/sh
set -eu

# 开机后在 /mnt 挂载 tmpfs，已挂载则跳过。
if ! /sbin/mount | /usr/bin/grep -Fq ' on /mnt ('; then
    /sbin/mount_tmpfs -s 8m -n 128 -o nosuid,nodev,nobrowse /mnt
    /bin/chmod 755 /mnt
fi

# 仅补建缺失目录并设置 UID:GID（参数 $1:$2）；不修改已有目录或共享。
# SMB 挂载由用户级 mount-nas 任务负责。
for target in /mnt/x /mnt/z /mnt/y /mnt/o; do
    [ -d "$target" ] && continue
    /bin/mkdir -m 755 "$target"
    /usr/sbin/chown "$1:$2" "$target"
done
