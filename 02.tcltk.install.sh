#!/usr/bin/env bash

# Install necesary packages
sudo apt-get install -y build-essential lbzip2 dejagnu

### TCL

wget https://prdownloads.sourceforge.net/tcl/tcl8.6.12-src.tar.gz

tar xf tcl8.6.12-src.tar.gz
cd tcl8.6.12/unix
./configure --prefix=/share/utils/tcltk/8.6.12 --enable-shared &&\
make && \
sudo make install
cd ../..

### TK

sudo apt install -y libx11-dev

wget https://prdownloads.sourceforge.net/tcl/tk8.6.12-src.tar.gz

tar xf tk8.6.12-src.tar.gz
cd tk8.6.12/unix
./configure --prefix=/share/utils/tcltk/8.6.12 --with-tcl=/share/utils/tcltk/8.6.12/lib --enable-shared && \
make && \
sudo make install
