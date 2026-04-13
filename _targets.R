
library(targets)
library(tarchetypes)

tar_source("R")
tar_option_set(packages = c("dplyr"))

list(
  tar_target(Config, load_config()),
  tar_target(ImportData, get_clindata_raw(Config)),
  tar_target(Stat_Outlier,  outlier (ImportData)),
  # tar_target(Stat_Missing,  missing (ImportData)),
  # tar_target(Stat_Digit,    digit (ImportData)),
  # tar_target(Stat_IntraVar, intra_var (ImportData)),  
  tar_target(Reporting, report (
      Stat_Outlier
      #, Stat_Missing, Stat_Digit, Stat_IntraVar 
      ))

)