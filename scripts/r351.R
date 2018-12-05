# 2019-09-25
#
# Check the number of conda-forge R packages built for R 3.5.1
#
# Adapted from the function find_pkgs_for_rerender from rerender-r-packages.
# Updated for conda 4.5.11 (the search query requires an asterisk now and also
# the channel returns the entire URL instead of just the name).
#
# https://github.com/bioconda/bioconda-recipes/issues/8947#issuecomment-424348194

suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("jsonlite"))
suppressPackageStartupMessages(library("purrr"))
suppressPackageStartupMessages(library("stringr"))

platform <- "linux-64"
anaconda <- system2(command = "conda",
                    args = c("search", "--json", "--override-channels",
                             "-c conda-forge", "--platform", platform, "'^r-*'"),
                    stdout = TRUE)
anaconda <- fromJSON(anaconda)
pkgs <- anaconda %>%
  map_df(`[`, c("name", "version", "build", "channel", "platform", "subdir")) %>%
  mutate(channel = basename(dirname(channel))) %>%
  filter(channel == "conda-forge") %>%
  group_by(name) %>%
  summarize(r351 = any(str_detect(build, "^r351")))
Sys.Date()
# [1] "2018-12-05"
table(pkgs$r351)
#
# FALSE  TRUE
#   198  1139
