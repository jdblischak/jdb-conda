# Helper script for migrating bioconda non-bio R pacakges to conda-forge
#
# https://github.com/bioconda/bioconda-recipes/issues/5582
#
# I manually saved the results from 2017-08-23 in the file
# r-bioconda-2017-08-23.txt. Not all of the packages in bioconda that are also
# in conda-forge were listed in the Issue. Perhaps they had some way of removing
# these known packages. Also, some of them were already submitted as a PR to
# staged-recipes even though they were already on conda-forge. I'm not sure if
# this was purposeful (maybe to update recipe, not sure if conda-smithy is that
# smart) or an accident.

library("jsonlite")
library("stringr")
library("tidyverse")

# Download list of packages starting with "r-" from Anaconda Cloud
cmd <- "conda search --json '^r-'"
raw <- fromJSON(system(cmd, intern = TRUE))
anaconda <- raw %>%
  map_df(`[`, c("name", "version", "build", "channel"))

# Obtain all bioconda R pacakges
bioconda <- anaconda %>%
  filter(channel == "bioconda") %>%
  select(name) %>%
  unique
bioconda <- bioconda$name

# Obtain all conda-forge R packages and their most recent version number
forge <- anaconda %>%
  filter(channel == "conda-forge") %>%
  mutate(version = str_replace_all(version, "_", "-")) %>%
  group_by(name) %>%
  summarize(version = max(as.numeric_version(version))) %>%
  mutate(version = as.character(version))

# For any bioconda R package already on conda-forge, print its version number
for (pkg in bioconda) {
  if (pkg %in% forge$name) {
    vers <- forge$version[forge$name == pkg]
    m <- sprintf("%s (%s in conda-forge)\n", pkg, vers)
    cat(m)
  }
}
