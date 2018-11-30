FROM continuumio/miniconda3:latest
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=840482
# https://github.com/conda-forge/python-libarchive-c-feedstock/issues/13

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git

RUN conda config --add channels defaults && \
    conda config --add channels conda-forge

RUN conda config \
  --set always_yes yes \
  --set changeps1 no

RUN git clone https://github.com/conda-forge/python-libarchive-c-feedstock.git

WORKDIR python-libarchive-c-feedstock/recipe

RUN conda install python-libarchive-c

# https://github.com/conda-forge/python-libarchive-c-feedstock/blob/master/recipe/meta.yaml#L37
ENV TEST "import libarchive; libarchive.extract_file('test/hello_world.xar')"

RUN python -c "$TEST" ; exit 0

RUN conda install diffoscope

RUN python -c "$TEST" ; exit 0

RUN apt-get install -y --no-install-recommends diffoscope

RUN python -c "$TEST" ; exit 0

CMD [ "/bin/bash" ]
