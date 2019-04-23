FROM ubuntu:18.04 AS ccls_build_env

ENV LLVM_PREBUILT_NAME=clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04

RUN apt-get update && apt-get install -y git make cmake zlib1g-dev libncurses-dev curl clang \
  && mkdir /llvm && curl -SL https://releases.llvm.org/8.0.0/${LLVM_PREBUILT_NAME}.tar.xz | tar xJ -C /llvm

RUN git clone --depth=1 --recursive https://github.com/MaskRay/ccls /ccls \
  && cd /ccls \
  && cmake -H. -BRelease -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_PREFIX_PATH=/llvm/${LLVM_PREBUILT_NAME}/ \
  && cmake --build Release --target install

FROM ubuntu:18.04

ENV LLVM_PREBUILT_NAME=clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04

COPY --from=ccls_build_env /llvm/${LLVM_PREBUILT_NAME}/lib/clang/8.0.0 /llvm/${LLVM_PREBUILT_NAME}/lib/clang/8.0.0

COPY --from=ccls_build_env /usr/local/bin/ccls /usr/local/bin

CMD ["ccls"]

# FROM alpine:latest

# ENV LLVM_PREBUILT_NAME=clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04

# RUN apk update && apk add clang binutils make cmake git zlib-dev ncurses-dev curl tar xz \
#   && mkdir /llvm && curl -SL https://releases.llvm.org/8.0.0/${LLVM_PREBUILT_NAME}.tar.xz | tar xJ -C /llvm

# RUN apk add build-base && git clone --depth=1 --recursive https://github.com/MaskRay/ccls /ccls \
#   && cd /ccls \
#   && cmake -H. -BRelease -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_CXX_COMPILER=g++ -DCMAKE_PREFIX_PATH=/llvm/${LLVM_PREBUILT_NAME}/ \
#   && cmake --build Release
