# Copyright 2019 the Tectonic Project
# Licensed under the MIT License.

FROM ubuntu:18.04 AS builder
ARG tag=v0.1.16

RUN TERM=dumb \
    apt-get update \
    && apt-get install -y \
        build-essential \
        curl \
        git \
        patch \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |sh -s -- -y

ADD 001-privileges.patch /
RUN git clone https://github.com/rust-embedded/cross.git \
    && cd cross \
    && git checkout $tag \
    && patch -p1 -i /001-privileges.patch

RUN cd cross && PATH=$HOME/.cargo/bin:$PATH cargo install --force --path .

# Use Docker's fancy multiple-FROM / COPY --from functionality to make a super
# minimal container that just copies the binary out into the host system.

FROM alpine:3.10
COPY --from=builder /root/.cargo/bin/cross /
VOLUME /work
CMD ["cp", "/cross", "/work/"]
