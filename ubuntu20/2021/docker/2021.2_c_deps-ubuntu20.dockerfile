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
        build-essential \
        git \
        curl \
        ca-certificates \
        libglib2.0-dev \
        libtbb-dev \
        cmake \
        python${PYTHON_VERSION}-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /usr/bin/ && rm -f python && \
    ln -s python3 python && \
    cd / && \
    curl https://bootstrap.pypa.io/get-pip.py -o /get-pip.py && \
    python${PYTHON_VERSION} /get-pip.py && \
    rm /get-pip.py && \
    python${PYTHON_VERSION} -m pip install \
        numpy \
        cython

ARG OV_VER="releases/2021/2"

RUN git clone \
        --depth 1 \
        --single-branch \
        -b ${OV_VER} \
        https://github.com/openvinotoolkit/openvino.git && \
    cd /openvino && \
    git submodule update --init --recursive && \
    mkdir build && cd build && \
    cmake \
        -DENABLE_VPU=OFF \
        -DENABLE_CLDNN=OFF \
        -DTHREADING=OMP \
        -DENABLE_GNA=OFF \
        -DENABLE_DLIA=OFF \
        -DENABLE_TESTS=OFF \
        -DENABLE_VALIDATION_SET=OFF \
        -DNGRAPH_ONNX_IMPORT_ENABLE=OFF \
        -DNGRAPH_DEPRECATED_ENABLE=FALSE \
        -DPYTHON_EXECUTABLE=`which python3` \
        .. && \
    TEMPCV_DIR=/openvino/inference-engine/temp/opencv_4* && \
    OPENCV_DIRS=$(ls -d -1 ${TEMPCV_DIR} ) && \
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${OPENCV_DIRS[0]}/opencv/lib && \
    make --jobs=$(nproc --all)

