 # df <- dplyr::tibble(
 #    age  = rnorm(100, 30, 10)
 #    )
 #  var = "age"


Outlier_IQR <- function(df, var){
  
  # ------------------------------
  # IQR method: Q1/Q3 ± 1.5 * IQR
  # ------------------------------
  qs <- stats::quantile(df[[var]], probs = c(0.25, 0.75), na.rm = TRUE)
  
  iqr <- qs[[2]] - qs[[1]]
  lower <- qs[[1]] - 1.5 * iqr
  upper <- qs[[2]] + 1.5 * iqr
  
  iqr_df <- df %>%
    dplyr::mutate(
      iqr_outlier = dplyr::case_when(
        .data[[var]] < lower | .data[[var]] > upper ~ TRUE,
        TRUE ~ FALSE
      )
    )

  iqr_df_ab <- iqr_df %>% dplyr::filter (iqr_outlier == TRUE)  
  
  iqr_indicator <- any(iqr_df$iqr_outlier, na.rm = TRUE)
  
  bp<- graphics::boxplot(df[[var]], range = 1.5, na.rm = TRUE, main = "Outlier based on IQR", plot = FALSE)
# graphics::boxplot(df[[var]], range = 1.5, na.rm = TRUE, main = "Outlier based on IQR")
# plot<- graphics::bxp(bp)
  
  comb<- list (
    iqr_indicator =iqr_indicator,
    iqr_df_ab = iqr_df_ab,
    plot = bp
  )
  
  
  return(comb)
}
