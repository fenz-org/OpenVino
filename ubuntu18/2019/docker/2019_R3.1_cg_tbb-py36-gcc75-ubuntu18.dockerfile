ARG OV_VER="2019_R3.1"
ARG BASEOS_VER="ubuntu18"
FROM openvino/${BASEOS_VER}_runtime:${OV_VER} as runtime

FROM provarepro/openvino:2019_cg_deps-ubuntu18

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
    cd /openvino/inference-engine && \
    mkdir build && cd build && \
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DTHREADING=TBB \
        -DENABLE_DLIA=OFF \
        -DENABLE_VPU=OFF \
        -DENABPP=OFF \
        -DENABLE_PROFILING_ITT=OFF \
        -DENABLE_VALIDATION_SET=OFF \
        -DENABLE_TESTS=OFF \
        -DENABLE_GNA=OFF \
        -DENABLE_CLDNN=ON \
        -DENABLE_MKL_DNN=ON \
        -DENABLE_OPENCV=OFF \
        .. && \
    make --jobs=$(nproc --all) && \
    sed -i '/<plugins>/a \        <plugin name="MULTI" location="libMultiDevicePlugin.so">\n        </plugin>' \
           /openvino/inference-engine/bin/intel64/Release/lib/plugins.xml

COPY --from=runtime \
         /opt/intel/openvino/deployment_tools/inference_engine/lib/intel64/libMultiDevicePlugin.so \
         /openvino/inference-engine/bin/intel64/Release/lib/libMultiDevicePlugin.so

ENV LD_LIBRARY_PATH="/opt/opencv/lib:/openvino/inference-engine/bin/intel64/Release/lib" \
    InferenceEngine_DIR=/openvino/inference-engine/build

# Creating user openvino
RUN useradd -ms /bin/bash -G users openvino && \
    chown openvino -R /home/openvino

USER openvino

CMD ["/bin/bash"]
