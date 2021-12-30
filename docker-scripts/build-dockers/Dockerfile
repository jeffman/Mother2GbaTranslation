FROM mcr.microsoft.com/powershell:ubuntu-20.04 AS builder
RUN echo "------------------Updating System------------------"
RUN apt update
RUN apt upgrade
RUN apt install -y wget gcc-arm-none-eabi cmake build-essential tar git
RUN echo "------------------Installing dotnet core------------------"
RUN mkdir -p /opt/dep
WORKDIR /opt/dep
RUN wget https://dot.net/v1/dotnet-install.sh
RUN chmod +x dotnet-install.sh
RUN ./dotnet-install.sh -c 2.1
RUN echo "-------------------Installing armips------------------"
RUN git clone --recursive https://github.com/Kingcom/armips.git
WORKDIR /opt/dep/armips
# Need a buildable commit...
RUN git checkout d481fe7a48b3ef02ce5358291a240819ff5742f1
RUN mkdir -p bld
WORKDIR /opt/dep/armips/bld
RUN cmake ../
RUN make -j
RUN mkdir -p /opt/src/bin
RUN cp /opt/dep/armips/bld/armips /opt/src/bin/armips
RUN cp /opt/dep/armips/bld/armipstests /opt/src/bin/armipstests
RUN cp /opt/dep/armips/bld/libarmips.a /opt/src/bin/libarmips.a
RUN useradd m2gba -m
RUN mkdir -p /home/m2gba/src
RUN cp /root/.dotnet /home/m2gba/.dotnet -R && rm -rf /opt/dep && rm -rf /opt/miscrosoft && rm -rf /root/.dotnet
RUN chown -R m2gba:m2gba /home/m2gba && chown -R m2gba:m2gba /opt/src
WORKDIR /opt/src
USER m2gba
CMD /home/m2gba/src/docker-scripts/docker-build-rom-script

#---------------------- Building mgba ------------------------
FROM builder AS mgba_builder
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential ccache cmake \
        git libavcodec-dev libavfilter-dev libavformat-dev libavresample-dev \
        libavutil-dev libcmocka-dev libedit-dev libelf-dev libpng-dev \
        libqt5opengl5-dev libsdl2-dev libsqlite3-dev libswscale-dev \
        libzip-dev qtmultimedia5-dev qttools5-dev qttools5-dev-tools && \
    apt-get autoremove -y && apt-get clean
WORKDIR /home/m2gba
USER m2gba
RUN git clone https://github.com/mgba-emu/mgba.git
RUN cd mgba && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. && make

#------------------- Building the Tester ---------------------
FROM builder AS tester
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends xvfb pulseaudio alsa-utils libsdl2-dev \
    libzip-dev libavcodec-dev libavfilter-dev && \
    apt-get autoremove -y && apt-get clean
WORKDIR /opt/src
USER m2gba
COPY --from=mgba_builder /home/m2gba/mgba/build/sdl/mgba ./bin/mgba-sdl
COPY --from=mgba_builder /home/m2gba/mgba/build/libmgba* ./
CMD /home/m2gba/src/docker-scripts/docker-test-rom-script
