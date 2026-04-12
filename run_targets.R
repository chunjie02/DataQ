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
print(Config)

tar_make(ImportData)
tar_load(ImportData)
names(ImportData[[1]])


tar_make(Stat_Outlier)
tar_load(Stat_Outlier)
names(Stat_Outlier[[1]])

## check dependencies
tar_visnetwork()

