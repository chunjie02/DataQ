
# ==============================================
# 【你唯一要改的地方】混合版本控制
# ==============================================
required_packages <- function() {
  list(
    # --------------------------
    # CRAN 固定版本
    # --------------------------
    # "dplyr"       = "1.1.4",
    # "yaml"        = "2.3.8",
    # "stringi"     = "1.8.3",
    
    # --------------------------
    # CRAN 任意版本（不锁定）
    # --------------------------
    "targets"     = TRUE,
    "tarchetypes" = TRUE,
    "visNetwork"  = TRUE,
    "dplyr"       = TRUE, 
    "ggplot2"     = TRUE, 
    "readr"       = TRUE,
    "yaml"        = TRUE,
    "favawesome"  = TRUE,
    "rsvg"        = TRUE,
    "rmarkdown"   = TRUE,
    "stringi"     = TRUE, 
    "stringr"     = TRUE, 
    "gt"          = TRUE,
    "htmltools"   = TRUE,
    "usethis"     = TRUE,
    "devtools"    = TRUE, 
    "roxygen2"    = TRUE


    
    # --------------------------
    # GitHub 固定版本
    # --------------------------

    #"gsm.core"      = "Gilead-BioStats/gsm.core@v1.1.6",

    )
}

# ==============================================
# 本地库管理
# ==============================================
activate_local_lib <- function(lib = file.path(getwd(), "r_libs")) {
  dir.create(lib, recursive = TRUE, showWarnings = FALSE)
  lib <- normalizePath(lib, winslash = "/", mustWork = TRUE)
  .libPaths(lib)
  invisible(lib)
}

# ==============================================
# 安装 CRAN 指定版本
# ==============================================
install_cran_version <- function(pkg, version, lib, repos) {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes", lib = lib, repos = repos)
  }
  remotes::install_version(
    pkg, version, lib = lib, repos = repos, upgrade = "never"
  )
}

# ==============================================
# 从 GitHub 安装
# ==============================================
install_github_ref <- function(full_ref, lib) {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes", repos = "https://cloud.r-project.org")
  }
  remotes::install_github(
    repo = full_ref, lib = lib, upgrade = "never", force = TRUE
  )
}

# ==============================================
# 检查版本是否匹配
# ==============================================
is_version_correct <- function(pkg, required_ver) {
  if (!requireNamespace(pkg, quietly = TRUE)) return(FALSE)
  current_ver <- as.character(packageVersion(pkg))
  return(current_ver == required_ver)
}

# ==============================================
# 核心：自动安装缺失/不匹配的包
# ==============================================
ensure_packages <- function(pkg_list, lib = "r_libs", repos = getOption("repos")) {
  activate_local_lib(lib)
  
  if (is.null(repos) || any(is.na(repos)) || "@CRAN@" %in% repos) {
    repos <- c(CRAN = "https://cloud.r-project.org")
  }
  
  for (pkg in names(pkg_list)) {
    val <- pkg_list[[pkg]]
    
    # 1. GitHub 包
    if (is.character(val) && grepl("/", val)) {
      if (!requireNamespace(pkg, quietly = TRUE)) {
        message("Installing from GitHub: ", pkg)
        install_github_ref(val, lib = lib)
      }
    }
    
    # 2. CRAN 固定版本
    else if (is.character(val)) {
      if (!is_version_correct(pkg, val)) {
        message("Installing fixed version: ", pkg, " = ", val)
        install_cran_version(pkg, val, lib = lib, repos = repos)
      }
    }
    
    # 3. CRAN 任意版本（TRUE = 不指定）
    else if (isTRUE(val)) {
      if (!requireNamespace(pkg, quietly = TRUE)) {
        message("Installing latest version: ", pkg)
        install.packages(pkg, lib = lib, repos = repos)
      }
    }
  }
}

# ==============================================
# 一键加载环境
# ==============================================
load_env <- function(lib = "r_libs", install = TRUE, load = TRUE) {
  pkgs <- required_packages()
  if (install) ensure_packages(pkgs, lib = lib)
  activate_local_lib(lib)
  
  if (load) {
    for (p in names(pkgs)) {
      library(p, character.only = TRUE)
    }
  }
  
  env <- new.env(parent = baseenv())
  env$lib <- lib
  env$packages <- pkgs
  invisible(env)
}

