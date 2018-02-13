# Submit Bioconductor R package recipe to bioconda

**WARNING:** These docs are now outdated. Bioconda has migrated away from
  `simulate-travis.py` and now [recommends locally running the Circle CI
  client][circle-ci-client].

The steps belows detail how I create and test a recipe for a Bioconductor R
package for submission to bioconda. Adapted from the relevant documentation:

* [Contributing overview][bioconda-contributing-overview]
* [Contributing a recipe][bioconda-contribute]
* [R/Bioconductor recipes][r-bioc-recipes]

1. Obtain a local, updated copy of [bioconda-recipes][]:

    a. Fork and clone:

    ```
    git clone git@github.com:jdblischak/bioconda-recipes.git
    cd bioconda-recipes
    git remote add upstream git@github.com:bioconda/bioconda-recipes.git
    ```

    b. Pull from upstream:

    ```
    cd bioconda-recipes
    git checkout master
    git pull upstream master
    git push origin master
    ```

1. Create a feature branch:

    ```
    git checkout -b pkgname
    ```
 
1. Create isolated conda environment for testing
([Instructions][conda-isolated]):

    ```
    ./simulate-travis.py --bootstrap ~/miniconda-bioconda --overwrite
    ```

    Which generates the following message:

    > An alternative conda installation is now in /home/jdb-work/miniconda-bioconda,
    > channels have been set, and requirements for bioconda-utils have been
    > installed there.

    > A config file at ~/.config/bioconda/conf.yml has been
    > created to store this information, so you can now run `./simulate-travis.py`
    > with no additional arguments to use this new conda installation.

    This only has to be run once per machine.

1. Create recipe with [bioconda-utils][] (Bioconductor pacakge name is
case-sensitive):

    ```
    ~/miniconda-bioconda/bin/bioconda-utils bioconductor-skeleton recipes/ ~/.config/bioconda/conf.yml pkgName
    ```

1. Add and commit:

    ```
    git add recipes/bioconductor-pkgname/
    git commit -m "Add bioconductor-pkgname."
    ```

1. Build and test package locally, but without using Docker. Specify the package
name, not the path to the package:

    ```
    ./simulate-travis.py --disable-docker --packages bioconductor-pkgname
    ```

1. Push to fork and create pull request:

    ```
    git push origin pkgname
    ```

[bioconda]: https://bioconda.github.io/
[bioconda-contribute]: https://bioconda.github.io/contribute-a-recipe.html
[bioconda-contributing-overview]: https://bioconda.github.io/contributing.html
[bioconda-recipes]: https://github.com/bioconda/bioconda-recipes
[bioconda-utils]: https://github.com/bioconda/bioconda-utils
[circle-ci-client]: https://bioconda.github.io/contrib-setup.html#install-the-circle-ci-client-optional
[conda-isolated]: https://bioconda.github.io/contribute-a-recipe.html#build-an-isolated-conda-installation-with-dependencies
[r-bioc-recipes]: https://bioconda.github.io/guidelines.html#r-bioconductor