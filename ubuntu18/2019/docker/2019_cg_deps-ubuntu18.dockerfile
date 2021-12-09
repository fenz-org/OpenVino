ARG BASE_IMAGE=provarepro/openvino:2019_c_deps-ubuntu18
FROM ${BASE_IMAGE}

#Install Intel Graphics Compute Runtime for OpenCL Driver package 19.04.12237.
RUN apt-get update && \
    apt-get install -y --no-install-recommends ocl-icd-libopencl1 && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /neo && cd /neo && \
    curl -LO https://github.com/intel/compute-runtime/releases/download/19.41.14441/intel-gmmlib_19.3.2_amd64.deb && \
    curl -LO https://github.com/intel/compute-runtime/releases/download/19.41.14441/intel-igc-core_1.0.2597_amd64.deb && \
    curl -LO https://github.com/intel/compute-runtime/releases/download/19.41.14441/intel-igc-opencl_1.0.2597_amd64.deb && \
    curl -LO https://github.com/intel/compute-runtime/releases/download/19.41.14441/intel-opencl_19.41.14441_amd64.deb && \
    curl -LO https://github.com/intel/compute-runtime/releases/download/19.41.14441/intel-ocloc_19.41.14441_amd64.deb && \
    sudo dpkg -i *.deb && \
    ldconfig && \
    cd / && rm -rf /neo
