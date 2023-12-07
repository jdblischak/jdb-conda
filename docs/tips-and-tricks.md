# Tips and tricks

## Install a specific build

It is well-documented how to install a specific version of a conda package, e.g.
in the [cheatsheet][]. A single equals sign does fuzzy matching, e.g.
`python=3.6` will install the latest version of Python 3.6, and two equals signs
does exact matching, e.g. `python==3.6.4` will install Python 3.6.4.

However, what if you want to install a specific build number? This may not be
that useful for a typical end user that just wants a package that works, but is
really useful for a maintainer to perform tests. When I have searched for this
(which I have done many times), I most often find this [thread from
2014][thread-2014]. This thread demonstrates how to install numpy version 0.13.0
and build number np17py27_0:

```
conda install pandas=0.13.0=np17py27_0
```

Thus to install specific build numbers of r-base, which I was trying to do to
[troubleshoot R 3.3.2][troubleshoot-r-base], can be done with the following:

```
# Install build number 0
conda install r-base=3.3.2=0
# Install build number 1
conda install r-base=3.3.2=1
# Install build number 2
conda install r-base=3.3.2=2
# etc.
```

Note that this syntax is required. You must use a single equals sign and specify the full version string. None of the following would work:

```
# None of these work:
conda install r-base==3.3.2=0
conda install r-base=3.3=0
conda install 'r-base>=3.3.2=0'
```

[cheatsheet]: https://conda.io/docs/user-guide/cheatsheet.html
[thread-2014]: https://groups.google.com/a/continuum.io/forum/#!msg/conda/s6GbcODB8D0/NgR4nX1qiZIJ
[troubleshoot-r-base]: https://github.com/conda-forge/r-base-feedstock/pull/32

## Pin packages in an environment

Even if you install package with `=`, any subsequent call to `install` or
`update` can cause the package version to be upgraded or downgraded as needed by
the solver. To avoid having to always re-specify the required pins in each
`install`, you can pin packages in an environment. Unfortunately there is no
convenient command-line argument to indicate you want a package pinned to a
specific version. You have to manually create/edit/delete the file
`conda-meta/pinned` whenever you need to update the pins for an environment.

Source: [conda docs: Preventing packages from updating (pinning)](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-pkgs.html#preventing-packages-from-updating-pinning)

Here is an example:

```sh
# create an environment with specific versions
mamba create -n test-pins --yes \
  -c conda-forge --override-channels \
  python=3.9 tiledb=2.18 tiledb-py=0.24
mamba activate test-pins

ls $CONDA_PREFIX/conda-meta/pinned
## No such file or directory

# Installing python=3.7 would downgrade tiledb and tiledb-py
# (because the py37 tiledb-py 0.24 is only on the tiledb channel)
mamba install --dry-run -c conda-forge --override-channels python=3.7
## - python_abi      3.9  4_cp39                conda-forge     Cached
## + python_abi      3.7  4_cp37m               conda-forge        6kB
## - tiledb       2.18.2  h1f358a1_1            conda-forge     Cached
## + tiledb       2.11.3  h3f4058f_1            conda-forge        5MB
## - python       3.9.18  h0755675_0_cpython    conda-forge     Cached
## + python       3.7.12  hf930737_100_cpython  conda-forge       60MB
## - numpy        1.26.2  py39h474f0d3_0        conda-forge     Cached
## + numpy        1.21.6  py37h976b520_0        conda-forge        6MB
## - tiledb-py    0.24.0  py39h4d4131a_1        conda-forge     Cached
## + tiledb-py    0.17.5  py37h03e727e_0        conda-forge        1MB

# pinning prevents this
cat > $CONDA_PREFIX/conda-meta/pinned << EOF
tiledb=2.18
tiledb-py=0.24
EOF

mamba install --dry-run -c conda-forge --override-channels python=3.7
##
## Pinned packages:
##   - tiledb 2.18.*
##   - tiledb-py 0.24.*
##
## Could not solve for environment specs
```
