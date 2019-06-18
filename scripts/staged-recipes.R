#!/usr/bin/env Rscript

# Find staged-recipes Pull Requests with R recipes.

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

cat(glue("Found {length(pr_r)} Pull Requests for R recipes"))

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
