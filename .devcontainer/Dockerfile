FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04 AS builder
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get upgrade -y \
    && apt-get -y install --no-install-recommends git cmake
RUN git clone --depth 1 https://github.com/microsoft/pict \
    && cd pict \
    && cmake -DCMAKE_BUILD_TYPE=Release -S . -B build \
    && cmake --build build

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04
COPY --from=builder /pict/build/cli/pict /usr/local/bin/pict
