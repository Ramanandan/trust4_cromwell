FROM ubuntu:22.04

LABEL base.image="quay.io/biocontainers/trust4:1.0.13--h43eeafb_0"
LABEL TRUST4_version="1.0.13"
LABEL 
quayio.url="https://quay.io/repository/biocontainers/trust4?tab=tags"

ARG TRUST4_VERSION=1.0.13
ARG CROMWELL_VERSION=85

RUN mkdir -p /resources

WORKDIR /resources

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    curl \
    unzip \
    zlib1g-dev \
    python3 \
    python3-pip \
    perl \
    git \
    wget \
    default-jre \
    default-jdk \
    lsb-release \
    gnupg && \
    apt-get clean

# Add TRUST4 references
ADD references/human_IMGT_C.fa /resources/human_IMGT_C.fa
ADD references/hg38_bcrtcr.fa /resources/hg38_bcrtcr.fa

# Install TRUST4
RUN wget 
https://github.com/liulab-dfci/TRUST4/archive/refs/tags/v${TRUST4_VERSION}.tar.gz 
&& \
    tar -xzf v${TRUST4_VERSION}.tar.gz && \
    rm v${TRUST4_VERSION}.tar.gz && \
    mv TRUST4-${TRUST4_VERSION} TRUST4 && \
    cd TRUST4 && \
    make

ENV PATH="/resources/TRUST4":$PATH

# Install Cromwell and Womtool
RUN wget 
https://github.com/broadinstitute/cromwell/releases/download/${CROMWELL_VERSION}/cromwell-${CROMWELL_VERSION}.jar 
-O /usr/local/bin/cromwell.jar && \
    wget 
https://github.com/broadinstitute/cromwell/releases/download/${CROMWELL_VERSION}/womtool-${CROMWELL_VERSION}.jar 
-O /usr/local/bin/womtool.jar

# Create alias or wrapper for easier use (optional)
RUN echo '#!/bin/bash\njava -jar /usr/local/bin/cromwell.jar "$@"' > 
/usr/local/bin/cromwell && \
    chmod +x /usr/local/bin/cromwell && \
    echo '#!/bin/bash\njava -jar /usr/local/bin/womtool.jar "$@"' > 
/usr/local/bin/womtool && \
    chmod +x /usr/local/bin/womtool

# Set default workdir
WORKDIR /resources

