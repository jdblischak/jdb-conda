# jdb-conda

This repository contains my personal documentation, recipes, and
scripts for creating, using, and maintaining software packages using
the [conda][] package manager.

* `docker/` - Dockerfiles to create testing containers

* `docs/` - Documentation for using [conda][]

* `recipes/` - Recipes for building the conda packages I have uploaded
  to my [Anaconda Cloud repo][repo]

* `scripts/` - Helper scripts for building and maintaining conda
  packages

## Installing a package from my channel

If you see a package in my [channel][repo] that you want to use, you
can install it into your conda environment by running the following:

```
conda install -c jdblischak <pkgname>
```

Caveats:

1. The packages in my channel are mainly available for the linux-64
architecture, with only a few built for osx-64.

1. The R packages in my channel are mainly available for use with R
3.3.2, with only a few built for R 3.3.1.

## License

Everything in this repository is in the public domain. See the file
`LICENSE` for the text of the [Creative Commons CC0 Public Domain
Dedication][cc0]. However, if you download any software via conda from
Anaconda Cloud, you are subject to the license of each individual
software package.

[cc0]: https://creativecommons.org/publicdomain/zero/1.0/
[conda]: https://conda.io/
[repo]: https://anaconda.org/jdblischak/repo
