# Create an exclusive conda-forge setup

When testing conda-forge tools, it is ideal to have all software packages
installed from the conda-forge channel. This way if I receive errors, I can
assume they are not a result of strange interactions between packages installed
from the conda-forge channel versus defaults or bioconda.

However, upon initial installation of Miniconda, the packages are all from the
defaults channel. After running the Miniconda installer and updating the PATH, I
run the following to create a conda-forge development environment. Specifying
`-c conda-forge` sets it as the priority over other channels specified in
`.condarc` (which can be checked with `conda config --get channels`).

$ conda update -c conda-forge --all
$ conda install -c conda-forge conda-build conda-build-all conda-smithy

As an example, using this setup fixed the [error][] I was having trying to run
`conda build-all`. Because of my `.condarc` settings, some of the packages were
installed from defaults and bioconda.

[error]: https://github.com/conda-forge/conda-smithy/issues/603#issuecomment-342210570
