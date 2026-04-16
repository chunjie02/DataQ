
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
  

  p<-  ggplot2::ggplot(df, ggplot2::aes(y = .data[[var]])) +
    ggplot2::geom_boxplot(
      fill = "lightblue",       
      color = "darkblue",        
      outlier.color = "darkblue",
      outlier.fill = "white", 
      outlier.shape = 21,        
      linetype = "solid",  
      staplewidth = 0.8    
    ) +
    ggplot2::labs(
      title = "Outlier based on IQR",
      x = "",  
      y = ""   
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title  = ggplot2::element_text(hjust = 0.5, size = 20, face = "bold"), # 标题居中放大
      axis.text.y = ggplot2::element_text(size = 18), 
      axis.text.x = ggplot2::element_blank(), 
      panel.grid  = ggplot2::element_blank(),   
      panel.border = ggplot2::element_rect(
        color = "black",   
        fill = NA,          
        linewidth = 1       
      )
    )
  
   comb<- list (
          iqr_df = iqr_df,
          iqr_df_ab= iqr_df_ab,
          iqr_indicator =iqr_indicator,
          plot = p
                  )
  
  
  return(comb)
}