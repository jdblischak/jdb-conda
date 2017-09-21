#!/usr/bin/env Rscript

# Script to detect updates to packages I help maintain.

pkgs <- character()
vers <- character()

# beeswarm
# https://github.com/conda-forge/r-beeswarm-feedstock
pkgs <- c(pkgs, "beeswarm")
vers <- c(vers, "0.2.3")

# callr
# https://github.com/conda-forge/r-callr-feedstock
pkgs <- c(pkgs, "callr")
vers <- c(vers, "1.0.0")

# covr
# https://github.com/conda-forge/r-covr-feedstock
pkgs <- c(pkgs, "covr")
vers <- c(vers, "3.0.0")

# cowplot
# https://github.com/conda-forge/r-cowplot-feedstock
pkgs <- c(pkgs, "cowplot")
vers <- c(vers, "0.8.0")

# devtools
# https://github.com/conda-forge/r-devtools-feedstock
pkgs <- c(pkgs, "devtools")
vers <- c(vers, "1.13.2")

# etrunct
# https://github.com/conda-forge/r-etrunct-feedstock
pkgs <- c(pkgs, "etrunct")
vers <- c(vers, "0.1")

# flux
# https://github.com/conda-forge/r-flux-feedstock
pkgs <- c(pkgs, "flux")
vers <- c(vers, "0.3-0")

# ggbeeswarm
# https://github.com/conda-forge/r-ggbeeswarm-feedstock
pkgs <- c(pkgs, "ggbeeswarm")
vers <- c(vers, "0.6.0")

# ggsci
# https://github.com/conda-forge/r-ggsci-feedstock
pkgs <- c(pkgs, "ggsci")
vers <- c(vers, "2.7")

# git2r
# https://github.com/conda-forge/r-git2r-feedstock
pkgs <- c(pkgs, "git2r")
vers <- c(vers, "0.19.0")

# gridGraphics
# https://github.com/conda-forge/r-gridgraphics-feedstock
pkgs <- c(pkgs, "gridGraphics")
vers <- c(vers, "0.2")

# SQUAREM
# https://github.com/conda-forge/r-squarem-feedstock
pkgs <- c(pkgs, "SQUAREM")
vers <- c(vers, "2016.8-2")

# vipor
# https://github.com/conda-forge/r-vipor-feedstock
pkgs <- c(pkgs, "vipor")
vers <- c(vers, "0.4.5")

stopifnot(length(pkgs) == length(vers))

available <- available.packages(repos = "http://cran.case.edu/")

for (i in seq_along(pkgs)) {
  latest <- available[pkgs[i], "Version"]
  if (latest != vers[i]) {
    m <- sprintf("Package %s has been updated to version %s (from %s)",
                 pkgs[i], latest, vers[i])
    cran <- paste0("https://cran.r-project.org/package=", pkgs[i])
    recipe <- paste0("https://github.com/conda-forge/r-", pkgs[i],
                     "-feedstock/blob/master/recipe/meta.yaml")
    # Download source to get sha256
    destfile <- paste0("/tmp/", pkgs[i], "_", latest, ".tar.gz")
    download.file(url = paste0("https://cran.r-project.org/src/contrib/",
                               pkgs[i], "_", latest, ".tar.gz"),
                  destfile = destfile, quiet = TRUE)
    sha256 <- system(sprintf("sha256sum %s", destfile), intern = TRUE)
    sha256 <- substr(sha256, 1, 64)
    unlink(destfile)
    cat(m, cran, recipe, sha256, "---", sep = "\n")
  }
}
