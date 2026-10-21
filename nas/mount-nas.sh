#!/bin/sh
# Wait for the local boot daemon; never mount through the legacy symlink.
[ -d /mnt/z ] && [ ! -L /mnt ] || exit 0

/usr/bin/nc -G 2 -z kong-nas 445 >/dev/null 2>&1 || exit 0   # 超时不挂载

# 从 Samba 凭据文件读取 username= 和 password=。
username=$(sed -n 's/^username=//p' /etc/samba/credentials)
# 将密码中的 @ 编码为 %40，不修改原始凭据。
password=$(sed -n 's/^password=//p' /etc/samba/credentials | sed 's/@/%40/g')

# 直接在连接地址中传入账号密码；特殊字符需 URL 编码。
option="soft,filemode=0775,dirmode=0775"
auth="//${username}:${password}@kong-nas"

# All shares use SMB3; kong-nas has protocol_vers_map=4 in /etc/nsmb.conf.
# Linux 需改用 `mount -t cifs`
/sbin/mount_smbfs -s -o "$option" "$auth/GitHub"     /mnt/x
/sbin/mount_smbfs -s -o "$option" "$auth/CMIP6"      /mnt/z
/sbin/mount_smbfs -s -o "$option" "$auth/Researches" /mnt/y
/sbin/mount_smbfs -s -o "$option" "$auth/CUG-hydro"  /mnt/o
