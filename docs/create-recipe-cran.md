# Create conda recipe for CRAN R package

I follow this general strategy for building the packages:

1. Run `conda skeleton cran` via
[bgruening/conda_r_skeleton_helper][helper]

1. Build the packages with `conda build`:

    ```
    conda build --R 3.3.1 r-<pkgname>
    conda build --R 3.3.2 r-<pkgname>
    ```

1. Upload to Anaconda Cloud with `anaconda upload`

[helper]: https://github.com/bgruening/conda_r_skeleton_helper

In practice, my exact usage of conda-build is quite a mess. I like
having access to the latest changes in the skeleton for CRAN packages,
so I like to use conda-build 3+ for creating the recipes. conda-build
3+ can be installed by specifying the channel defaults.

```
conda install -c defaults conda-build
conda skeleton cran r-<pkgname>
```

However, conda-build 2 and 3 differ in how they create build version
strings. conda-build 2 uses r3.3.2_0, r3.3.2_1, r3.4.1_0, etc, and
conda-build 3 uses r332abcdef_0, r332hijklm_1, r341nopqrs_0,
etc. Mixing these two is a disaster, i.e. an R package built with
conda-build 3 will always be installed as the latest version even if
it was created with an older version of R. To install conda-build 2,
use the conda-forge channel.

```
conda install -c conda-forge conda-build
conda build --R 3.3.2 r-<pkgname>
```

Frustratingly, conda-build has to be installed in the root
environment, so this setup cannot be improved by using different conda
environments for creating and building recpies, respectively.
