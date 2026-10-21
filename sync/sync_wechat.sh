#!/bin/bash
# 节省系统盘空间：将微信文件迁移到 NAS，并挂载到原目录。
set -e

src="/Users/kongdd/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files/wxid_udml2ofatec521_485a/msg/file"
dst="/mnt/y/sync/wechat/file"

# 已直接挂载时无需迁移，避免删除 NAS 上的文件。
if /sbin/mount | grep -Fq " on $src (smbfs,"; then
  exit 0
fi

if [ -d "$src" ] && [ ! -L "$src" ]; then
  # 仅向已挂载的 NAS 迁移，避免误写到本地挂载点。
  /sbin/mount | /usr/bin/grep -Fq " on /mnt/y (smbfs,"
  mkdir -p "$dst"
  rsync -a8 --progress --remove-source-files "$src/" "$dst/"
  find "$src" -depth -type d -empty -exec rmdir {} \;
fi

## 将 NAS 直接挂载到原目录，不使用软链接。
# exec /bin/bash /Users/kongdd/.config/nas/mount-apps.sh
