#!/bin/sh
set -eu

# 手动以 root 安装系统 plist 并重载任务；脚本直接使用 .config 中的版本。
[ "$(id -u)" -eq 0 ] || { echo "请以 root 运行此脚本。" >&2; exit 1; }
cd "$(dirname "$0")"
/bin/sh -n mkdir-mnt.sh
/usr/bin/plutil -lint mkdir-mnt.plist
/usr/bin/install -o root -g wheel -m 644 mkdir-mnt.plist /Library/LaunchDaemons/mkdir-mnt.plist

/bin/launchctl bootout system/mkdir-mnt 2>/dev/null || true
/bin/launchctl bootstrap system /Library/LaunchDaemons/mkdir-mnt.plist

## mount-nas.plist采用软链接安装
# ln -sf ~/.config/nas/mount-nas.plist ~/Library/LaunchAgents/mount-nas.plist
# launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/mount-nas.plist
