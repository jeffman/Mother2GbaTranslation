FROM lorenzooone/m2gba_translation:builder
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential ccache cmake \
        git libavcodec-dev libavfilter-dev libavformat-dev libavresample-dev \
        libavutil-dev libcmocka-dev libedit-dev libelf-dev libpng-dev \
        libqt5opengl5-dev libsdl2-dev libsqlite3-dev libswscale-dev \
        libzip-dev qtmultimedia5-dev qttools5-dev qttools5-dev-tools xvfb pulseaudio alsa-utils && \
    apt-get autoremove -y && apt-get clean
WORKDIR /home/m2gba
USER m2gba
RUN git clone https://github.com/mgba-emu/mgba.git
RUN cd mgba && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. && make && cp sdl/mgba /opt/src/bin/mgba-sdl
WORKDIR /opt/src
CMD /home/m2gba/src/docker-scripts/docker-test-rom-script
