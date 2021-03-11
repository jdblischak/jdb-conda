# Create conda recipe for GitHub R package

**Note:** The below applies to conda-build 3.

The Git repo must have at least one tag for this to work. For each tag, GitHub
creates a URL to download the tarball for this release, which is what conda uses
to build the package. Note that this only works if the R package is in the root
directory.

1. Tag the repo and push to GitHub:

    ```
    git tag -a vX.X.X -m "This release has the following changes..."
    git push origin --tags
    ```

1. Create the recipe using the cran skeleton:

    ```
    conda skeleton cran --use-noarch-generic https://github.com/username/pkgname
    ```

    If the package doesn't contain any compiled code, the flag
    `--use-noarch-generic` will create a noarch recipe. When the recipe is
    built, that conda binary is installable on Linux, macOS, and Windows. If it
    contains compiled code, the conda binary it creates will only be installable
    on the same operating system on which it was built.

    If you need to create a recipe for a tag other than the most recent tag,
    specify the tag with `--git-tag <name-of-tag>`.

1. Clean up the recipe:

    1) Remove unnecessary comments
    1) Make sure the URL to the GitHub repo is correct in the about section.
    1) Check that the license file(s) is/are included.

1. Build the packages with `conda build`:

    ```
    conda build --R 4.0 r-pkgname
    conda build --R 3.6 r-pkgname
    ```

1. Upload to Anaconda Cloud with `anaconda upload`
