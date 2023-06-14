# Ubuntu container for testing conda-forge recipes.

FROM ubuntu:jammy

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

# Install Mambaforge and update everything.
RUN curl -s -L https://github.com/conda-forge/miniforge/releases/download/23.1.0-1/Mambaforge-23.1.0-1-Linux-x86_64.sh > mambaforge.sh && \
    openssl sha256 mambaforge.sh | grep cfb16c47dc2d115c8b114280aa605e322173f029fdb847a45348bf4bd23c62ab && \
    bash mambaforge.sh -b -p /opt/conda && \
    rm mambaforge.sh && \
    conda config --set show_channel_urls True && \
    mamba update --all --yes && \
    conda clean -tipy

# Install conda build and deployment tools.
RUN mamba install --yes --quiet conda-build anaconda-client jinja2 setuptools && \
    conda clean -tipy

# Install tools for interactive analysis
RUN mamba install --yes --quiet ipython ipdb && \
    conda clean -tipy

RUN git clone https://github.com/conda-forge/staged-recipes.git ~/staged-recipes

CMD [ "/bin/bash" ]
