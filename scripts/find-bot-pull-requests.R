#!/usr/bin/env Rscript

# Find bot PRs to merge or fix.
#
# Motivation:
# https://github.com/bioconda/bioconda-recipes/issues/10771
# https://github.com/pulls?utf8=%E2%9C%93&q=is%3Aopen+is%3Apr+archived%3Afalse+org%3Aconda-forge+-review%3Achanges_requested+-repo%3Aconda-forge%2Fstaged-recipes+author%3Aregro-cf-autotick-bot+Rebuild

# Setup ------------------------------------------------------------------------

library("gh")
library("purrr")
library("stringr")

# Search for bot PRs -----------------------------------------------------------

# https://developer.github.com/v3/search/#search-issues
# https://help.github.com/articles/searching-issues-and-pull-requests/
search_query <- paste("is:pr",
                      "Rebuild in:title",
                      "org:conda-forge",
                      "is:open",
                      "is:public",
                      "author:regro-cf-autotick-bot",
                      "status:failure",
                      "")
message("Using the search query:")
message(search_query)
pr_bot_search <- gh("/search/issues", page = 1, per_page = 100,
                    q = search_query, sort = "created")
n_found <- pr_bot_search$total_count
message(sprintf("Found %d bot PRs", n_found))
pr_bot <- pr_bot_search$items
n_returned <- length(pr_bot)
page <- 1
while (n_returned < n_found) {
  page <- page + 1
  pr_bot_search <- gh("/search/issues", page = page, per_page = 100,
                      q = search_query, sort = "created")
  pr_bot <- c(pr_bot, pr_bot_search$items)
  n_returned <- length(pr_bot)
}
pr_bot_repos <- map_chr(pr_bot, "repository_url") %>% basename
pr_bot_r <- pr_bot[str_detect(pr_bot_repos, "^r-")]
message(sprintf("Found %d bot PRs on R feedstocks", length(pr_bot_r)))

# Inspect open PRs -------------------------------------------------------------

pr_bot_r %>% map_chr("title")
# pr_bot_r %>% map_chr("html_url") %>% (function(x) lapply(x, browseURL))
