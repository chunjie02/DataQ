
library(targets)
library(tarchetypes)
tar_source("R")
tar_option_set(packages = c(    

))

list(
  tar_target(ImportData, get_clindata_raw())
  # tar_target(cfg, load_config("config/config.yaml")),
  # tar_target(sources, tar_group(dplyr::group_by(dplyr::bind_rows(cfg$sources), id)), iteration = "group"),
  # tar_target(method_registry, build_method_registry(cfg)),
  # tar_target(raw, ingest_source(list(id = sources$id[1], type = sources$type[1], path = sources$path[1])), pattern = map(sources)),
  # tar_target(std, standardize_data(raw = raw, cfg = cfg), pattern = map(raw)),
  # tar_target(method_results, run_methods(std = std, registry = method_registry), pattern = map(std)),
  # tar_target(score, score_review(method_results = method_results, cfg = cfg), pattern = map(method_results)),
  # tar_target(report_path, render_report(std = std, method_results = method_results, score = score), pattern = map(std, method_results, score), format = "file")

)
