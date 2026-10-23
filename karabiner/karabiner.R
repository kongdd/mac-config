#!/usr/bin/env -S arf -f
## MAC Karabiner-Elements Configs
source("~/.config/karabiner/main_pkgs.R")

windows <- app("com.microsoft.rdc.macos")
not_windows <- app("com.microsoft.rdc.macos", TRUE)

editors <- app(c("com.microsoft.VSCode", "dev.zed.Zed"))
not_editors <- app(c("com.microsoft.VSCode", "dev.zed.Zed"), TRUE)

# 专用规则优先于通用规则，避免右侧按键被提前匹配。
rules <- list(
  rule("所有设备：Command+L → Control+L", maps(c("command+l" = "left_control+l"))),
  rule(
    "select to file home/end (k380/editors)",
    maps(
      c(
        "command+right_command" = "left_command+home", # home: mac
        "control+right_command" = "left_command+home", # home: win -> mac
        "command+right_option" = "left_command+end", # end : mac, k380 `right_ctrl` is `right_option`
        "control+right_control" = "left_command+end" # end : win -> mac
      ),
      cond = list(k380, editors),
      optional = c("caps_lock", "shift")
    )
  ),
  rule(
    "所有设备：右 Ctrl / Command → 行首，右 Option → 行尾（Windows App 使用 Home / End）",
    c(
      maps(
        c("right_command" = "home", "right_option" = "end"),
        cond = list(windows), optional = "any"
      ),
      maps(
        c(
          # "right_control" = "right_command+left_arrow", #? 远程调试 win -> mac
          "right_command" = "right_command+left_arrow",
          "right_option" = "right_command+right_arrow"
        ),
        optional = "any"
      )
    )
  ),
  rule(
    "所有键盘：F11 → Control+Command+F，F7 → Option+S（排除 Windows App）",
    maps(
      c("f11" = "left_control+left_command+f", "f7" = "left_option+s"),
      cond = list(not_windows),
      optional = c("fn", "caps_lock")
    )
  ),
  rule(
    "单按左 Option 打开 Apps，组合键不变（排除 Windows App）",
    list(remap(
      "left_option", "left_option",
      cond = list(not_windows),
      to_if_alone = list(list(shell_command = "/usr/bin/open -a /System/Applications/Apps.app"))
    ))
  ),
  rule(
    "Excel：Ctrl+Enter → Ctrl+Option+Enter（兼容 K380 Ctrl/Command 对调）",
    list(
      remap(
        "control+return_or_enter", "left_control+left_option+return_or_enter",
        cond = list(app("com.microsoft.Excel"))
      ),
      remap(
        "left_command+return_or_enter", "left_control+left_option+return_or_enter",
        cond = list(app("com.microsoft.Excel"), k380)
      )
    )
  ),
  rule(
    "K380：Finder 中 Del → Command+Backspace（移到废纸篓）",
    list(remap(
      "delete_forward", c(key("left_command+delete_or_backspace"), list(`repeat` = FALSE)),
      cond = list(k380, app("com.apple.finder")),
      optional = c("fn", "caps_lock")
    ))
  ),
  rule(
    "Word：Command+←/→ 翻页，Command+↑/↓ 到文档首尾（兼容 K380 Ctrl/Command 对调）",
    c(
      maps(
        c(
          "command+left_arrow" = "left_command+page_up",
          "command+right_arrow" = "left_command+page_down",
          "command+up_arrow" = "left_command+home",
          "command+down_arrow" = "left_command+end"
        ),
        cond = list(app("com.microsoft.Word"))
      ),
      maps(
        c(
          "control+left_arrow" = "left_command+page_up",
          "control+right_arrow" = "left_command+page_down",
          "control+up_arrow" = "left_command+home",
          "control+down_arrow" = "left_command+end"
        ),
        cond = list(app("com.microsoft.Word"), k380)
      )
    )
  ),
  rule(
    "Command+H：VS Code / Zed → Command+Option+F，其他应用禁用",
    list(
      remap("command+h", "left_command+left_option+f", cond = list(editors)),
      remap("command+h", "vk_none", cond = list(not_editors))
    )
  ),
  rule(
    "K380：Windows App 左 Command → Alt、左 Option → Win，左 Ctrl 不变", # windows app passed
    maps(
      c("left_command" = "left_option", "left_option" = "left_command"),
      cond = list(k380, windows),
      optional = "any"
    )
  ),
  rule(
    "K380：左 Ctrl ↔ Command（排除 Windows App）",
    maps(
      c("left_control" = "left_command", "left_command" = "left_control"),
      cond = list(k380, not_windows),
      optional = "any"
    )
  )
)

config_file <- path.expand("~/.config/karabiner/karabiner.json")
build_karabiner(rules, output = config_file)
