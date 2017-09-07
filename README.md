# jdb-conda

Recipes for building the conda packages I have uploaded to my
[Anaconda Cloud repo][repo].

## Installing

To install one of these R packages with conda, run:

```
conda install -c jdblischak r-<pkgname>
```

Caveats:

1. The packages in my channel are mainly available for the linux-64
architecture, with only a few built for osx-64.

1. The R packages in my channel are mainly available for use with R
3.3.2, with only a few built for R 3.3.1.

## Building R packages

I follow this general strategy for building the packages:

1. Run `conda skeleton cran` via
[bgruening/conda_r_skeleton_helper][helper]

1. Build the packages with `conda build`:

    ```
    conda build --R 3.3.1 r-<pkgname>
    conda build --R 3.3.2 r-<pkgname>
    ```

1. Upload to Anaconda Cloud with `anaconda upload`

## Building Bioconductor packages

I follow this general strategy for building the packages:

1. I use an [outdated version][bioconda-recipes-outdated] of the
script to build recipes for Bioconductor packages because it is easier
to install and run for one-off use. If you're interested in submitting
a Bioconductor package to [bioconda][], you should instead follow
their instructions to [contribute a recipe][bioconda-contribute] and
use [bioconda-utils][].

    ```
    git clone git@github.com:bioconda/bioconda-recipes.git
    cd bioconda-recipes
    git checkout f33fa2c93a6f77ffa30ca90ec3ff3b7a43096b0f
    cd scripts/bioconductor
    # I skip the following step b/c I already have bioconda in my .condarc file
    #conda config --add channels bioconda
    conda create -n bioconductor-recipes --file requirements.txt
    source activate bioconductor-recipes
    ./bioconductor_skeleton.py --recipes . --bioc-version 3.4 <case-sensitive-pkgname>
    source deactivate
    ```

1. Build the packages with `conda build`:

    ```
    conda build --R 3.3.1 r-<pkgname>
    conda build --R 3.3.2 r-<pkgname>
    ```

1. Upload to Anaconda Cloud with `anaconda upload`

## License

Everything in this repository is in the public domain. See the file
`LICENSE` for the text of the [Creative Commons CC0 Public Domain
Dedication][cc0]. However, each software package also has its own
license that must be followed.

[bioconda]: https://bioconda.github.io/
[bioconda-contribute]: https://bioconda.github.io/contribute-a-recipe.html
[bioconda-recipes-outdated]: https://github.com/bioconda/bioconda-recipes/blob/f33fa2c93a6f77ffa30ca90ec3ff3b7a43096b0f/scripts/bioconductor/README.md
[bioconda-utils]: https://github.com/bioconda/bioconda-utils
[cc0]: https://creativecommons.org/publicdomain/zero/1.0/
[helper]: https://github.com/bgruening/conda_r_skeleton_helper
[repo]: https://anaconda.org/jdblischak/repo
