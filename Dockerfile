FROM node:16-buster
ENV DEBIAN_FRONTEND noninteractive

ENV DISPLAY :99.0

RUN apt-get -qq update
RUN apt-get install -y --no-install-recommends \
  libuv1-dev libgles2-mesa-dev libglfw3-dev \
  cmake \
  xvfb xauth

WORKDIR /maplibre-gl-native

RUN mkdir lib

RUN git clone https://github.com/koumoul-dev/maplibre-gl-native --single-branch --branch node-14 &&\
  cd ./maplibre-gl-native &&\
  git checkout bf86ef116f245de768e95f4ed3a1d6d778e2fa0b &&\
  git submodule update --init --recursive &&\
  npm install --ignore-scripts &&\
  cmake . -B build -D MBGL_WITH_EGL=ON && cmake --build build &&\
  xvfb-run -s ":99" npm run test &&\
  mv lib ../lib &&\
  rm -rf *

