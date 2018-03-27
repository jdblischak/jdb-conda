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
