#'@export
gfa_default_parameters <- function(){
  list(
  kmax = NULL,
  ridge_penalty = 0,
  min_ev = 1e-5,
  max_lr_percent = 0.99,
  lr_zero_thresh = 1e-3,
  max_iter = 1000,
  extrapolate = TRUE,
  ebnm_fn_F = flash_ebnm(prior_family = "point_normal", optmethod = "nlm"),
  ebnm_fn_L = flash_ebnm(prior_family = "point_normal", optmethod = "nlm"),
  init_fn = flash_greedy_init_default,
  fixed_truncate = Inf, duplicate_check_thresh = 0.5
  )

}

