#' Identify Outliers Using IQR and Z-Score Methods
#'
#' @description
#' `r lifecycle::badge("maturing")`
#' Detect outliers in numeric variables from EDC datasets based on a pre-defined
#' specification. Both IQR (1.5 * IQR rule) and Z-score (±3 SD rule) are used.
#'
#' @param ImportData A list, each element must contain:
#'   \itemize{
#'     \item \code{CRF}: Dataset name
#'     \item \code{DataField}: Target variable name
#'     \item \code{DataType}: Data type (NUM/CHAR)
#'     \item \code{Outlier}: Logical flag indicating whether to check outliers
#'     \item \code{Data}: Data frame containing subject-level data
#'   }
#'
#' @return A list, each element contains:
#'   \itemize{
#'     \item \code{CRF}: CRF name
#'     \item \code{DataField}: Analyzed variable
#'     \item \code{iqr_df}: Data frame with IQR outlier flag
#'     \item \code{iqr_indicator}: TRUE if any IQR outlier exists
#'     \item \code{z_df}: Data frame with Z-score outlier flag
#'     \item \code{z_indicator}: TRUE if any Z-score outlier exists
#'   }
#'
#' @details
#' This function processes only variables where:
#' \itemize{
#'   \item \code{Outlier} is TRUE (supports "TRUE", "T", "Y", "1")
#'   \item \code{DataField} is numeric
#' }
#'
#' @export
#'

outlier <- function(ImportData) {
  
  filtered_list <- ImportData %>%
    purrr::keep(~ !is.null(.x[["Outlier"]]) && .x[["Outlier"]] == "Y")

  Out_list <- filtered_list %>%
    purrr::imap(function(item, i) {  
    
      
      item$iqr_outlier <- Outlier_IQR(item$Data, item$DataField)
      
      return(item)
    })

    
    return(Out_list)
}
