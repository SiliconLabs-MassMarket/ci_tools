FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        git cmake ninja-build gperf ccache dfu-util device-tree-compiler wget \
        python3-dev python3-venv python3-tk xz-utils file make gcc gcc-multilib \
        g++-multilib libsdl2-dev libmagic1 curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Prepare Zephyr Python environment and west
RUN python3 -m venv /opt/zephyrproject/.venv && \
    . /opt/zephyrproject/.venv/bin/activate && \
    pip install --upgrade pip && \
    pip install west
    #west init /opt/zephyrproject && \
    # cd /opt/zephyrproject && \
    # west update && \
    # west zephyr-export && \
    # west packages pip --install

# Download and setup Zephyr SDK
WORKDIR /opt
RUN wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.17.4/zephyr-sdk-0.17.4_linux-x86_64.tar.xz > /dev/null 2>&1 && \
    wget -O sha256.sum https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.17.4/sha256.sum && \
    shasum --check --ignore-missing sha256.sum && \
    tar xvf zephyr-sdk-0.17.4_linux-x86_64.tar.xz > /dev/null 2>&1 && \
    cd zephyr-sdk-0.17.4 && \
    ./setup.sh -c -t arm-zephyr-eabi

# (Optional) Add Zephyr SDK or west to PATH (if needed by default)
ENV PATH="/opt/zephyr-sdk-0.17.4:${PATH}"
ENV PATH="/opt/zephyrproject/.venv/bin:${PATH}"

# Set default workdir
WORKDIR /workspace
