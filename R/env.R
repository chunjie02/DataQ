required_packages <- function() {
  c(
    "targets",
    "tarchetypes",
    "visNetwork",
    "dplyr", 
    "ggplot2", 
    "readr",
    "yaml"
  )
}

activate_local_lib <- function(lib = file.path(getwd(), "r_libs")) {
  dir.create(lib, recursive = TRUE, showWarnings = FALSE)
  lib <- normalizePath(lib, winslash = "/", mustWork = TRUE)
  .libPaths(unique(c(lib, .libPaths())))
  invisible(lib)
}

ensure_packages <- function(packages, lib = file.path(getwd(), "r_libs"), repos = getOption("repos")) {
  activate_local_lib(lib)
  if (
    is.null(repos) ||
      length(repos) == 0 ||
      any(is.na(repos)) ||
      any(repos %in% c("@CRAN@", ""))
  ) {
    repos <- c(CRAN = "https://cloud.r-project.org")
  }
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    install.packages(missing, lib = normalizePath(lib, winslash = "/", mustWork = TRUE), repos = repos)
    message("Packages ", paste(missing, collapse = ", "), " are installed in local library: ", lib)
  }
  invisible(TRUE)
}

load_env <- function(lib = file.path(getwd(), "r_libs"), install = TRUE, load = TRUE, repos = getOption("repos")) {
  pkgs <- required_packages() 
  if (install) ensure_packages(pkgs, lib = lib, repos = repos)
  activate_local_lib(lib)
  if (load) {
    for (p in pkgs) {
      library(p, character.only = TRUE)
    }
  }
  e <- new.env(parent = baseenv())
  e$lib <- normalizePath(lib, winslash = "/", mustWork = TRUE)
  e$packages <- pkgs
  e
}

