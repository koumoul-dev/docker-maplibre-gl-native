FROM node:16-buster
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update
RUN apt-get install -y --no-install-recommends \
  libuv1-dev libgles2-mesa-dev libglfw3-dev \
  cmake \
  xvfb xauth

RUN git clone https://github.com/koumoul-dev/maplibre-gl-native --single-branch --branch node-14 &&\
  cd /maplibre-gl-native &&\
  git checkout bf86ef116f245de768e95f4ed3a1d6d778e2fa0b
WORKDIR /maplibre-gl-native

RUN git submodule update --init --recursive
RUN npm ci --ignore-scripts

RUN cmake . -B build -D MBGL_WITH_EGL=ON
RUN cmake --build build

ENV DISPLAY :99.0
RUN xvfb-run -s ":99" npm run test

