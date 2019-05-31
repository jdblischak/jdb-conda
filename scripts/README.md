# Scripts

This directory contains utility scripts for maintaing conda packages.

* `rerender-r-packages.R` - Helper script to identify conda-forge R packages
that are missing builds and have all dependencies met. Rerenders the feedstocks
and sends a Pull Request.

* `delete-my-feedstocks.R` - Delete any feedstock forks that have no open Pull
Requests or Issues.

* `conda-forge-cran.R` - Helper script to identify conda-forge R
 packages that have more recent versions released on CRAN.

* `maintain.R` - This is a useful script for detecting changes to CRAN
  R packages when you are only tracking a dozen or so
  packages. Requires you to manually edit the current version of each
  package after you update it.

* `bioconda-migration.R` - Helper script for migrating non-bio R
  packages from bioconda to conda-forge.

* `find-bot-pull-requests.R` - Find Pull Requests on R feedstocks opened by
  regro-cf-autotick-bot.

* `count-r-pkgs.R` - Count the number of R packages available for the platforms
  linux-64, osx-64, and win-64 for the channels r, conda-forge, and bioconda
  (includes Bioconductor packages).

* `r351.R` - Count the number of conda-forge R packages built for R 3.5.1.

* `pkgs-to-add.R` - Find R packages to add to conda-forge channel

* `stop-watching.py` - Stop watching conda-forge R feedstocks. I will still
  receive notifications if mentioned by my username, @conda-forge/r, or
  @conda-forge/r-<pkg>. Also I should still receive a notification if someone
  starts a conversation in a particular team forum.
