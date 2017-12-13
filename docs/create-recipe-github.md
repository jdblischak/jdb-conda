# Create conda recipe for GitHub R package

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
   conda skeleton cran https://github.com/username/pkgname
   ```

1. Clean up the recipe:
   a. Remove unnecessary comments
   b. Make sure the URL to the GitHub repo is correct in the about section.
   c. Add the license file.

1. Build the packages with `conda build` (version 2, not 3):

    ```
    conda build --R 3.4.1 r-pkgname
    ```

1. Upload to Anaconda Cloud with `anaconda upload`
