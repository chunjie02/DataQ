report <- function(Stat_Outlier) {
  dir.create("output", recursive = TRUE, showWarnings = FALSE)
  
  rmarkdown::render(    
    input = "config/report template.Rmd",
    output_file = "output/demo.html",
    params =  list(Stat_Outlier = Stat_Outlier))
  
}
