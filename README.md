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

2. If the package is GPL'd, add the line `license_file: '{{
environ["RECIPE_DIR"] }}/LICENSE'` and download the license text from CRAN:

    ```
    # GPL2
    wget -O LICENSE https://cran.r-project.org/web/licenses/GPL-2
    # GPL3
    wget -O LICENSE https://cran.r-project.org/web/licenses/GPL-3
    ```

3. Build the packages with `conda build`:

    ```
    conda build --R 3.3.1 r-<pkgname>
    conda build --R 3.3.2 r-<pkgname>
    ```

4. Upload to Anaconda Cloud with `anaconda upload`


[helper]: https://github.com/bgruening/conda_r_skeleton_helper
[repo]: https://anaconda.org/jdblischak/repo
