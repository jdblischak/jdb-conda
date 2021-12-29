#!/usr/bin/env Rscript

"Delete unnecessary forks of conda-forge feedstocks.
Usage:
delete-my-feedstocks.R [options] [<feedstock>...]
Options:
-h --help              Show this screen
-n --dry-run           Dry run
-a --all               Delete all feedstocks
-l --limit=<l>         Limit the maximum number of feedstocks to attempt to delete
                       [default: 10]
-f --force             Force delete feedstock even if PR or Issue open (not yet
                       implemented)
Arguments:
feedstock                Zero or more conda-forge feedstocks,
                       e.g. r-ggplot2-feedstock" -> doc

# Requirements:
#
# 1. Install R packages:
#
# install.packages("docopt", "gh", "magrittr", "purrr", "stringr")
#
# or
#
# conda install r-docopt r-gh r-magrittr r-purrr r-stringr
#
# 2. Create a GitHub Personal Access Token:
#
# Follow these directions:
# https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/
#
# Add the permissions: repo:status, public_repo, read:org, delete_repo
#
# Export the token as GITHUB_PAT in your .Renviron file.
#
# WARNING: You are giving yourself permission to programmatically delete
# repositories. Use with caution!
#
# WARNING: This token must be kept private! It is no different than your
# password. If you are using a personal laptop, you don't have to worry much.
# But if you are on a shared machine, make sure only you can read the file.
#
# chmod 600 ~/.Renviron

# Packages ---------------------------------------------------------------------

suppressPackageStartupMessages(library("docopt"))
suppressPackageStartupMessages(library("gh"))
suppressPackageStartupMessages(library("magrittr"))
suppressPackageStartupMessages(library("purrr"))
suppressPackageStartupMessages(library("stringr"))

# Functions --------------------------------------------------------------------

# Get all repos
# https://developer.github.com/v3/repos/#list-your-repositories
get_my_repos <- function(...) {
  repos <- character()
  i <- 1
  while(TRUE) {
    result <- gh("/user/repos", visibility = "public", affiliation = "owner",
                 page = i, ...)
    if (all(result == "")) {
      break
    } else {
      latest <- result %>% map_chr("name")
      repos <- c(repos, latest)
      i <- i + 1
    }
  }
  return(repos)
}


# Main -------------------------------------------------------------------------

main <- function(feedstock = NULL, dry_run = FALSE, all = FALSE, limit = 10,
                 force = FALSE) {

  if (all && force) {
    stop("Cannot simultaneously set options all and force. ",
         "Only use force for specific feedstocks you know you want to delete.",
         call. = FALSE)
  }

  # Login to GitHub with Personal Access Token
  if (Sys.getenv("GITHUB_PAT") == "") {
    stop("You need to generate a GitHub personal access token and ",
         "export it as GITHUB_PAT in your .Renviron file.")
  } else {
    login <- gh_whoami()
    cat(sprintf("You are logged into GitHub as %s\n", login$login))
  }

  repos <- get_my_repos()
  if (all) {
    feedstock <- unique(c(feedstock, str_subset(repos, "-feedstock$")))
  }

  feedstock <- feedstock[seq_len(min(length(feedstock), limit))]
  if (length(feedstock) == 0) {
    cat("No feedstocks to delete\n")
    return(invisible())
  }
  cat("Feedstocks to delete:\n\n")
  cat(sprintf("\t%s", feedstock), sep = "\n")

  for (stock in feedstock) {
    cat(sprintf("\n%s\t\t", stock))

    # Skip if doesn't exist
    if (!(stock %in% repos)) {
      cat("Does not exist")
      next
    }

    # Skip if not a feedstock
    if (!str_detect(stock, "-feedstock")) {
      cat("Not a feedstock")
      next
    }

    # Check for an existing Pull Request
    # https://developer.github.com/v3/pulls/#list-pull-requests
    pr_existing <- gh("/repos/:owner/:repo/pulls", owner = "conda-forge",
                      repo = stock, state = "open")

    if (!all(pr_existing == "")) {
      pr_authors <- pr_existing %>% map("user") %>% map_chr("login")
      if (login$login %in% pr_authors) {
        cat("Skipping: Open Pull Request")
        next
      }
    }

    # Check for an existing Issue
    # https://developer.github.com/v3/issues/#list-issues-for-a-repository
    issue_existing <- gh("/repos/:owner/:repo/issues", owner = "conda-forge",
                      repo = stock, state = "open")
    if (!all(issue_existing == "")) {
      issue_authors <- issue_existing %>% map("user") %>% map_chr("login")
      if (login$login %in% issue_authors) {
        cat("Skipping: Open Issue")
        next
      }
    }

    if (dry_run) {
      cat("Would be deleted")
    } else {
      # https://developer.github.com/v3/repos/#delete-a-repository
      gh("DELETE /repos/:owner/:repo", owner = login$login, repo = stock)
      cat("Deleted")
    }
  }
  cat("\n", sep = "")
}

# Arguments --------------------------------------------------------------------

if (!interactive()) {
  opts <- docopt(doc)
  # Pass NULL to main() if no feedstocks specified at command-line
  if (length(opts$feedstock) == 0) {
    opts$feedstock <- NULL
  }
  main(feedstock = opts$feedstock,
       dry_run = opts$dry_run,
       all = opts$all,
       limit = as.numeric(opts$limit),
       force = opts$force)
}
