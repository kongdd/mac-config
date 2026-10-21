# NAS 配置

源码位于 `~/.config/nas/`。脚本直接从本目录运行；plist按下表安装。

| 配置 | 生效方式 |
| --- | --- |
| `mkdir-mnt.sh` | root launchd 任务直接调用；修改后下次运行生效 |
| `mkdir-mnt.plist` | `install-nas-root.sh` 安装至 `/Library/LaunchDaemons/` 并重载任务 |
| `mount-nas.sh` | 用户 launchd 任务直接调用；修改后下次运行生效 |
| `mount-nas.plist` | 软链接至 `~/Library/LaunchAgents/`；修改后重载用户任务 |

root 任务 `mkdir-mnt` 开机运行，创建 `/mnt` 临时文件系统及 `x/y/z/o` 目录；用户任务 `mount-nas` 登录时运行并每 60 秒检查挂载。任务改名时，先卸载旧任务并移除旧 plist，再加载新任务。

四个 SMB3 共享挂载如下：`GitHub → /mnt/x`、`CMIP6 → /mnt/z`、`Researches → /mnt/y`、`CUG-hydro → /mnt/o`。凭据从 `/etc/samba/credentials` 读取，不纳入 Git；重启会重建挂载目录，不影响 NAS 数据。

```ini
# /etc/nsmb.conf
[kong-nas]
protocol_vers_map=4
```

```bash
# /etc/synthetic.conf
mnt
```
