# Scripts

This directory contains utility scripts for maintaing conda packages.

* `conda-forge-cran.R` - Helper script to identify conda-forge R
 packages that have more recent versions released on CRAN.

* `maintain.R` - This is a useful script for detecting changes to CRAN
  R packages when you are only tracking a dozen or so
  packages. Requires you to manually edit the current version of each
  package after you update it.

* `bioconda-migration.R` - Helper script for migrating non-bio R
  packages from bioconda to conda-forge.
