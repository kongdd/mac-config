#!/bin/sh
# Wait for the local boot daemon; never mount through the legacy symlink.
[ -d /mnt/z ] && [ ! -L /mnt ] || exit 0

/usr/bin/nc -G 2 -z kong-nas 445 >/dev/null 2>&1 || exit 0   # 超时不挂载

# All shares use SMB3; kong-nas has protocol_vers_map=4 in /etc/nsmb.conf.
/usr/bin/expect "$HOME/.config/bin/mount-kong-nas.exp" GitHub /mnt/x
/usr/bin/expect "$HOME/.config/bin/mount-kong-nas.exp" CMIP6 /mnt/z
/usr/bin/expect "$HOME/.config/bin/mount-kong-nas.exp" Researches /mnt/y
/usr/bin/expect "$HOME/.config/bin/mount-kong-nas.exp" CUG-hydro /mnt/o
