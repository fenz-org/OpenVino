ARG OV_VER="2019_R3.1"
ARG BASEOS_VER="ubuntu18"
FROM openvino/${BASEOS_VER}_runtime:${OV_VER} as runtime

ARG BASE_IMAGE=provarepro/openvino:2019_cg_deps-ubuntu18
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
        -DENABLE_CLDNN=ON \
        -DENABLE_MKL_DNN=ON \
        -DENABLE_OPENCV=OFF \
        .. && \
    make --jobs=$(nproc --all)

COPY --from=runtime \
         /opt/intel/openvino/deployment_tools/inference_engine/lib/intel64/libMultiDevicePlugin.so \
         /openvino/inference-engine/bin/intel64/Release/lib/libMultiDevicePlugin.so

#Manually add MULTI plugin if was missing
RUN grep -qF '<plugin name="MULTI" location="libMultiDevicePlugin.soa">' plugins.xml || \
        sed -i '/<plugins>/a \        <plugin name="MULTI" location="libMultiDevicePlugin.so">\n        </plugin>' plugins.xml

ENV LD_LIBRARY_PATH="/openvino/inference-engine/temp/omp/lib/:/opt/opencv/lib:/openvino/inference-engine/bin/intel64/Release/lib" \
    InferenceEngine_DIR=/openvino/inference-engine/build

# Creating user openvino
RUN useradd -ms /bin/bash -G users openvino && \
    chown openvino -R /home/openvino

USER openvino

CMD ["/bin/bash"]
