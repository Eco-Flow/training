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

USER vscode

# Install nextflow
RUN curl -s https://get.nextflow.io | bash && \
    chmod +x nextflow && \
    sudo mv nextflow /usr/local/bin/nextflow

# Install nf-test
RUN curl -fsSL https://code.askimed.com/install/nf-test | bash && \
    sudo mv nf-test /usr/local/bin/nf-test

RUN sudo Rscript -e "install.packages(c('BiocManager'))"

RUN sudo Rscript -e "BiocManager::install('DESeq2')"
