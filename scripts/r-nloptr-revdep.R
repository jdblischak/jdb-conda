#!/usr/bin/env Rscript

# How many conda-forge R packages rely on r-nloptr?

library("devtools")
library("dplyr")
library("jsonlite")
library("magrittr")
library("purrr")

# CRAN packages that depend on nloptr
nloptr_cran <- revdep("nloptr",
                      dependencies = c("Depends", "Imports", "LinkingTo"),
                      recursive = TRUE) %>%
  tolower() %>% paste0("r-", .)
cat(sprintf("%d CRAN packages depend on nloptr\n\n", length(nloptr_cran)))
# 510 CRAN packages depend on nloptr

cmd <- "conda search --json --override-channels -c conda-forge r-*"
anaconda <- fromJSON(system(cmd, intern = TRUE))
conda_forge <- anaconda %>%
  map_df(`[`, c("name", "channel")) %>%
  filter(grepl("^r-", name),
         channel == "conda-forge") %>%
  select(name) %>% unlist %>% unique
cat(sprintf("%d R packages are available via conda-forge\n\n",
            length(conda_forge)))
# 616 R packages are available via conda-forge

conda_forge_nloptr <- intersect(conda_forge, nloptr_cran)
cat(sprintf("%d conda-forge R packages depend on nloptr\n\n",
            length(conda_forge_nloptr)))
# 11 conda-forge R packages depend on nloptr
cat(conda_forge_nloptr, sep = "\n")
# r-aer
# r-afex
# r-arm
# r-bradleyterry2
# r-car
# r-factominer
# r-lme4
# r-lmertest
# r-mlmrev
# r-pbkrtest
# r-ptw
