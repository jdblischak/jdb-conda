#!/usr/bin/env Rscript

# Helper script to identify conda-forge R packages that have more recent
# versions released on CRAN.
#
# Strategy:
#
# 1. Obtain list of R packages on CRAN
# 2. Obtain list of R packages in conda-forge channel on Anaconda Cloud
# 3. Intersect packages and determine which are outdated
# 4. Future idea: Create conda recipes for updated packages
# 5. Future idea: Submit updated recipes as Pull Requests to individual feedstocks

suppressPackageStartupMessages(library("dplyr"))
library("jsonlite")
suppressPackageStartupMessages(library("purrr"))
library("stringr")

# 1. Obtain list of R packages on CRAN -----------------------------------------

cran <- available.packages() %>%
  as.data.frame %>%
  select(package = Package, version = Version) %>%
  mutate(package = paste0("r-", str_to_lower(package)),
         version = as.numeric_version(version))

# 2. Obtain list of R packages in conda-forge channel on Anaconda Cloud --------

# conda-search currently doesn't respect --override-channels. Packages in
# defaults or the channels in .condarc are always included:
# https://github.com/conda/conda/issues/5717
cmd <- "conda search --json --override-channels -c conda-forge r-*"
anaconda <- fromJSON(system(cmd, intern = TRUE)) %>%
  map_df(`[`, c("name", "version", "build", "channel")) %>%
  filter(grepl("^r-", name),
         channel == "conda-forge",
         grepl("^r3.3.2", build)) %>%
  mutate(version = str_replace_all(version, "_", "-")) %>%
  group_by(name) %>%
  summarize(version = max(as.numeric_version(version))) %>%
  rename(package = name)
stopifnot(nrow(anaconda) == length(unique(anaconda$package)))

# 3. Intersect packages and determine which are outdated -----------------------

conda_forge <- merge(anaconda, cran, by = "package",
                     suffixes = c(".conda", ".cran")) %>%
  mutate(outdated = version.conda < version.cran)
cat(sprintf("%d of %d CRAN R packages on conda-forge are outdated.\n",
            sum(conda_forge$outdated), nrow(conda_forge)))

# 4. Future idea: Create conda recipes for updated packages --------------------

# Could adapt code from https://github.com/bgruening/conda_r_skeleton_helper

# 5. Future idea: Submit updated recipes as PRs to individual feedstocks -------

# There is already a helper script that does this for PyPI packages.
# https://github.com/conda-forge/conda-forge.github.io/blob/master/scripts/tick_my_feedstocks.py
#
# Discussion on helper scripts for updating packages:
# https://github.com/conda-forge/conda-forge.github.io/issues/369
# https://github.com/conda-forge/conda-forge.github.io/pull/375
# https://github.com/conda-forge/conda-forge.github.io/issues/51
