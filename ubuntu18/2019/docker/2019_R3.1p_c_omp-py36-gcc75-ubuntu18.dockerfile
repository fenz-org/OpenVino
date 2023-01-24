ARG BASE_IMAGE=provarepro/openvino:2019_c_deps-ubuntu18
FROM ${BASE_IMAGE}

USER root

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

RUN git clone \
        --depth 1 \
        --single-branch \
        -b 2019_R3.1 \
        https://github.com/openvinotoolkit/openvino.git && \
    cd /openvino && \
    wget https://raw.githubusercontent.com/openvinotoolkit/openvino/releases/2019/pre-release/inference-engine/src/inference_engine/cnn_network_int8_normalizer.cpp \
        -O inference-engine/src/inference_engine/cnn_network_int8_normalizer.cpp && \
    git submodule update --init --recursive && \
    cd inference-engine && \
    ./install_dependencies.sh && \
    cd /usr/bin/ && rm python && \
    ln -s python3 python && \
    cd /openvino/inference-engine && \
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
        .. && \
    make --jobs=$(nproc --all)

ENV LD_LIBRARY_PATH="/openvino/inference-engine/temp/omp/lib/:/opt/opencv/lib:/openvino/inference-engine/bin/intel64/Release/lib" \
    InferenceEngine_DIR=/openvino/inference-engine/build

# Creating user openvino
RUN useradd -ms /bin/bash -G users openvino && \
    chown openvino -R /home/openvino

USER openvino

CMD ["/bin/bash"]
