FROM ubuntu:22.04

# Update and install initial packages
RUN apt-get update && apt-get install -y \
    sudo \
    apt-utils \
    locales \
    vim \
    wget \
    curl

# Define username and user ID
ARG USER=tester
ARG USER_ID

# Setup locale
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y locales && \
    dpkg-reconfigure locales --frontend noninteractive && \
    locale-gen "en_US.UTF-8" && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install required packages for Google Test
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++ \
    git \
    && apt-get clean

# Clone and install Google Test
WORKDIR /home/${USER}/Workspace/gtest
RUN git clone https://github.com/google/googletest.git && \
    cd googletest && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local . && \
    make -j$(nproc) && \
    make install && \
    cd .. && rm -rf googletest

# User management
RUN useradd -m -u ${USER_ID} -s /bin/bash ${USER} && \
    usermod -a -G sudo ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory and switch to non-root user
WORKDIR /home/${USER}/Workspace/
RUN chown -R ${USER}:${USER} /home/${USER}
USER ${USER}
