ARG BASE_IMAGE=provarepro/openvino:2019_c_deps-ubuntu20
FROM ${BASE_IMAGE}

USER root

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

RUN git clone \
        --depth 1 \
        --single-branch \
        -b 2019_R3.1 \
        https://github.com/openvinotoolkit/openvino.git && \
    cd /openvino && \
    git submodule update --init --recursive && \
    cd inference-engine && \
    ./install_dependencies.sh && \
    cd /usr/bin/ && rm python && \
    ln -s python3 python && \
    update-alternatives \
        --install /usr/bin/gcc gcc /usr/bin/gcc-7 70 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-7 \
        --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-7 \
        --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-7 \
        --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-7 \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-7 \
        --slave /usr/bin/gcov-dump gcov-dump /usr/bin/gcov-dump-7 \
        --slave /usr/bin/gcov-tool gcov-tool /usr/bin/gcov-tool-7 && \
    update-alternatives \
        --install /usr/bin/cpp cpp /usr/bin/cpp-7 70 && \
    cd /openvino/inference-engine && \
    mkdir build && cd build && \
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DTHREADING=OMP \
        -DENABLE_DLIA=OFF \
        -DENABLE_VPU=OFF \
        -DENABLE_VALIDATION_SET=OFF \
        -DENABLE_TESTS=OFF \
        -DENABLE_GNA=OFF \
        -DENABLE_CLDNN=OFF \
        -DENABLE_MKL_DNN=ON \
        -DENABLE_OPENCV=OFF \
        **-DNGRAPH_ONNX_IMPORT_ENABLE=OFF \
        -DNGRAPH_DEPRECATED_ENABLE=FALSE** \
        .. && \
    make --jobs=$(nproc --all)

#    cmake \
#        -DCMAKE_BUILD_TYPE=Release \
#        -DTHREADING=OMP \
#        -DENABLE_DLIA=OFF \
#        -DENABLE_VPU=OFF \
#        -DENABPP=OFF \
#        -DENABLE_PROFILING_ITT=OFF \
#        -DENABLE_VALIDATION_SET=OFF \
#        -DENABLE_TESTS=OFF \
#        -DENABLE_GNA=OFF \
#        -DENABLE_CLDNN=OFF \
#        -DENABLE_MKL_DNN=ON \
#        -DENABLE_OPENCV=OFF \
#        .. && \
#    make --jobs=$(nproc --all)

ENV LD_LIBRARY_PATH="/openvino/inference-engine/temp/omp/lib/:/opt/opencv/lib:/openvino/inference-engine/bin/intel64/Release/lib" \
    InferenceEngine_DIR=/openvino/inference-engine/build

# Creating user openvino
RUN useradd -ms /bin/bash -G users openvino && \
    chown openvino -R /home/openvino

USER openvino

CMD ["/bin/bash"]
