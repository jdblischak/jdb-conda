# Ubuntu container for testing bioconda recipes.

FROM jdblischak/ubuntu-conda-forge

RUN conda config --add channels bioconda

RUN conda update --all

RUN git clone https://github.com/bioconda/bioconda-recipes.git
RUN git clone https://github.com/bioconda/bioconda-utils.git

RUN conda install --file bioconda-utils/bioconda_utils/bioconda_utils-requirements.txt

RUN cd bioconda-utils/ && \
    python setup.py install && \
    cd ..

CMD [ "/bin/bash" ]
