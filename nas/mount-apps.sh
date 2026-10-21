#!/bin/bash
# 将 NAS 微信文件直接挂载到微信原目录，避免链接越出沙盒。
set -euo pipefail

# 挂载 SMB 共享；已挂载时跳过，复用已有认证会话。
mount_smb() {
  local source="$1" target="$2"

  if ! /sbin/mount | grep -F "$source on $target (smbfs," >/dev/null; then
    mkdir -p "$target" || return
    /sbin/mount_smbfs -N -o nobrowse "$source" "$target"
  fi
}

## wechat
app="$HOME/Library/Containers/com.tencent.xinWeChat/Data"
source="//kong@kong-nas/Researches/sync/wechat/file"
target="$app/Documents/xwechat_files/wxid_udml2ofatec521_485a/msg/file"
mount_smb "$source" "$target"
