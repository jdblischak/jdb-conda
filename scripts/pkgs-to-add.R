#!/usr/bin/env Rscript

# Find CRAN packages to add to conda-forge
#
# Full results saved in data/pkgs-to-add.txt

suppressPackageStartupMessages({
  library("cranlogs")
  library("jsonlite")
  library("stringr")
})

cat(as.character(Sys.time()), sep = "\n")
cat(system("conda --version", intern = TRUE), sep = "\n")

# Obtain CRAN packages available from conda-forge and bioconda channels
query <- "conda search --quiet --json --override-channels -c conda-forge -c bioconda 'r-*'"
cf <- system(query, intern = TRUE)
cf <- fromJSON(cf)
cf_pkgs <- names(cf)

cat(sprintf("Currently %d CRAN packages in conda-forge or bioconda channels\n",
            length(cf_pkgs)))

# Top downloaded CRAN packages -------------------------------------------------

# Obtain most downloaded CRAN packages
top <- cran_top_downloads(when = "last-month", count = 100)
top_pkgs <- paste0("r-", tolower(top$package))

# Top downloaded CRAN packages that need to be added to conda-forge
top_pkgs_to_add <- setdiff(top_pkgs, cf_pkgs)

n_top_pkgs_to_add <- length(top_pkgs_to_add)
if (n_top_pkgs_to_add > 0) {
  cat("\nTop downloaded CRAN packages to be added to conda-forge:\n\n")
  cat(top_pkgs_to_add[1:pmin(n_top_pkgs_to_add, 10)], sep = "\n")
  if (n_top_pkgs_to_add > 10) {
    cat(sprintf("And %d more\n", n_top_pkgs_to_add - 10))
  }
}

# cran2deb ---------------------------------------------------------------------

# Requires that ppa:marutter/c2d4u3.5 or similar is set as a Software Source on
# Ubuntu
#
# https://launchpad.net/~marutter/+archive/ubuntu/c2d4u3.5
cran2deb <- system("apt-cache search r-cran-", intern = TRUE)
cran2deb_pkgs <- str_subset(cran2deb, "^r-cran-")
cran2deb_pkgs <- str_extract(cran2deb_pkgs, "^r-cran-\\S+")
cran2deb_pkgs <- str_replace(cran2deb_pkgs, "-cran", "")

# cran2deb CRAN packages that need to be added to conda-forge
cran2deb_pkgs_to_add <- setdiff(cran2deb_pkgs, cf_pkgs)

n_cran2deb_pkgs_to_add <- length(cran2deb_pkgs_to_add)
if (n_cran2deb_pkgs_to_add > 0) {
  cat("\ncran2deb packages to be added to conda-forge:\n\n")
  cat(cran2deb_pkgs_to_add[1:pmin(n_cran2deb_pkgs_to_add, 10)], sep = "\n")
  if (n_cran2deb_pkgs_to_add > 10) {
    cat(sprintf("And %d more\n", n_cran2deb_pkgs_to_add - 10))
  }
}

# Full results -----------------------------------------------------------------

pkgs_all <- union(top_pkgs_to_add, cran2deb_pkgs_to_add)
write.table(pkgs_all, file = "data/pkgs-to-add.txt", quote = FALSE,
            row.names = FALSE, col.names = FALSE)
