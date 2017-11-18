FROM debian:jessie
RUN echo 'deb http://http.debian.net/debian jessie-backports main' >> /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y -t jessie-backports dos2unix curl unzip openjdk-8-jdk
#VOLUME /sdks
ENV sdk_dir /sdks
COPY . /app
RUN cp /app/source/Env.mc.sample /app/source/Env.mc && \
   find /app -type f -name '*.sh' -or -name '*.xml' -or -name '*.mc' -or -name '*.sh' | xargs dos2unix -q
RUN cd /app && \
  bash ./install-connectiq-sdk.sh && \
  bash ./build-connectiq-app.sh
