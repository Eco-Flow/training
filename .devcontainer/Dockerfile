FROM mcr.microsoft.com/devcontainers/base:ubuntu

USER root

# Install util tools.
RUN apt-get update --quiet && \
    apt-get install --yes \
        apt-transport-https \
        apt-utils \
        sudo \
        git \
        less \
        wget \
        curl \
        tree \
        python3 \
        r-base

# Install java
ENV JAVA_VERSION=17
RUN apt-get update && apt-get install -y \
    openjdk-${JAVA_VERSION}-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install nextflow
RUN curl -s https://get.nextflow.io | bash && \
    chmod +x nextflow && \
    mv nextflow /usr/local/bin/nextflow

# Install nf-test
RUN curl -fsSL https://code.askimed.com/install/nf-test | bash && \
    mv nf-test /usr/local/bin/nf-test

RUN Rscript -e "install.packages(c('BiocManager'))"

RUN Rscript -e "BiocManager::install('DESeq2')"

USER vscode
