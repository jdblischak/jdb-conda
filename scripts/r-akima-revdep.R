#!/usr/bin/env Rscript

# How many R packages include akima as a dependency? What are their licenses?

library("devtools")
library("dplyr")

revdep_akima <- revdep("akima",
                      dependencies = c("Depends", "Imports", "LinkingTo"),
                      recursive = TRUE, bioconductor = TRUE)
cran <- available.packages(repos = "http://cran.case.edu/")
cran <- as.data.frame(cran)
cran %>% filter(Package %in% c("akima", revdep_akima)) %>%
  select(Package, starts_with("License"))
#        Package            License License_is_FOSS License_restricts_use
# 1        akima ACM | file LICENSE            <NA>                   yes
# 2 DATforDCEMRI    CC BY-NC-SA 3.0            <NA>                  <NA>
# 3          FGN    CC BY-NC-SA 3.0            <NA>                  <NA>
# 4   RchivalTag    CC BY-NC-SA 4.0            <NA>                  <NA>
# 5 spikeSlabGAM    CC BY-NC-SA 4.0            <NA>                  <NA>
setdiff(revdep_akima, cran$Package)
# [1] "LedPred"  "OCplus"   "splatter"
# LedPred is MIT, OCplus is LGPL, and splatter is GPL3.
