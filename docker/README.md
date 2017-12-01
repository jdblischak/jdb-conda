# Dockerfiles

This directory contains the source Dockerfiles I use to build containers for
testing conda-related things.

* `ubuntu-conda-forge/` - For testing conda-forge recipes. Based on Ubuntu
  16.04.


I modeled my Dockerfiles off of the following Dockerfiles:

* [condaforge/linux-anvil](https://github.com/conda-forge/docker-images/blob/2f303f27d78029ca925d998b868c7db1bab4c7ab/linux-anvil/Dockerfile)
* [bioconda/bioconda-utils-build-env](https://github.com/bioconda/bioconda-utils/blob/b83cf28d71e70e03b7fdb3ec35f4b88109a0fa7c/Dockerfile)
* [rocker/r-base](https://hub.docker.com/r/rocker/r-base/~/dockerfile/)
