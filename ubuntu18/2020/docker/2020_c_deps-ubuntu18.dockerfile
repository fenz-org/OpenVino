ARG BASE_IMAGE=ubuntu:18.04
FROM ${BASE_IMAGE}

USER root

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    OPENCV_VERSION="4.3.0" \
    CMAKE_VERSION="3.17.2" \
    PYTHON_VERSION="3.6"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        cmake \
        build-essential \
        curl \
        unzip \
        ca-certificates \
        sudo \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-distutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /usr/bin/ && \
    ln -s python3 python

WORKDIR /

RUN curl https://bootstrap.pypa.io/get-pip.py -o /get-pip.py && \
    python${PYTHON_VERSION} /get-pip.py && \
    rm /get-pip.py && \
    python${PYTHON_VERSION} -m pip install \
        numpy \
        cython \
        cmake==${CMAKE_VERSION}

RUN curl -LO https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
    unzip -q ${OPENCV_VERSION}.zip && \
    rm ${OPENCV_VERSION}.zip && \
    cd /opencv-${OPENCV_VERSION} && \
    mkdir build && cd build && \
    cmake \
        -DPYTHON_EXECUTABLE=/usr/bin/python${PYTHON_VERSION} \
        -DPYTHON3_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython${PYTHON_VERSION}m.so \
        -DPYTHON3_INCLUDE_DIR=/usr/include/python${PYTHON_VERSION} \
        -DCMAKE_INSTALL_PREFIX=/opt/opencv \
        .. && \
    cmake --build . && make install && \
    cd / && \
    rm -rf /opencv-${OPENCV_VERSION}

ENV OpenCV_DIR=/opt/opencv/lib/cmake/opencv4
