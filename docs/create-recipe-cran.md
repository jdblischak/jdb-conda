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