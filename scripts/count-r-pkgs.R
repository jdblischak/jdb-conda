# Count the number of R packages available on Anaconda Cloud
#
# R - 3.5.1
# platforms - linux-64, osx-64, win-64
# channels - r, conda-forge, bioconda

suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("jsonlite"))
suppressPackageStartupMessages(library("purrr"))
suppressPackageStartupMessages(library("stringr"))

# The order of the platforms and channels matters. Rearranging will break the
# code.
platforms <- c("linux-64", "osx-64", "win-64")
channels <- c("r", "conda-forge", "bioconda")
totals <- matrix(nrow = length(channels), ncol = length(platforms))
rownames(totals) <- channels
colnames(totals) <- platforms


for (platform in platforms) {
  anaconda <- system2(command = "conda",
                      args = c("search", "--json", "--override-channels",
                               "-c conda-forge", "-c bioconda", "-c r",
                               "--platform", platform, "'^r-*'"),
                      stdout = TRUE)
  anaconda <- fromJSON(anaconda)

  # Add bioconductor packages
  if (platform != "win-64") {
    bioc <- system2(command = "conda",
                    args = c("search", "--json", "--override-channels",
                             "-c conda-forge", "-c bioconda", "-c r",
                             "--platform", platform, "'^bioconductor-*'"),
                    stdout = TRUE)
    bioc <- fromJSON(bioc)
    anaconda <- c(anaconda, bioc)
  }

  pkgs <- anaconda %>%
    map_df(`[`, c("name", "version", "build", "channel", "platform", "subdir")) %>%
    mutate(channel = basename(dirname(channel)),
           channel = factor(channel, levels = channels)) %>%
    filter(str_detect(build, "^r351")) %>%
    group_by(channel) %>%
    distinct(name) %>%
    summarize(total = n())
  # This only works b/c I ordered Windows to be the third platform and bioconda
  # to be the third channel.
  totals[seq_along(pkgs$total), platform] <- pkgs$total
}
Sys.Date()
# [1] "2018-12-06"
totals
#             linux-64 osx-64 win-64
# r                382    381    375
# conda-forge     1139   1141   1102
# bioconda        1180   1000     NA
