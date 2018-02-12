#!/usr/bin/env Rscript

"Rerender conda-forge R packages.
Usage:
rerender-r-packages.R [options] [<package>...]
Options:
-h --help              Show this screen
-n --dry-run           Dry run
-a --all               Rerender all packages with dependencies available
-l --limit=<l>         Limit the maximum number of packages to attempt to update
                       [default: 10]
-b --buffer=<b>        Buffer time (hours) to wait for CI builds to finish after
                       creating a feedstock or merging a PR [default: 72].
                       Feedstocks within the buffer time are automatically skipped.
-i --issue             Open an Issue if the CI needs restarted.
-p --path=<p>          Path on local machine to save intermediate files
Arguments:
package               Zero or more R packages using conda syntax, e.g. r-ggplot2" -> doc

# Requirements:
#
# 1. Install conda-build (v2) and conda-smithy:
#
# conda install -c conda-forge conda-build conda-smithy
#
# These packages have to be installed in the root environment. I'd advise
# creating a separate, isolated conda installation for maintaining conda-forge
# packages.
#
# 2. Install R packages:
#
# install.packages("docopt", "dplyr", "gh", "git2r", "jsonlite", "lubridate",
# "purrr", "stringr", "yaml")
#
# or
#
# conda install r-docopt r-dplyr r-gh r-git2r r-jsonlite r-lubridate r-purrr
# r-stringr r-yaml
#
# 3. Create a GitHub Personal Access Token:
#
# Follow these directions:
# https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/
#
# Add the permissions: repo:status, public_repo, read:org
#
# Export the token as GITHUB_PAT in your .Renviron file.
#
# WARNING: This token must be kept private! It is no different than your
# password. If you are using a personal laptop, you don't have to worry much.
# But if you are on a shared machine, make sure only you can read the file.
#
# chmod 600 ~/.Renviron
#
# 4. Setup SSH keys:
#
# I use SSH keys to authenticate with GitHub. It may be possible to use HTTPS
# with this script, but I haven't actually tested it. Also, if your SSH keys
# have a passphrase, you may need to unlock them first by running a Git command
# in the Terminal.
#
# https://help.github.com/articles/connecting-to-github-with-ssh/

# Packages ---------------------------------------------------------------------

suppressPackageStartupMessages(library("docopt"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("gh"))
suppressPackageStartupMessages(library("git2r"))
suppressPackageStartupMessages(library("jsonlite"))
suppressPackageStartupMessages(library("lubridate"))
suppressPackageStartupMessages(library("purrr"))
suppressPackageStartupMessages(library("stringr"))
suppressPackageStartupMessages(library("yaml"))

# Functions --------------------------------------------------------------------

check_package_name <- function(package) {
  prefix <- str_sub(package, 1, 2)
  is_lower <- str_to_lower(package) == package
  invalid <- package[prefix != "r-" | !is_lower]
  return(invalid)
}

# Find conda-forge R packages that have been built with only a subset of the R
# builds available, and thus need to be rerendered. Must be performed separately
# for each platform. r-base is removed.
#
# platform - Platform passed to `conda search --platform`, e.g. linux-64, osx-64, win-64, etc
find_pkgs_for_rerender <- function(platform, builds = c("r3.3.2", "r3.4.1")) {
  # conda-search currently doesn't respect --override-channels. Packages in
  # defaults or the channels in .condarc are always included:
  # https://github.com/conda/conda/issues/5717
  anaconda <- system2(command = "conda",
                      args = c("search", "--json", "--override-channels",
                               "-c conda-forge", "--platform", platform, "^r-"),
                      stdout = TRUE)
  anaconda <- fromJSON(anaconda)
  pkgs <- anaconda %>%
    map_df(`[`, c("name", "version", "build", "channel", "platform", "subdir")) %>%
    filter(channel == "conda-forge", name != "r-base") %>%
    mutate(build = str_extract(build, "r[0-9]\\.[0-9]\\.[0-9]"),
           version = str_replace_all(version, "_", "-")) %>%
    group_by(name) %>%
    # Only consider the latest version of the recipe
    filter(as.numeric_version(version) == max(as.numeric_version(version))) %>%
    summarize(rerender = !all(builds %in% build))
  return(pkgs)
}

read_recipe_yaml <- function(meta_lines) {
  valid_yaml <- paste(meta_lines[!str_detect(meta_lines, "\\{")],
                      collapse = "\n")
  list_yaml <- yaml.load(valid_yaml)
  return(list_yaml)
}

clean_dependencies <- function(x) {
  if (is.null(x)) {
    return(x)
  } else {
    result <- str_split(x, pattern = " ", simplify = TRUE)[, 1]
    return(result)
  }
}

obtain_pkg_dependencies <- function(pkg) {
  meta_url <- url(paste0("https://raw.githubusercontent.com/conda-forge/",
                         pkg, "-feedstock/master/recipe/meta.yaml"))
  meta_lines <- readLines(meta_url)
  close(meta_url)
  list_yaml <- read_recipe_yaml(meta_lines)
  reqs_build <- clean_dependencies(list_yaml$requirements$build)
  reqs_run <- clean_dependencies(list_yaml$requirements$run)
  return(union(reqs_build, reqs_run))
}

# Find leaves in dependency graph.
#
# l - list with the dependencies for each pacakge that needs rerendered
find_leaves_in_graph <- function(l) {
  nodes <- names(l)
  is_leaf <- logical(length = length(l))
  names(is_leaf) <- nodes
  for (i in seq_along(l)) {
    is_leaf[i] <- sum(l[[i]] %in% nodes) == 0
  }
  return(nodes[is_leaf])
}

# https://developer.github.com/v3/repos/forks/#create-a-fork
fork_repo <- function(repo, owner = "conda-forge") {
  fork <- gh("POST /repos/:owner/:repo/forks", owner = owner, repo = repo)
  return(fork)
}

create_feature_branch <- function(repo, name = "rerender") {
  stopifnot(class(repo) == "git_repository")
  git_log <- commits(repo)
  b <- branch_create(commit = git_log[[1]], name = name)
  checkout(b)
  return(b)
}

rerender_feedstock <- function(path, max_attempts = 3) {
  if (Sys.which("conda-smithy") == "") {
    stop("You need to install conda-smithy to rerender the feedstock.\n",
         "    conda install -c conda-forge conda-smithy")
  }
  # Sometimes conda-smithy times out when downloading data from Anaconda Cloud
  attempts <- 0
  while(attempts < max_attempts) {
    out <- system2(command = "conda",
                   args = c("smithy", "rerender", "--commit", "auto",
                            "--feedstock_directory", path),
                   stdout = TRUE, stderr = TRUE)
    if (any(grepl("remote server error", out))) {
      attempts <- attempts + 1
    } else {
      return(out)
    }
  }
  stop(out, "\n\nconda-smithy failed when trying to rerender the feedstock")
}

# Determine if a new build was added by conda-smithy by checking for the string
# CONDA_R.
#
# r - git_repository that had `conda smithy rerender --commit auto` applied
#
# Returns TRUE if CONDA_R detected in new lines, otherwise FALSE.
check_smithy_additions <- function(r) {
  stopifnot(class(r) == "git_repository")
  git_log <- commits(r)
  tree_1 <- tree(git_log[[2]])
  tree_2 <- tree(git_log[[1]])
  git_diff <- diff(tree_1, tree_2, as_char = TRUE)
  git_diff_lines <- str_split(git_diff, "\n")[[1]]
  # Select all lines that start with only 1 + (excludes the lines
  # stating the filenames, which start with +++ and ---)
  git_diff_lines_added <- str_subset(git_diff_lines, "^[+]{1,1}[^+]")
  # Do any of the added lines include CONDA_R?
  conda_r_lines <- str_detect(git_diff_lines_added, "CONDA_R")
  return(any(conda_r_lines))
}

# https://developer.github.com/v3/pulls/#create-a-pull-request
submit_pull_request <- function(owner, repo, title, head, base, body,
                                maintainer_can_modify = TRUE) {
  pr <- gh("POST /repos/:owner/:repo/pulls", owner = owner, repo = repo,
           title = title, head = head, base = base, body = body,
           maintainer_can_modify = maintainer_can_modify)
  return(pr)
}

# https://developer.github.com/v3/issues/#create-an-issue
create_issue <- function(owner, repo, title = NULL, body = NULL) {
  if (is.null(title)) {
    title <- "Missing build"
  }
  if (is.null(body)) {
    body <- "Try restarting any failed CI builds (all the dependencies should be available). Please record your attempts here to avoid duplicating effort and CI time."
  }
  issue <- gh("POST /repos/:owner/:repo/issues", owner = owner, repo = repo,
           title = title, body = body)
  return(issue)
}

# Main -------------------------------------------------------------------------

main <- function(package = NULL, dry_run = FALSE, all = FALSE, limit = 10,
                 buffer = 72, issue = FALSE, path = NULL) {

  buffer <- as.difftime(buffer, units = "hours")

  # Find packages that need rerendered because they are not available for R
  # 3.4.1
  linux_64 <- find_pkgs_for_rerender("linux-64")
  cat(sprintf("%d of %d R packages for linux-64 need rerendered\n",
              sum(linux_64$rerender), nrow(linux_64)))
  osx_64 <- find_pkgs_for_rerender("osx-64")
  cat(sprintf("%d of %d R packages for osx-64 need rerendered\n",
              sum(osx_64$rerender), nrow(osx_64)))
  win_64 <- find_pkgs_for_rerender("win-64")
  cat(sprintf("%d of %d R packages for win-64 need rerendered\n",
              sum(win_64$rerender), nrow(win_64)))
  rerender_total <- Reduce(union, list(linux_64$name[linux_64$rerender],
                                       osx_64$name[osx_64$rerender],
                                       win_64$name[win_64$rerender]))
  cat(sprintf("A total of %d R packages need rerendered\n",
              length(rerender_total)))

  # Obtain dependencies for each package that needs rerendered
  dependencies <- Map(obtain_pkg_dependencies, rerender_total)

  # Find leaves of dependency graph
  leaves <- find_leaves_in_graph(dependencies)
  leaves <- sort(leaves)

  cat(sprintf("A total of %d R packages are leaves in the dependency graph and can be rerendered\n",
              length(leaves)))

  # Determine which packages to rerender
  if (!is.null(package)) {
    package <- package[package %in% leaves]
  }
  if (all) {
    package <- unique(c(package, leaves))
  }
  package <- package[seq_len(min(length(package), limit))]
  cat("Packages to rerender:\n\n")
  cat(sprintf("\t%s", package), sep = "\n")

  if (dry_run) {
    cat("Dry run mode. Exiting.\n")
    return(invisible())
  }

  # Path to clone Git repositories
  if (is.null(path)) {
    path <- tempdir()
  } else {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
    cat(sprintf("Saving intermediate files to %s\n", path))
  }

  if (Sys.getenv("GITHUB_PAT") == "") {
    stop("You need to generate a GitHub personal access token and ",
         "export it as GITHUB_PAT in your .Renviron file.")
  } else {
    login <- gh_whoami()
    cat(sprintf("You are logged into GitHub as %s\n", login$login))
  }

  for (pkg in package) {
    cat(sprintf("Processing %s\n", pkg))
    feedstock <- paste0(pkg, "-feedstock")

    # Check for an existing Pull Request
    # https://developer.github.com/v3/pulls/#list-pull-requests
    pr_existing <- gh("/repos/:owner/:repo/pulls", owner = "conda-forge",
                      repo = feedstock, state = "open")
    if (!all(pr_existing == "")) {
      pr_titles <- pr_existing %>% map_chr("title")
      if (any(str_detect(pr_titles, "conda-smithy"))) {
        cat(sprintf("Skipping %s because a conda-smithy PR already exists:\n%s\n",
                    pkg, paste0("https://github.com/conda-forge/", feedstock, "/pulls")))
        next
      } else {
        cat(sprintf("Skipping %s because a PR is currently open:\n%s\n",
                    pkg, paste0("https://github.com/conda-forge/", feedstock, "/pulls")))
        next
      }
    }

    # Check for a recently merged Pull Request
    pr_merged <- gh("/repos/:owner/:repo/pulls", owner = "conda-forge",
                      repo = feedstock, state = "closed")
    if (!all(pr_merged == "")) {
      merge_times <- pr_merged %>%
        map_chr("merged_at", .default = NA) %>%
        as_datetime()
      if (any(Sys.time() - merge_times < buffer, na.rm = TRUE)) {
        cat(sprintf("Skipping %s because a PR was merged in the last 72 hours:\n%s\n",
                    pkg, paste0("https://github.com/conda-forge/", feedstock, "/pulls")))
        next
      }
    }

    # Check for an existing Issue
    # https://developer.github.com/v3/issues/#list-issues-for-a-repository
    issue_existing <- gh("/repos/:owner/:repo/issues", owner = "conda-forge",
                      repo = feedstock, state = "open")
    if (!all(issue_existing == "")) {
      cat(sprintf("Skipping %s because an Issue is already open:\n%s\n",
                  pkg, paste0("https://github.com/conda-forge/", feedstock, "/issues")))
      next
    }

    # Skip package if feedstock was created in the last 3 days
    # https://developer.github.com/v3/repos/#get
    feedstock_info <- gh("/repos/:owner/:repo", owner = "conda-forge",
                         repo = feedstock)
    created_at <- as_datetime(feedstock_info$created_at)
    if (Sys.time() - created_at < buffer) {
      cat(sprintf("Skipping %s because created in last 3 days\n", pkg))
      next
    }

    cat("  * Forking feedstock repo\n")
    fork <- fork_repo(feedstock)
    cat("  * Cloning feedstock repo\n")
    r <- clone(fork$ssh_url, local_path = file.path(path, fork$name),
               progress = FALSE)
    b <- create_feature_branch(r)
    cat("  * Rerendering feedstock repo\n")
    conda_smithy <- rerender_feedstock(workdir(r))

    # Only push and pull request if a new commit was made by conda-smithy and
    # the changes include adding a new version of R.
    if (branch_target(b) != branch_target(branches(r)$master) &&
        check_smithy_additions(r)) {
      push(r, name = "origin", refspec = paste0("refs/heads/", b@name))
      last_commit_message <- commits(r)[[1]]@summary
      pr <- submit_pull_request(owner = "conda-forge", repo = feedstock,
                                title = last_commit_message,
                                head = paste(login$login, b@name, sep = ":"),
                                base = "master",
                                body = "")
      cat(sprintf("PR submitted for %s:\n%s\n", pkg,
                  paste0("https://github.com/conda-forge/", feedstock, "/pulls")))
    } else {
      cat(sprintf("Rerendering %s had no effect.\n", pkg))
      if (issue) {
        issue <- create_issue(owner = "conda-forge", repo = feedstock)
        cat(sprintf("Opened Issue %s\n", issue$html_url))
      }
    }
  }
}

# Arguments --------------------------------------------------------------------

if (!interactive()) {
  opts <- docopt(doc)
  invalid <- check_package_name(opts$package)
  if (length(invalid) > 0) {
    cat(sprintf("Package names must be lowercase and start with r-. The following are invalid: %s\n\n",
                paste(invalid, collapse = " ")))
    docopt(doc, "-h")
  }
  main(package = opts$package,
       dry_run = opts$`dry-run`,
       all = opts$all,
       limit = as.numeric(opts$limit),
       buffer = as.numeric(opts$buffer),
       issue = opts$issue,
       path = opts$path)
}
