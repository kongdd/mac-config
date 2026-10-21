#!/bin/sh
set -eu

# 手动以 root 部署；开机任务不直接执行用户可写的源码。
[ "$(id -u)" -eq 0 ] || { echo "请以 root 运行此脚本。" >&2; exit 1; }
cd "$(dirname "$0")"
/bin/sh -n local.prepare-mnt.sh
/usr/bin/plutil -lint local.prepare-mnt.plist
/usr/bin/install -o root -g wheel -m 755 local.prepare-mnt.sh /Library/PrivilegedHelperTools/local.prepare-mnt.sh
/usr/bin/install -o root -g wheel -m 644 local.prepare-mnt.plist /Library/LaunchDaemons/local.prepare-mnt.plist
if /bin/launchctl print system/local.prepare-mnt >/dev/null 2>&1; then
    /bin/launchctl bootout system/local.prepare-mnt
fi
/bin/launchctl bootstrap system /Library/LaunchDaemons/local.prepare-mnt.plist
