outlier <- function(ImportData) {

  # input：ImportData(list), contain keys of CRF / DataField / DataType / Outlier / Data（data.frame）
  # output：Outlier (list)；contain keys of  CRF / Datafield / iqr_df(data.frame) / iqr_indicator /z_df (data.frame)/z_indicatorO
  # Calculate outlier, for ImportData (items)  where Outlier = TRUE and DataField == numeric 时

  # check non-empty ImportData
  if (is.null(ImportData) || length(ImportData) == 0 ) return(list())

  for (i in seq_along(ImportData)) {
    Outlier <- list ()
    j=1
 i=1
    if (toupper(trimws (ImportData[[i]]$Outlier )) %in% c("TRUE", "T", "Y", "1") ) {
      df <- ImportData[[i]]$Data
      var <- ImportData[[i]]$DataField

      if (is.numeric(df[[var]])) {

        # IQR: out of（Q1-1.5*IQR, Q3+1.5*IQR)
          qs <- stats::quantile((df[[var]]), probs = c(0.25, 0.75), na.rm = TRUE)
          iqr <- qs[[2]] - qs[[1]]
          lower <- qs[[1]] - 1.5 * iqr
          upper <- qs[[2]] + 1.5 * iqr
          iqr_df <- df %>% 
            dplyr::mutate(
              iqr_outlier = dplyr::case_when(
                .data[[var]] < lower | .data[[var]] > upper ~ TRUE,
                TRUE ~ FALSE
              ))
          output <- list()
          output$CRF <- ImportData[[i]]$CRF
          output$DataField <- ImportData[[i]]$DataField
          output$iqr_df <- iqr_df 
          output$iqr_indicator <- nrow(iqr_df %>% dplyr::filter(iqr_outlier == TRUE)) [1] > 0
        
          # Z-score: out of +/- 3 SD 
          z_df <- df %>% dplyr::mutate(
            scale = as.numeric (scale(.data[[var]])),
            z_outlier = dplyr::case_when(
                abs(scale) >3 ~ TRUE,
                TRUE ~ FALSE)
            )
          output$z_df <- z_df 
          output$z_indicator <- nrow(z_df %>% dplyr::filter(z_outlier == TRUE)) [1] > 0
          
          ## stack output
          Outlier[[j]] <-output
          j <- j + 1
      } 
     }
  }
     return(Outlier)   
}

