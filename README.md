# 1 mac系统的推荐软件

- `karabiner`     : 快捷键自定义，配合罗技K380（其他则需要自己适配快捷键定义），**以贴近Windows体验**
- `snipaste`      : 截图、贴图工具（多系统适配）
- `Maccy`         : 类似于win+v历史粘贴板
- `Rectangle`     : 窗口快捷键定义，**以贴近Windows体验**
- `BetterDisplay` : 显示器色彩校准，以及高分辨显示器150%缩放
- `sumatrapdf`    : 经典pdf软件（占用资源极小），无文件锁定（绘图的时候不需要先关闭再打开，调图时非常高效），需自行编译安装<https://github.com/sumatrapdfreader/sumatrapdf>
- `skim`          : pdf软件，弥补sumatrapdf打印功能缺失
- `Office全家桶`    : <https://github.com/alsyundawy/Microsoft-Office-For-MacOS>
- `Windows app`   : 远程Windows
- `rustdesk`      : 被远程
- `智谱autoglm`    : 语音输入法

## 1.1 编程必备
- `kitty`         : 支持显示image的终端，可在pi中贴图、显示图
- `herdr`
- `zed`,`vscode`, `sublime-merge`

k380键盘需配合<https://github.com/kongdd/k380_fn.rs>使用。

## 1.2 安装方式
能通过命令安装的软件

```bash
brew install kitty kerdr git sublime-merge
```

# 2 如何使用本repo的配置

```bash
git clone https://github.com/kongdd/mac-config ~/.config
```
