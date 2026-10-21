# source("~/.config/karabiner/scripts/karabiner.R")
# build_karabiner()                     # 生成临时 JSON
# build_karabiner(output = config_file) # 应用配置，原文件备份为 .bak
build_karabiner <- function(input = config_file, output = tempfile(fileext = ".json")) {
  config <- jsonlite::fromJSON(path.expand(input), simplifyVector = FALSE)
  profile <- which(vapply(
    config$profiles, function(x) identical(x$name, "k380"), logical(1)
  ))
  stopifnot(length(profile) == 1L)
  config$profiles[[profile]]$complex_modifications$rules <- rules

  output <- path.expand(output)
  staging <- tempfile(tmpdir = dirname(output))
  on.exit(unlink(staging))
  jsonlite::write_json(config, staging, auto_unbox = TRUE, pretty = TRUE)
  if (file.exists(output)) {
    stopifnot(file.copy(output, paste0(output, ".bak"), overwrite = TRUE))
  }
  stopifnot(file.rename(staging, output))
  message("已生成：", normalizePath(output))
  invisible(output)
}

config_file <- path.expand("~/.config/karabiner/karabiner.json")

# 快捷键写作「修饰键+键码」；单元素数组必须保留为 list。
key <- function(x) {
  if (is.list(x)) {
    return(x)
  }
  parts <- strsplit(x, "+", fixed = TRUE)[[1]]
  c(
    list(key_code = tail(parts, 1)),
    if (length(parts) > 1) list(modifiers = as.list(head(parts, -1)))
  )
}

remap <- function(from, to, cond = NULL, optional = "caps_lock", ...) {
  from <- key(from)
  from$modifiers <- c(
    if (length(from$modifiers)) list(mandatory = from$modifiers),
    list(optional = as.list(optional))
  )
  c(
    list(type = "basic", from = from, to = list(key(to))),
    if (length(cond)) list(conditions = cond),
    list(...)
  )
}

maps <- function(from, to, ...) {
  unname(Map(function(f, t) remap(f, t, ...), from, to))
}

rule <- function(description, manipulators) {
  list(description = description, manipulators = manipulators)
}

app <- function(ids, unless = FALSE) {
  list(
    type = paste0("frontmost_application_", if (unless) "unless" else "if"),
    bundle_identifiers = as.list(paste0("^", gsub(".", "\\.", ids, fixed = TRUE), "$"))
  )
}

k380 <- list(
  type = "device_if",
  identifiers = list(list(is_keyboard = TRUE, product_id = 45890L, vendor_id = 1133L))
)
windows <- app("com.microsoft.rdc.macos")
not_windows <- app("com.microsoft.rdc.macos", TRUE)
editors <- app(c("com.microsoft.VSCode", "dev.zed.Zed"))
not_editors <- app(c("com.microsoft.VSCode", "dev.zed.Zed"), TRUE)
right <- c("right_control", "right_command", "right_option")
arrows <- c("left_arrow", "right_arrow", "up_arrow", "down_arrow")
pages <- paste0("left_command+", c("page_up", "page_down", "home", "end"))

# 保留现有规则及匹配顺序，不调整优先级。
rules <- list(
  rule("所有设备：Command+L → Control+L", maps("command+l", "left_control+l")),
  rule(
    "所有设备：右 Ctrl / Command → 行首，右 Option → 行尾（Windows App 使用 Home / End）",
    c(
      maps(right, c("home", "home", "end"), list(windows), optional = "any"),
      maps(
        right, paste0("left_command+", c("left_arrow", "left_arrow", "right_arrow")),
        optional = "any"
      )
    )
  ),
  rule(
    "所有键盘：F11 → Control+Command+F，F7 → Option+S（排除 Windows App）",
    maps(
      c("f11", "f7"), c("left_control+left_command+f", "left_option+s"),
      list(not_windows),
      optional = c("fn", "caps_lock")
    )
  ),
  rule(
    "单按左 Option 打开 Apps，组合键不变（排除 Windows App）",
    list(remap(
      "left_option", "left_option", list(not_windows),
      to_if_alone = list(list(shell_command = "/usr/bin/open -a /System/Applications/Apps.app"))
    ))
  ),
  rule(
    "Excel：Ctrl+Enter → Ctrl+Option+Enter（兼容 K380 Ctrl/Command 对调）",
    list(
      remap(
        "control+return_or_enter", "left_control+left_option+return_or_enter",
        list(app("com.microsoft.Excel"))
      ),
      remap(
        "left_command+return_or_enter", "left_control+left_option+return_or_enter",
        list(app("com.microsoft.Excel"), k380)
      )
    )
  ),
  rule(
    "K380：Finder 中 Del → Command+Backspace（移到废纸篓）",
    list(remap(
      "delete_forward", c(key("left_command+delete_or_backspace"), list(`repeat` = FALSE)),
      list(k380, app("com.apple.finder")),
      optional = c("fn", "caps_lock")
    ))
  ),
  rule(
    "Word：Command+←/→ 翻页，Command+↑/↓ 到文档首尾（兼容 K380 Ctrl/Command 对调）",
    c(
      maps(paste0("command+", arrows), pages, list(app("com.microsoft.Word"))),
      maps(paste0("control+", arrows), pages, list(app("com.microsoft.Word"), k380))
    )
  ),
  rule(
    "Command+H：VS Code / Zed → Command+Option+F，其他应用禁用",
    list(
      remap("command+h", "left_command+left_option+f", list(editors)),
      remap("command+h", "vk_none", list(not_editors))
    )
  ),
  rule(
    "K380：Windows App 左 Command → Alt、左 Option → Win，左 Ctrl 不变",
    maps(
      c("left_command", "left_option"), c("left_option", "left_command"),
      list(k380, windows),
      optional = "any"
    )
  ),
  rule(
    "K380：左 Ctrl ↔ Command（排除 Windows App）",
    maps(
      c("left_control", "left_command"), c("left_command", "left_control"),
      list(k380, not_windows),
      optional = "any"
    )
  ),
  rule(
    "K380：VS Code / Zed 中 Cmd+右 Alt → 文档首，Cmd+右 Ctrl → 文档尾（兼容 Mac 键码及左 Ctrl/Command 对调）",
    maps(
      c(
        "control+right_command", "command+right_command", "control+right_control",
        "control+right_option", "command+right_control", "command+right_option"
      ),
      paste0("left_command+", c("home", "home", "end", "end", "end", "end")),
      list(k380, editors),
      optional = c("caps_lock", "shift")
    )
  )
)
