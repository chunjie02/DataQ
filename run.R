source("R/env.R")
env <- load_env()

# Inspect the pipeline
tar_manifest(fields = all_of("command"))
tar_visnetwork()
tar_visnetwork( targets_only = TRUE)

# Run the pipeline
targets::tar_make()
targets::tar_read(ImportData)

##

