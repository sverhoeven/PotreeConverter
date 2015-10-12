# Docker image with potreeconverter binary (https://github.com/potree/PotreeConverter)
#
# Image creation:
#
#    docker build -t potreeconverter .
#
# To convert input.laz (in current working directory) into a potree resource in input.laz_converted/ sub-directory use:
#
#    docker run -u $UID -v $PWD:/data potreeconverter PotreeConverter -l 5 --output-format LAZ /data/input.laz
#
FROM ubuntu:15.04
MAINTAINER Stefan Verhoeven <s.verhoeven@esciencecenter.nl
VOLUME ["/data"]
#RUN echo 'deb http://ppa.launchpad.net/ubuntugis/ubuntugis-unstable/ubuntu trusty main' > /etc/apt/sources.list.d/ubuntugis-unstable.list \
# && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160
RUN apt-get update && apt-get install -y \
libtiff-dev libgeotiff-dev libgdal1-dev \
libboost-system-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev libboost-iostreams-dev \
git cmake build-essential wget
WORKDIR /opt

RUN git clone https://github.com/m-schuetz/LAStools.git && cd LAStools/LASzip && mkdir build && cd build && \
cmake -DCMAKE_BUILD_TYPE=Release .. && make

# build potree converter
RUN mkdir -p /opt/PotreeConverter
WORKDIR /opt/PotreeConverter
COPY . /opt/PotreeConverter
RUN mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DLASZIP_INCLUDE_DIRS=/opt/LAStools/LASzip/dll/ \
-DLASZIP_LIBRARY=/opt/LAStools/LASzip/build/src/liblaszip.so .. && \
make && make install

CMD PotreeConverter
