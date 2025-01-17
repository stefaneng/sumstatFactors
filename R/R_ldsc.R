#'@export
R_ldsc <- function(Z_hat, ldscores, weights){
  M <- ncol(Z_hat)
  stopifnot(class(ldscores) == "numeric")
  stopifnot(length(ldscores) == nrow(Z_hat))
  res <- expand.grid(trait1 = 1:M, trait2 = 1:M) %>%
         filter(trait1 <= trait2)
  vals <- map2_dbl(res$trait1, res$trait2, function(i, j){
          zz <- Z_hat[,i]*Z_hat[,j]
          f <- lm(zz ~ ldscores, weights = weights)
          return(f$coefficients[1])})
  res$value <- vals
  res_copy <- filter(res, trait1 != trait2) %>%
    rename(n1c = trait2, n2c = trait1) %>%
    rename(trait1 = n1c, trait2 = n2c)

  cov_mat <- bind_rows(res, res_copy)  %>%
    reshape2::dcast(trait1 ~ trait2, value.var = "value")
  Re <- as.matrix(cov_mat[,-1])
  return(Re)
}

#'@export
R_ldsc2 <- function(Z_hat, ldscores, ld_size, N, return_gencov = FALSE){
  M <- ncol(Z_hat)
  J <- nrow(Z_hat)
  stopifnot(class(ldscores) == "numeric")
  stopifnot(length(ldscores) == J)
  if("matrix" %in% class(N)){
    stopifnot(nrow(N) == J & ncol(N) == M)
  }else if(class(N) == "numeric"){
    stopifnot(length(N) == M)
    N <- matrix(rep(N, each = J), nrow = J)
  }

  h2 <- lapply(1:M, function(m){
    snp_ldsc(ld_score = ldscores, ld_size = ld_size, chi2 = Z_hat[,m]^2, sample_size = N[,m], blocks = NULL)
  })
  res <- expand.grid(trait1 = 1:M, trait2 = 1:M) %>%
    filter(trait1 <= trait2)

  vals <- map2(res$trait1, res$trait2, function(i, j){
    if(i == j) return(h2[[i]])
    rg <- ldsc_rg(ld_score = ldscores, ld_size = ld_size,
            z1 = Z_hat[,i], z2 = Z_hat[,j],
            h2_1 = h2[[i]], h2_2 = h2[[j]],
            sample_size_1 = N[,i], sample_size_2 = N[,j],
            blocks = NULL)
    c(rg[["int"]], rg[["gencov"]])
  })

  val_int <- map(vals, 1) %>% unlist()

  res$value <- val_int
  res_copy <- filter(res, trait1 != trait2) %>%
    rename(n1c = trait2, n2c = trait1) %>%
    rename(trait1 = n1c, trait2 = n2c)

  cov_mat <- bind_rows(res, res_copy)  %>%
    reshape2::dcast(trait1 ~ trait2, value.var = "value")
  Re <- as.matrix(cov_mat[,-1])

  if(!return_gencov){return(Re)}

  res_gencov <- expand.grid(trait1 = 1:M, trait2 = 1:M) %>%
    filter(trait1 <= trait2)
  res_gencov$value <- map(vals, 2) %>% unlist()
  res_g_copy <- filter(res_gencov, trait1 != trait2) %>%
    rename(n1c = trait2, n2c = trait1) %>%
    rename(trait1 = n1c, trait2 = n2c)

  gcov_mat <- bind_rows(res_gencov, res_g_copy)  %>%
    reshape2::dcast(trait1 ~ trait2, value.var = "value")
  Rg <- as.matrix(gcov_mat[,-1])
  return(list("Re" = Re, "Rg" = Rg))

}


