FROM ubuntu:18.04 as spike-builder
RUN apt-get -y update
RUN apt-get install -y curl git make gcc g++ autoconf automake autotools-dev
RUN apt-get install -y libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev
RUN apt-get install -y gawk build-essential bison flex texinfo gperf libtool
RUN apt-get install -y patchutils bc zlib1g-dev device-tree-compiler pkg-config libexpat-dev

RUN git clone https://github.com/riscv/riscv-tools --depth=1 --recursive
ENV RISCV /install
WORKDIR /riscv-tools/riscv-fesvr
RUN git checkout f683e01
WORKDIR /riscv-tools
RUN /riscv-tools/build.sh

WORKDIR /riscv-tools/riscv-gnu-toolchain
RUN ./configure --prefix=$RISCV
RUN make linux

FROM ubuntu:18.04 as qemu-builder
RUN apt-get -y update
RUN apt-get install -y gcc g++ libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev
RUN apt-get install -y git python
RUN git clone --recursive https://github.com/riscv/riscv-qemu.git
WORKDIR /riscv-qemu
RUN ./configure --prefix=/install --target-list=riscv64-softmmu,riscv32-softmmu,riscv64-linux-user,riscv32-linux-user
RUN make -j4
RUN make install

FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y sudo vim device-tree-compiler make
RUN apt-get install -y curl git make gcc g++ autoconf automake autotools-dev
RUN apt-get install -y libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev
RUN apt-get install -y gawk build-essential bison flex texinfo gperf libtool
RUN apt-get install -y patchutils bc zlib1g-dev device-tree-compiler pkg-config libexpat-dev
RUN apt-get install -y libpixman-1-dev libfdt-dev libglib2.0-dev zlib1g-dev
RUN apt-get install -y python3-pip
COPY --from=spike-builder /install /usr/local
COPY --from=qemu-builder /install /usr/local
ENV RISCV /usr/local
ENV LD_LIBRARY_PATH=$RISCV/lib
ENV pk=$RISCV/riscv64-unknown-elf/bin/pk

ENTRYPOINT []
