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
ENV PATH="${PATH}:/root/.dotnet/tools"
RUN echo "-------------------Installing armips------------------"
WORKDIR /opt/dep
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
RUN echo "-------------------Building patched rom------------------"
COPY ./ /opt/src
WORKDIR /opt/src
CMD ./docker-build-rom-script
