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
FROM ubuntu:12.04
MAINTAINER Stefan Verhoeven <s.verhoeven@esciencecenter.nl
VOLUME ["/data"]
RUN echo 'deb http://ppa.launchpad.net/ubuntugis/ubuntugis-unstable/ubuntu precise main' > /etc/apt/sources.list.d/ubuntugis-unstable.list \
&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160
RUN apt-get update && apt-get install -y \
libtiff-dev libgeotiff-dev libgdal1-dev \
libboost-system-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev libboost-iostreams-dev \
git cmake build-essential wget
WORKDIR /opt

# can't use apt liblas-dev liblas-c-dev, because they are missing laz support
# build libzip
RUN wget -nc https://github.com/LASzip/LASzip/releases/download/v2.2.0/laszip-src-2.2.0.tar.gz && tar -zxf laszip-src-2.2.0.tar.gz
WORKDIR /opt/laszip-src-2.2.0
RUN ./configure --includedir=/usr/local/include/laszip && make && make install

# build liblas
WORKDIR /opt
RUN wget -nc http://download.osgeo.org/liblas/libLAS-1.8.0.tar.bz2 && tar -jxf libLAS-1.8.0.tar.bz2
WORKDIR /opt/libLAS-1.8.0
RUN mkdir build && cd build && cmake -DWITH_GDAL=YES -DWITH_LASZIP=YES -DWITH_GEOTIFF=YES .. && make && make install && ldconfig

# build potree converter
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN mkdir build && cd build && cmake .. && make && make install

CMD PotreeConverter
