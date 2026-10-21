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

# 与现有 JSON 保持一致：四空格缩进、对象键排序、短结构紧凑输出。
format_json <- function(x, depth = 0L, field = "") {
  if (!is.list(x)) {
    return(as.character(jsonlite::toJSON(x, auto_unbox = TRUE, null = "null", digits = NA)))
  }
  object <- !is.null(names(x))
  if (object) x <- x[order(names(x))]
  brackets <- if (object) c("{", "}") else c("[", "]")
  if (!length(x)) return(paste0(brackets, collapse = ""))

  fields <- if (object) names(x) else rep(field, length(x))
  values <- Map(function(value, name) format_json(value, depth + 1L, name), x, fields)
  parts <- if (object) {
    paste0(vapply(names(x), function(name) {
      as.character(jsonlite::toJSON(name, auto_unbox = TRUE))
    }, character(1)), ": ", values)
  } else unlist(values, use.names = FALSE)
  compact <- !any(grepl("\n", parts, fixed = TRUE)) &&
    (if (object) length(x) == 1L else field != "bundle_identifiers")
  if (compact) {
    content <- paste(parts, collapse = ", ")
    if (object) content <- paste0(" ", content, " ")
    return(paste0(brackets[1], content, brackets[2]))
  }
  paste0(
    brackets[1], "\n", strrep("    ", depth + 1L),
    paste(parts, collapse = paste0(",\n", strrep("    ", depth + 1L))),
    "\n", strrep("    ", depth), brackets[2]
  )
}

build_karabiner <- function(rules, input = config_file, output = tempfile(fileext = ".json")) {
  input <- path.expand(input)
  output <- path.expand(output)
  config <- jsonlite::fromJSON(input, simplifyVector = FALSE)
  profile <- which(vapply(
    config$profiles, function(x) identical(x$name, "k380"), logical(1)
  ))
  stopifnot(length(profile) == 1L)
  config$profiles[[profile]]$complex_modifications$rules <- rules
  text <- format_json(config)
  stopifnot(jsonlite::validate(text))

  staging <- tempfile(tmpdir = dirname(output))
  on.exit(unlink(staging))
  writeBin(charToRaw(enc2utf8(text)), staging)
  # if (file.exists(output)) {
  #   stopifnot(file.copy(output, paste0(output, ".bak"), overwrite = TRUE))
  # }
  stopifnot(file.rename(staging, output))
  message("已生成：", normalizePath(output))
  invisible(output)
}

k380 <- list(
  type = "device_if",
  identifiers = list(list(is_keyboard = TRUE, product_id = 45890L, vendor_id = 1133L))
)
