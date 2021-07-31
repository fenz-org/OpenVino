ARG BASE_IMAGE=provarepro/openvino:2020_c_deps-ubuntu18
FROM ${BASE_IMAGE}

USER root

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

RUN git clone \
        --depth 1 \
        --single-branch \
        -b 2020.3.1 \
        https://github.com/openvinotoolkit/openvino.git && \
    cd /openvino && \
    git submodule update --init --recursive && \
    ./install_dependencies.sh && \
    apt-get purge -y cmake && \
    rm -rf /var/lib/apt/lists/* && \ 
    cd /usr/bin/ && rm python && \
    ln -s python3 python && \
    cd /openvino && \
    mkdir build && cd build && \
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DTHREADING=OMP \
        -DENABLE_DLIA=OFF \
        -DENABLE_VPU=OFF \
        -DENABPP=OFF \
        -DENABLE_PROFILING_ITT=OFF \
        -DENABLE_VALIDATION_SET=OFF \
        -DENABLE_TESTS=OFF \
        -DENABLE_GNA=OFF \
        -DENABLE_CLDNN=OFF \
        -DENABLE_MKL_DNN=ON \
        -DENABLE_OPENCV=OFF \
        -DNGRAPH_ONNX_IMPORT_ENABLE=OFF \
        -DNGRAPH_DEPRECATED_ENABLE=FALSE \
        .. && \
    make --jobs=$(nproc --all)

ENV LD_LIBRARY_PATH="/openvino/inference-engine/temp/omp/lib/:/opt/opencv/lib:/openvino/bin/intel64/Release/lib" \
    InferenceEngine_DIR=/openvino/build

# Creating user openvino
RUN useradd -ms /bin/bash -G users openvino && \
    chown openvino -R /home/openvino

USER openvino

CMD ["/bin/bash"]
