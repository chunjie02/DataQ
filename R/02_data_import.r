#' Load and attach EDC data based on analysis specification
#'
#' @description
#' `r lifecycle::badge("maturing")`
#' Load pre-saved .rda datasets from the `data/` folder according to a configuration list,
#' extract specified data fields, attach subject ID and site ID columns, and return
#' an enriched configuration list with extracted data attached.
#'
#' @param Config A list generated from analysis specification (usually from analysis_spec.csv),
#'   each element must contain at least \code{CRF}, \code{DataField}, and \code{DataType}.
#' @param subjid_col Column name for subject ID (e.g., \code{"SUBJID"}).
#' @param siteid_col Column name for site ID (e.g., \code{"SITEID"}).
#'
#' @return An enriched list with the same length as input \code{Config}.
#'   Each element gains a new component \code{$Data}, which is a data frame containing:
#'   \itemize{
#'     \item \code{subjid}: Subject ID
#'     \item \code{siteid}: Site ID
#'     \item The target data field specified in the configuration
#'   }
#'
#' @details
#' This function:
#' 1. Loads \code{.rda} files from the \code{data/} folder (filename matches CRF name)
#' 2. Caches datasets to avoid redundant loading
#' 3. Extracts target fields from corresponding datasets
#' 4. Returns NA-filled columns if fields are missing (with warning)
#' 5. Automatically converts factors and logical values to character
#'
#' @export
#'

  get_edc_data <- function(Config, subjid_col, siteid_col) {

  # Return empty list if Config is empty
  if (is.null(Config) || length(Config) == 0) {
    return(list())
  }

  #----------------------------------------------------------------------------
  # Helper: safely extract a scalar value from a list
  #----------------------------------------------------------------------------
  get_scalar <- function(x, name) {
    if (!is.list(x)) return(NA_character_)
    v <- x[[name]]
    if (is.null(v) || length(v) != 1) return(NA_character_)
    v <- as.character(v)
    if (!nzchar(v)) return(NA_character_)
    v
  }

  #----------------------------------------------------------------------------
  # Helper: load .rda dataset and return the correct object
  #----------------------------------------------------------------------------
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

    # Use object matching CRF name if available; otherwise use the only object
    if (crf %in% obj_names) {
      return(temp_env[[crf]])
    } else if (length(obj_names) == 1) {
      return(temp_env[[obj_names[1]]])
    } else {
      stop("Multiple objects found; cannot select automatically: ",
           paste(obj_names, collapse = ", "))
    }
  }

  #----------------------------------------------------------------------------
  # Cache loaded datasets to avoid reloading
  #----------------------------------------------------------------------------
  dataset_cache <- new.env(parent = emptyenv())

  #----------------------------------------------------------------------------
  # Process each row in the configuration, load data
  #----------------------------------------------------------------------------
  for (i in seq_along(Config)) {
    crf        <- get_scalar(Config[[i]], "CRF")
    data_field <- get_scalar(Config[[i]], "DataField")
    data_type  <- toupper(get_scalar(Config[[i]], "DataType"))

    # Validate required fields
    if (is.na(crf)) stop("Config row ", i, " is missing CRF.")
    if (is.na(data_field)) stop("Config row ", i, " is missing DataField.")

    # Load dataset if not already cached
    if (!exists(crf, envir = dataset_cache)) {
      assign(crf, load_dataset(crf), envir = dataset_cache)
    }
    data <- get(crf, envir = dataset_cache)

    # Skip non-data.frame objects
    if (!is.data.frame(data)) {
      warning("Loaded object is not a data frame: ", crf)
      Config[[i]]$Data <- NULL
      next
    }

    #--------------------------------------------------------------------------
    # Extract subject ID and site ID (explicit columns)
    #--------------------------------------------------------------------------
    subjid <- if (subjid_col %in% names(data))  as.character(data[[subjid_col]]) else NA_character_
    siteid <- if (siteid_col %in% names(data))  as.character(data[[siteid_col]]) else NA_character_


    #--------------------------------------------------------------------------
    # Extract target data field
    #--------------------------------------------------------------------------
    if (data_field %in% names(data)) {
      raw_value <- data[[data_field]]
      
      # Safe conversion for NUM type: handle non-numeric values
      if (identical(data_type, "NUM")) {
        
        # Clean whitespace and empty strings
        clean_val <- trimws(as.character(raw_value))
        clean_val[clean_val == ""] <- NA_character_
        
        # Convert to numeric, count failures
        field_value <- suppressWarnings(as.numeric(clean_val))
        n_fail <- sum(!is.na(clean_val) & is.na(field_value), na.rm = TRUE)
        
        # Warn if some values cannot be converted
        if (n_fail > 0) {
          warning(
            "Non-numeric values found in ", crf, "$", data_field,
            " (", n_fail, " records converted to NA)"
          )
        }
        
      } else {
        # Character type: keep as is
        field_value <- as.character(raw_value)
      }
      
    } else {
      # Field missing: fill NA according to type
      field_value <- if (identical(data_type, "NUM")) {
        NA_real_
      } else {
        NA_character_
      }
      warning("Field not found in ", crf, ": ", data_field)
    }
    

    #--------------------------------------------------------------------------
    # Build output data frame
    #--------------------------------------------------------------------------
    out_df <- data.frame(
      subjid = subjid,
      siteid = siteid,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    out_df[[data_field]] <- field_value

    # Attach data back to configuration
    Config[[i]]$Data <- out_df
  }

  Config
}