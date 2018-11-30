FROM continuumio/miniconda3:4.5.11
# https://hub.docker.com/r/continuumio/miniconda3/
# https://github.com/ContinuumIO/docker-images/blob/miniconda3-4.3.27p0/miniconda3/Dockerfile

# Build: docker build -t test-conda-build .
# Run: docker run --rm -it test-conda-build
# Remove exited containers:
#   docker ps -aq --no-trunc -f status=exited | xargs docker rm
# Remove untagged images:
#   docker images -q --filter dangling=true | xargs docker rmi

MAINTAINER John Blischak, jdblischak@gmail.com

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    diffoscope \
    emacs \
    git \
    nano

RUN conda config --add channels defaults && \
    conda config --add channels conda-forge

RUN conda config \
  --set always_yes yes \
  --set changeps1 no \
  --set auto_update_conda False

RUN conda install conda-build conda-verify patchelf py-lief

RUN git clone https://github.com/jdblischak/conda-build.git

WORKDIR conda-build

RUN git remote add upstream https://github.com/conda/conda-build.git

RUN conda build conda.recipe/

RUN conda install --use-local conda-build

ENV PYTHONPATH .

CMD [ "/bin/bash" ]
