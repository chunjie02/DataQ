source("R/env.R")
env <- load_env()

# Inspect the pipeline
tar_manifest(fields = all_of("command"))
tar_visnetwork( targets_only = TRUE)

# Run the all pipelines
targets::tar_make()

# Run single pipeline
targets::tar_make(Config)
tar_load(Config)

tar_make(ImportData)
tar_load(ImportData)

tar_make(Stat_Outlier)
tar_load(Stat_Outlier)

tar_make(Reporting)

## check dependencies
tar_visnetwork()

