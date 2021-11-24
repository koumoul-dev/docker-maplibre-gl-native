FROM node:16-buster AS builder
ENV DEBIAN_FRONTEND noninteractive
ENV DISPLAY :99.0

RUN apt-get -qq update
RUN apt-get install -y --no-install-recommends \
  libuv1-dev libgles2-mesa-dev libglfw3-dev \
  cmake \
  xvfb xauth


RUN git clone https://github.com/koumoul-dev/maplibre-gl-native --single-branch --branch node-14

WORKDIR /maplibre-gl-native

RUN  git checkout deb395d04dc1da608d8cd9d10034b16a2a9acf33 && git submodule update --init --recursive

RUN  npm install --ignore-scripts
RUN  cmake . -B build -D MBGL_WITH_EGL=ON && cmake --build build







# Issue with alpine: 
#  - xvfb-run does not run anything and just wait
#  - libOpenGL.so.0 is missing, package mesa-gl contain only libOpenGL.so.1


# FROM node:16-alpine AS base_image_alpine
# ENV DISPLAY :99.0
# RUN apk -qq update && apk add --no-cache \
#   mesa-egl mesa-gl\
#   xvfb xauth xvfb-run

# FROM base_image_alpine AS testing_alpine
# COPY --from=builder /maplibre-gl-native /maplibre-gl-native
# WORKDIR /maplibre-gl-native
# RUN Xvfb :99 -ac -screen 0 1280x720x16 -nolisten tcp & npm run test






# Issue with 16 / 16-buster : 
#  - Too big: ~1Go


# Size: 1 037 310 364
# FROM node:16 AS base_image_buster
# RUN apt-get -qq update && apt-get install -y --no-install-recommends \
#   libegl1 libopengl0\
#   xvfb xauth

# FROM base_image AS testing_buster
# COPY --from=builder /maplibre-gl-native /maplibre-gl-native
# WORKDIR /maplibre-gl-native
# RUN  xvfb-run -a npm run test






# Size: 344 460 975
FROM node:16-slim AS base_image_slim
RUN apt-get -qq update && apt-get install -y --no-install-recommends \
  libegl1 libopengl0 libcurl4 libjpeg62-turbo libicu63\
  xvfb xauth

FROM base_image_slim AS testing_slim
COPY --from=builder /maplibre-gl-native /maplibre-gl-native
WORKDIR /maplibre-gl-native

RUN  xvfb-run -a npm run test


FROM base_image_slim AS final_image
COPY --from=builder /maplibre-gl-native/lib/node-v93/mbgl.node /maplibre-gl-native/lib/node-v93/mbgl.node
