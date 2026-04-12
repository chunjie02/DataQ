

get_clindata_raw <- function(Config) {
  if (is.null(Config) || length(Config) == 0) {
    return(list())
  }

  get_scalar <- function(x, name) {
    if (!is.list(x)) return(NA_character_)
    v <- x[[name]]
    if (is.null(v) || length(v) != 1) return(NA_character_)
    v <- as.character(v)
    if (!nzchar(v)) return(NA_character_)
    v
  }

  load_dataset <- function(crf) {
    file_path <- file.path(getwd(), "data", paste0(crf, ".rda"))
    if (!file.exists(file_path)) {
      stop("Data file not found: ", file_path)
    }

    temp_env <- new.env(parent = emptyenv())
    load(file_path, envir = temp_env)
    obj_names <- ls(temp_env, all.names = TRUE)
    if (length(obj_names) == 0) {
      stop("No objects found in file: ", file_path)
    }

    obj_to_use <- NULL
    if (crf %in% obj_names) {
      obj_to_use <- crf
    } else if (length(obj_names) == 1) {
      obj_to_use <- obj_names[[1]]
    } else {
      stop(
        "Multiple objects found and none matches the CRF name; cannot decide which to use: ",
        file_path,
        "; objects: ",
        paste(obj_names, collapse = ", ")
      )
    }

    temp_env[[obj_to_use]]
  }

  dataset_cache <- new.env(parent = emptyenv())

  for (i in seq_along(Config)) {
    row_spec <- Config[[i]]
    crf <- get_scalar(row_spec, "CRF")
    data_field <- get_scalar(row_spec, "DataField")
    data_type <- toupper(get_scalar(row_spec, "DataType"))

    if (is.na(crf)) stop("Config row ", i, " is missing CRF.")
    if (is.na(data_field)) stop("Config row ", i, " is missing DataField.")

    if (!exists(crf, envir = dataset_cache, inherits = FALSE)) {
      assign(crf, load_dataset(crf), envir = dataset_cache)
    }
    data <- get(crf, envir = dataset_cache, inherits = FALSE)

    value <- NULL
    if (is.data.frame(data)) {
      resolve_col <- function(df, nm) {
        nms <- names(df)
        hit <- which(tolower(nms) == tolower(nm))
        if (length(hit) > 0) return(nms[[hit[[1]]]])
        NA_character_
      }

      subjid_col <- resolve_col(data, "subjid")
      siteid_col <- resolve_col(data, "siteid")

      subjid <- if (!is.na(subjid_col)) data[[subjid_col]] else rep(NA_character_, nrow(data))
      siteid <- if (!is.na(siteid_col)) data[[siteid_col]] else rep(NA_character_, nrow(data))
      if (is.factor(subjid)) subjid <- as.character(subjid)
      if (is.factor(siteid)) siteid <- as.character(siteid)

      if (data_field %in% names(data)) {
        field_value <- data[[data_field]]
        if (is.factor(field_value)) field_value <- as.character(field_value)
        if (is.logical(field_value)) field_value <- as.character(field_value)
        value <- data.frame(
          subjid = subjid,
          siteid = siteid,
          stringsAsFactors = FALSE,
          check.names = FALSE
        )
        value[[data_field]] <- field_value
      } else {
        field_value <- if (identical(data_type, "NUM")) rep(NA_real_, nrow(data)) else rep(NA_character_, nrow(data))
        value <- data.frame(
          subjid = subjid,
          siteid = siteid,
          stringsAsFactors = FALSE,
          check.names = FALSE
        )
        value[[data_field]] <- field_value
        warning("Field not found in ", crf, ": ", data_field)
      }
    } else {
      warning("Loaded object is not a data.frame; cannot extract by DataField: ", crf)
    }

    row_spec$Data <- value
    Config[[i]] <- row_spec
  }

  Config
}
