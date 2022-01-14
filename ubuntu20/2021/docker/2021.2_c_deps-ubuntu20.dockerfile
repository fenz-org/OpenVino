ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE}

USER root

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    PYTHON_VERSION="3.8"

RUN apt-get update && \
    apt-get install -y \
        git \
        ca-certificates \
        libglib2.0-dev \
        libtbb-dev \
        cmake \
        python${PYTHON_VERSION}-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /usr/bin/ rm -f python && \
    ln -s python3 python && \
    cd / && \
    curl https://bootstrap.pypa.io/get-pip.py -o /get-pip.py && \
    python${PYTHON_VERSION} /get-pip.py && \
    rm /get-pip.py && \
    python${PYTHON_VERSION} -m pip install \
        numpy \
        cython
