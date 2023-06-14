# Ubuntu container for testing conda-forge recipes.

FROM ubuntu:xenial

WORKDIR /root
ENV PATH "/opt/conda/bin:$PATH"

# Set an encoding to make things work smoothly.
ENV LANG en_US.UTF-8

# Install basic requirements.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    curl \
    emacs \
    git \
    less \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Install the latest Miniconda with Python 3 and update everything.
RUN curl -s -L https://repo.continuum.io/miniconda/Miniconda3-4.3.21-Linux-x86_64.sh > miniconda.sh && \
    openssl md5 miniconda.sh | grep c1c15d3baba15bf50293ae963abef853 && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    conda config --set show_channel_urls True && \
    conda config --add channels conda-forge && \
    conda update --all --yes && \
    conda clean -tipy

# Install conda build and deployment tools.
RUN conda install --yes --quiet conda-build anaconda-client jinja2 setuptools && \
    conda clean -tipsy

# Install tools for interactive analysis
RUN conda install --yes --quiet ipython ipdb

RUN git clone https://github.com/conda-forge/staged-recipes.git ~/staged-recipes

CMD [ "/bin/bash" ]
