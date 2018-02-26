#!/usr/bin/env Rscript

# The CircleCI token for a feedstock expires after some time. I wasn't able to
# find an exact time, but @jakirkham thinks it is about a year. This script
# finds any conda-forge feedstocks for R recipes that have not had their token
# created or updated in the last year, and then opens an Issue to instruct
# @conda-forge-admin to update the token.
#
# https://github.com/conda-forge/r-lubridate-feedstock/issues/2#issuecomment-368015908
# https://conda-forge.org/docs/webservice.html#conda-forge-admin-please-update-circle

suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("gh"))
suppressPackageStartupMessages(library("jsonlite"))
suppressPackageStartupMessages(library("lubridate"))
suppressPackageStartupMessages(library("purrr"))
suppressPackageStartupMessages(library("stringr"))

# Time for CircleCI tokens to expire
expiration <- as.difftime(365, units = "days")
phrase <- "@conda-forge-admin, please update circle"

# Get conda-forge R packages built for linux-64
anaconda <- system2(command = "conda",
                    args = c("search", "--json", "--override-channels",
                             "-c conda-forge", "--platform", "linux-64", "^r-"),
                    stdout = TRUE)
anaconda <- fromJSON(anaconda)
pkgs <- anaconda %>%
  map_df(`[`, c("name", "version", "build", "channel", "platform", "subdir")) %>%
  filter(channel == "conda-forge") %>%
  select(name) %>%
  unlist() %>%
  unique()
length(pkgs)

# Remove packages that have been created in the last year
feedstocks <- paste0(pkgs, "-feedstock")
get_repo <- function(repo) {
  gh("/repos/:owner/:repo", owner = "conda-forge", repo = repo)
}

repos <- map(feedstocks, get_repo)
created_at <- repos %>%
  map_chr("created_at") %>%
  as_datetime
now <- Sys.time()
lifetime <- now - created_at
feedstocks <- feedstocks[lifetime > expiration]

# Remove packages that have had their CircleCI token updated within the last year
# https://developer.github.com/v3/issues/#list-issues-for-a-repository
get_issues <- function(repo) {
  gh("/repos/:owner/:repo/issues", owner = "conda-forge", repo = repo,
     state = "all")
}

issues_per_feedstock_all <- map(feedstocks, get_issues)
names(issues_per_feedstock_all) <- feedstocks

issues_per_feedstock <- issues_per_feedstock_all[issues_per_feedstock_all != ""]

recently_updated <- character()

# I couldn't find a good way to do this with purrr. Probably would need to use
# either `do` or `map_df`:
# https://community.rstudio.com/t/cheatsheet-for-moving-from-plyr-to-purrr/2507
for (stock in issues_per_feedstock) {
  for (issue in stock) {
    in_title <- str_detect(issue$title, phrase)
    if (!is.null(issue$body)) {
      in_body <- str_detect(issue$body, phrase)
    } else {
      in_body <- FALSE
    }
    issue_date <- as_datetime(issue$created_at)
    is_pr <- !is.null(issue$pull_request)
    if ((in_title || in_body) && !is_pr && now - issue_date < expiration) {
      recently_updated <- c(recently_updated, basename(issue$repository_url))
    }
  }
}

feedstocks <- feedstocks %>% discard(feedstocks %in% recently_updated)

# Submit an Issue to have @conda-forge-admin update the CircleCI token
#
# Waiting to get confirmation that this is the right approach
