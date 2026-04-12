load_config <- function() {
    lconfig <- list()
    lconfig <- yaml::read_yaml("config/analysis_spec.yaml")$analysis_spec
    return(lconfig)
}
