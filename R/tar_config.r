load_config <- function() {
  
  # conver spec to yaml
  df <- read.csv("config/analysis_spec.csv", encoding = "UTF-8", stringsAsFactors = FALSE)
  rows <- lapply(1:nrow(df), function(i) {
    as.list(df[i, ])
  })

  output <- list(analysis_spec = rows)
  yaml::write_yaml(output, "config/analysis_spec.yaml")
  
# spec <- list()
#  spec <- yaml::read_yaml("config/analysis_spec.yaml")$analysis_spec
  return(output$analysis_spec)
}
