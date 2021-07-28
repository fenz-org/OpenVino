ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE}

USER root

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    OPENCV_VERSION="4.3.0" \
    PYTHON_VERSION="3.8"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        cmake \
        make \
        dirmngr \
        dpkg-dev \
        fakeroot \
        gcc-7 \
        g++-7 \
        gnupg \
        gnupg-l10n \
        gnupg-utils \
        gpg \
        gpg-agent \
        gpg-wks-client \
        gpg-wks-server \
        gpgconf \
        gpgsm \
        libalgorithm-diff-perl \
        libalgorithm-diff-xs-perl \
        libalgorithm-merge-perl \
        libassuan0 \
        libdpkg-perl \
        libfakeroot \
        libfile-fcntllock-perl \
        libksba8 \
        liblocale-gettext-perl \
        libnpth0 \
        libubsan1 \
        patch \
        pinentry-curses \
        xz-utils \
        curl \
        unzip \
        ca-certificates \
        sudo \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-distutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives \
        --install /usr/bin/gcc gcc /usr/bin/gcc-7 70 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-7 \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-7 && \
    cd /usr/bin/ && \
    ln -s python3 python && \
    cd / && \
    curl https://bootstrap.pypa.io/get-pip.py -o /get-pip.py && \
    python${PYTHON_VERSION} /get-pip.py && \
    rm /get-pip.py && \
    python${PYTHON_VERSION} -m pip install \
        numpy \
        cython && \
    curl -LO https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
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
    cmake --build . && make install

ENV OpenCV_DIR=/opt/opencv/lib/cmake/opencv4
