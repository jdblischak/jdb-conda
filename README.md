# jdb-conda

Recipes for building the conda packages I have uploaded to my
[Anaconda Cloud repo][repo].

## Installing

To install one of these R packages with conda, run:

```
conda install -c jdblischak r-<pkgname>
```

Caveats:

1. The packages in my channel are only available for the linux-64
architecture.

2. The packages in my channel are only available for use with R 3.3.1
and 3.3.2.

## Building

I follow this general strategy for building the packages:

1. Run `conda skeleton cran` via
[bgruening/conda_r_skeleton_helper][helper]

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

[cc0]: https://creativecommons.org/publicdomain/zero/1.0/
[helper]: https://github.com/bgruening/conda_r_skeleton_helper
[repo]: https://anaconda.org/jdblischak/repo
