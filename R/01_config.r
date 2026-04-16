#' Load analysis specification
#'
#' Load analysis specification from a CSV file. Spec can be created from EDC ALS file.
#'
#' @description
#' `r lifecycle::badge("maturing")`
#' This function loads an analysis specification CSV file
#' and converts it into a structured list for downstream data processing.
#'
#' @param Spec File name of .csv file (e.g., analysis_spec.csv).
#'   The file should be placed under the `config/` folder.
#'   Expected columns: CRF, DataField, DataType, Outlier, Missing, Digit, Variance.
#'
#' @return A list, with length equal to the number of rows in the specification file.
#'
#' @export


load_config <- function(Spec) {
  
  Spec_file <- file.path("config", Spec)
  
  df <- read.csv(Spec_file, encoding = "UTF-8", stringsAsFactors = FALSE)
  rows <- lapply(1:nrow(df), function(i) {
    as.list(df[i, ])
  })

  output <- list(analysis_spec = rows)
  
  return(output$analysis_spec)
}
