FROM mcr.microsoft.com/powershell:ubuntu-20.04
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
