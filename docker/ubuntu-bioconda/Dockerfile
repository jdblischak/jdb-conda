# Ubuntu container for testing bioconda recipes.

FROM jdblischak/ubuntu-conda-forge

RUN conda config --add channels bioconda

RUN conda update --all

RUN git clone https://github.com/bioconda/bioconda-recipes.git
RUN git clone https://github.com/bioconda/bioconda-utils.git

RUN conda install --file bioconda-utils/bioconda_utils/bioconda_utils-requirements.txt

# pytz recently became a noarch package, which causes bioconda-utils
# problem. The quickest solution is to just install it with pip. See
# bioconda-utils #204.
RUN pip install pytz

RUN cd bioconda-utils/ && \
    python setup.py install && \
    cd ..

CMD [ "/bin/bash" ]
