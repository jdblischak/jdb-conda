#!/usr/bin/env Rscript

# Find staged-recipes Pull Requests with R recipes.
#
# List Pull Requests: https://developer.github.com/v3/pulls/#list-pull-requests

# Packages ---------------------------------------------------------------------

suppressPackageStartupMessages(library("gh"))
suppressPackageStartupMessages(library("glue"))
suppressPackageStartupMessages(library("stringr"))

# Functions --------------------------------------------------------------------

is_r_recipe <- function(x) {
  regex <- "\\br-[:alnum:]\\b" # match any word starting with r-
  any(str_detect(c(x$title, x$body), regex))
}

# Main -------------------------------------------------------------------------

pr_all <- gh("/repos/:owner/:repo/pulls",
             owner = "conda-forge",
             repo = "staged-recipes",
             state = "open",
             sort = "updated",
             direction = "desc",
             .limit = 100)

pr_r <- Filter(is_r_recipe, pr_all)

# Find PRs that mention @conda-forge/help-r or @conda-forge/r
#
# https://help.github.com/en/articles/searching-issues-and-pull-requests
# https://help.github.com/en/articles/searching-issues-and-pull-requests#search-by-team-mention
query <- paste(
  "team:conda-forge/help-r",
  "team:conda-forge/r",
  "repo:conda-forge/staged-recipes",
  "is:pr",
  "is:open",
  "updated:>2019-01-01",
  sep = "+")

# Sanitize URL
query <- str_replace_all(query, ":", "%3A")
query <- str_replace_all(query, "/", "%2F")

pr_search <- gh(glue("/search/issues?q={query}"))

pr_search_as_pr <- lapply(pr_search$items,
                          function(x) gh(x[["pull_request"]][["url"]]))

pr_r <- c(pr_r, pr_search_as_pr)

cat(glue("Found {length(pr_r)} Pull Requests for R-related recipes"),
    sep = "\n")

for (i in seq_along(pr_r)) {
  pr <- pr_r[[i]]
  cat(glue("Pull Request {i}: {pr$title}
           Created at {pr$created_at}
           Last updated at {pr$updated_at}
           "))
  status <- gh(pr$statuses_url)
  cat(glue("\n\nStatus updates: {length(status)}\n\n"))
  for (j in seq_along(status)) {
    cat(glue("* {status[[j]]$state}: {status[[j]]$context}\n\n"))
  }
  ans <- readline("Would you like to open this PR? (y/n)")
  if (tolower(ans) == "y") browseURL(pr$html_url)
}
