#!/bin/bash
#=============================================================================
# This script provides directions for installing Anaconda Python,
# ffmpeg and openSMILE on Ubuntu 14.04.
#
# Usage:
#     bash machine-setup.sh <install_dir>
#       <install_dir>: path to installation directory (optional)
#
# Authors:
#     - Arno Klein, 2015-2016  (arno@sagebase.org)  http://binarybottle.com
#
# Copyright 2016,  Sage Bionetworks (http://sagebase.org), Apache v2.0 License
#=============================================================================

#-----------------------------------------------------------------------------
# Assign download and installation path.
# Create installation folder if it doesn't exist:
#-----------------------------------------------------------------------------
INSTALLS=$HOME/install
if [ ! -d $INSTALLS ]; then
    mkdir -p $INSTALLS;
fi
export INSTALLS
export PATH=$INSTALLS/bin:$PATH

#-----------------------------------------------------------------------------
# System-wide dependencies:
#-----------------------------------------------------------------------------
sudo apt-get update
sudo apt-get install -y git
sudo apt-get install -y build-essential

#-----------------------------------------------------------------------------
# Anaconda's miniconda Python distribution for local installs:
#-----------------------------------------------------------------------------
CONDA_URL="http://repo.continuum.io/miniconda"
CONDA_FILE="Miniconda-latest-Linux-x86_64.sh"
CONDA_DL=$INSTALLS/${CONDA_FILE}
CONDA_PATH=$INSTALLS/miniconda2
CONDA=${CONDA_PATH}/bin
wget --no-clobber -O $CONDA_DL ${CONDA_URL}/$CONDA_FILE
chmod +x $CONDA_DL
# -b           run install in batch mode (without manual intervention),
#              it is expected the license terms are agreed upon
# -f           no error if install prefix already exists
# -p PREFIX    install prefix
bash $CONDA_DL -b -f -p $CONDA_PATH
export PATH=$CONDA:$PATH

#-----------------------------------------------------------------------------
# Additional resources for installing packages:
#-----------------------------------------------------------------------------
$CONDA/conda install --yes cmake pip

#-----------------------------------------------------------------------------
# Install some Python libraries:
#-----------------------------------------------------------------------------
$CONDA/conda install --yes numpy scipy pandas

# Install Synapse client:
$CONDA/pip install synapseclient

#-----------------------------------------------------------------------------
# Install ffmpeg and dependencies for audio file conversion:
#-----------------------------------------------------------------------------
# (from https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu)
mkdir $INSTALLS/ffmpeg
mkdir $INSTALLS/ffmpeg/ffmpeg_sources
mkdir $INSTALLS/ffmpeg/ffmpeg_build
sudo apt-get -y --force-yes install autoconf automake build-essential libass-dev libfreetype6-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texi2html zlib1g-dev

# Install yasm (ffmpeg dependency):
cd $INSTALLS/ffmpeg/ffmpeg_sources
wget -nc http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd $INSTALLS/ffmpeg/ffmpeg_sources/yasm-1.3.0
./configure --prefix="$INSTALLS/ffmpeg/ffmpeg_build" --bindir="$INSTALLS/bin"
make
make install
make distclean

# Install ffmpeg:
cd $INSTALLS/ffmpeg/ffmpeg_sources
wget -nc http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PKG_CONFIG_PATH=$INSTALLS/ffmpeg/ffmpeg_build/lib/pkgconfig
./configure --prefix=$INSTALLS/ffmpeg/ffmpeg_build --pkg-config-flags="--static" --extra-cflags="-I$INSTALLS/ffmpeg/ffmpeg_build/include" --extra-ldflags="-L$INSTALLS/ffmpeg/ffmpeg_build/lib" --bindir="$INSTALLS/bin" --enable-gpl
#--enable-libass --enable-libfreetype --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libx265 --enable-nonfree --enable-libfdk-aac --enable-libmp3lame --enable-libopus --enable-libvpx
make
make install
export PATH=$INSTALLS/ffmpeg/ffmpeg_sources/ffmpeg:$PATH

#-----------------------------------------------------------------------------
# Install openSMILE:
#-----------------------------------------------------------------------------
cd $INSTALLS
# wget -nc http://www.audeering.com/research-and-open-source/files/openSMILE-2.2rc1.tar.gz
synapse get syn5584794
tar xvf openSMILE-2.1.0.tar.gz
cd openSMILE-2.1.0
bash buildStandalone.sh -p $INSTALLS

wget -nc http://www.audeering.com/research-and-open-source/files/openSMILE-2.2rc1.tar.gz
tar xvf openSMILE-2.2rc1.tar.gz
cd openSMILE-2.2rc1
bash buildStandalone.sh -p $INSTALLS
