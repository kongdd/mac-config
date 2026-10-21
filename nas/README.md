# NAS 文件的生效位置

这里的“可以放在本目录”指：**程序实际使用这里的文件，修改后无需复制到其他目录。** 仅保存源码不算生效；macOS 不会自动加载 `~/.config/nas/`。

## 可以直接从本目录使用的脚本

| 文件 | 生效方式 |
| --- | --- |
| `mount-nas.sh` | 用户任务直接调用此处脚本；修改后下次调用生效 |
| `mkdir-mnt.sh` | root 任务直接调用 `/Users/kongdd/.config/nas/mkdir-mnt.sh`；修改后下次开机或重载任务时生效 |

两个脚本均无需复制到其他目录，但对应的 launchd 任务必须先安装并加载。

## 仅放在本目录不会生效的文件

| 文件 | 实际生效路径 | 如何生效 |
| --- | --- | --- |
| `mkdir-mnt.plist` | `/Library/LaunchDaemons/mkdir-mnt.plist` | 安装为 root 所有的副本，加载系统任务；仅在加载时执行 |
| `mount-nas.plist` | `~/Library/LaunchAgents/mount-nas.plist` | 可软链接到本目录；首次安装或修改 plist 后需重载用户任务 |
| `nsmb.conf` | `/etc/nsmb.conf` | SMB 客户端读取系统路径；影响后续新建连接 |
| `synthetic.conf` | `/etc/synthetic.conf` | 修改系统文件后重启生效 |
| `credentials` | `/etc/samba/credentials` | 挂载脚本从此处读取；不得纳入 Git |
| `nfs.conf` | `/etc/nfs.conf` | Mac NFS 客户端配置，详见 [NFS.md](NFS.md) |

`nsmb.conf`、`synthetic.conf` 目前是**本目录指向系统文件**的软链接；系统读取的仍是 `/etc/` 下的文件，不是扫描本目录。

## 部署工具与说明

- `install-nas-root.sh`：手动以 root 执行，仅安装系统 plist 并重载 `mkdir-mnt`；修改系统 plist 后需重新执行，不再复制脚本。
- root 任务直接执行本目录的 `mkdir-mnt.sh`；修改脚本会影响下一次 root 执行。
- 重命名已加载的任务时，先卸载旧 Label 并移除旧 plist，再加载新任务。
- `NFS.md`：NFS 配置说明，不参与运行。

## 其他文件
- NAS 配置源码统一存放于 `~/.config/nas/`；`synthetic.conf` 和 `nsmb.conf` 是指向 `/etc/` 下同名系统文件的链接，Git 仅记录链接，不记录目标内容。
- root 任务 `local.mkdir-mnt` 开机运行一次，调用 `/Library/PrivilegedHelperTools/mkdir-mnt.sh`，建立 `/mnt` 的 tmpfs 和 `x/y/z/o` 目录；修改源码后以 root 运行 `install-nas-root.sh` 部署并重载。
- 用户任务 `local.mount-nas` 登录及每 60 秒调用本目录的 `mount-nas.sh`；`~/Library/LaunchAgents/local.mount-nas.plist` 链接到本目录，修改 plist 后需重载任务。
- 四个共享均通过 SMB3 连接 `kong-nas`：`GitHub → /mnt/x`、`CMIP6 → /mnt/z`、`Researches → /mnt/y`、`CUG-hydro → /mnt/o`。
- 凭据仅从 `/etc/samba/credentials` 读取，不迁移、不纳入 Git；重启后挂载目录自动重建，NAS 数据不受影响。

## 其他配置

```bash
# /etc/nsmb.conf
[kong-nas]
protocol_vers_map=4

# /etc/synthetic.conf
mnt
```
