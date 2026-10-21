# NAS NFSv4 名称映射

2026-10-20 配置；仅映射名称，不改文件 UID/GID、密码或权限，不用 FUSE。

## 原理与配置

- 两端统一域为 `kong-nas.pi.invalid`（无需 DNS）：Mac `/etc/nfs.conf` 的 `nfs.client.default_nfs4domain` 及运行时 sysctl；NAS `/etc/idmapd.conf`。
- NAS 在 `/etc/systemd/system/nfs-idmapd.service.d/20-pi-name-mapping.conf` 中，于服务启动前设置 `nfs4_disable_idmapping=N`。
- Mac 添加用户别名 `kong/admin → kongdd`、组别名 `users → staff`、`root → wheel`；别名也参与本机账户解析。

已验证 `/mnt/x`、`/mnt/z` 临时文件显示 `kongdd:staff`（501:20），硬链接正常，测试文件已清理；真实 root 属主仍显示 `root:wheel`。

注意：exports 未改，两个共享仍将请求映射至 NAS admin；名称映射影响 NAS 全部 NFSv4 服务，未映射账户可能显示 nobody，不会统一映射为 kongdd。

## 回滚

依次在 NAS、Mac 的授权终端执行；原配置备份在对应目录，不改 NAS 数据文件。

```sh
# NAS
sudo /bin/sh /var/backups/pi-nfs4-idmap-01a15805/server.sh rollback

# Mac
sudo /bin/bash /var/root/pi-nfs4-idmap-01a15805/client.sh rollback
```
