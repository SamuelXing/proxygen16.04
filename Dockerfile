FROM ubuntu:16.04
MAINTAINER SamuelXing

# Some extra dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -yq \
        g++ \
        cmake \
        wget \
        libboost-all-dev \
        libevent-dev \
        libdouble-conversion-dev \
        libgoogle-glog-dev \
        libgflags-dev \
        libiberty-dev \
        liblz4-dev \
        liblzma-dev \
        libsnappy-dev \
        make \
        zlib1g-dev \
        binutils-dev \
        libjemalloc-dev \
        libssl-dev \
        libsodium-dev \
        flex \
        bison \
        libkrb5-dev \
        libsasl2-dev \
        libnuma-dev \
        libcap-dev \
        gperf \
        autoconf-archive \
        libtool \
        unzip \
        pkg-config \
        apt-utils \
        git \
        bc \
        hardening-wrapper \
        sudo

ENV DEB_BUILD_HARDENING=1

RUN wget https://github.com/google/googletest/archive/release-1.8.0.tar.gz && \
    tar zxf release-1.8.0.tar.gz && \
    rm -f release-1.8.0.tar.gz && \
    cd googletest-release-1.8.0 && \
    cmake . && \
    make && \
    make install

RUN cd /home && git clone https://github.com/fmtlib/fmt.git && \
    cd fmt && git checkout fdcf7870a2e5b543144cf38aceec85c3d05d8dff && \
    mkdir _build && cd _build && \
    cmake .. && \
    make -j$(nproc) && \
    sudo make install && \
    cd /home && rm -rf fmt

# Clone the Folly library
RUN cd /home && git clone https://github.com/facebook/folly && \
    cd folly && git checkout c60619007b356bb03784539dc1a347c9d4713b7e && \
    mkdir build_ && cd build_ && \
    cmake configure .. -DBUILD_SHARED_LIBS:BOOL=ON -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON && \
    make -j $(nproc) && \
    sudo make install && \
    cd /home && rm -rf folly

# Clone the Fizz library
RUN cd /home && git clone https://github.com/facebookincubator/fizz && \
    cd fizz && git checkout bf5820d87841f061e2f355741b4dedf5f3faf039 && \
    mkdir build_ && cd build_ && \
    cmake ../fizz && \
    make -j $(nproc) && \
    sudo make install && \
    cd /home && rm -rf fizz

# Get wangle
RUN cd /home && git clone https://github.com/facebook/wangle && \
    cd wangle && git checkout fae764dfefa6f929a97eeb37edd6eb7ebf83e2b7 && \
    mkdir _build && cd _build && \
    cmake ../wangle && \
    make -j $(nproc) && \
    sudo make install && \
    cd /home && rm -rf wangle

# Clone the ProxyGen library
COPY deps.sh /home/
RUN cd /home && git clone https://github.com/facebook/proxygen.git && \
    cd proxygen && git checkout d3f694c582b0beea41f1e97e8e33b8a8c4968a81 && \
    cd proxygen && cp /home/deps.sh ./ && \
    ./reinstall.sh && \
    apt-get update && ./deps.sh -j $(printf %.0f $(echo "$(nproc) * 1.5" | bc -l)) && \
    cd /home && rm -rf /proxygen

# Tell the linker where to find ProxyGen and friends
ENV LD_LIBRARY_PATH /usr/local/lib

