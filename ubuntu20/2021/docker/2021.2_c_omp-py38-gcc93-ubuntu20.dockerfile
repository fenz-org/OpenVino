ARG BASE_IMAGE=provarepro/openvino:2021.2_c_deps-ubuntu20
FROM ${BASE_IMAGE}

USER root

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

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
        -DCMAKE_BUILD_TYPE=Release \
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

ENV LD_LIBRARY_PATH="/openvino/inference-engine/temp/omp/lib/:/openvino/inference-engine/temp/opencv_4.5.0_ubuntu20/opencv/lib:/openvino/bin/intel64/Release/lib" \
    InferenceEngine_DIR=/openvino/build

# Creating user openvino
RUN useradd -ms /bin/bash -G users openvino && \
    chown openvino -R /home/openvino

USER openvino

CMD ["/bin/bash"]
