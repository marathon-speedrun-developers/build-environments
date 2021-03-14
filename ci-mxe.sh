#!/bin/bash

set -o errexit

# Buildah script to create Ubuntu 18.04 Build Environment
# with MXE for use with Aleph One.
#
# (C) 2021 Marathon Speedrun Developers
#
# Redistribution and use in source and binary forms, with or 
# without modification, are permitted provided that the 
# following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright 
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above 
# copyright notice, this list of conditions and the following 
# disclaimer in the documentation and/or other materials provided 
# with the distribution.
#
# 3. Neither the name of the copyright holder nor the names 
# of its contributors may be used to endorse or promote products 
# derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

ctr=$(buildah from ubuntu:20.04)
mount_ctr=$(buildah mount $ctr)

# Metadata

buildah config --author="Marathon Speedrun Developers <marathonspeedruns@gmail.com>" $ctr

# Install Build Dependencies

buildah run $ctr apt-get -y update

buildah run $ctr apt-get -y upgrade

buildah run $ctr apt-get -y install build-essential

buildah run $ctr apt-get -y install autoconf automake autopoint bash bison \
	bzip2 flex g++ g++-multilib gettext git \
	gperf intltool libc6-dev-i386 libgdk-pixbuf2.0-dev \
	libltdl-dev libssl-dev libtool-bin libxml-parser-perl \
	lzip make openssl p7zip-full patch perl \
	python ruby sed unzip wget xz-utils

# Grabbing MXE

buildah config --workingdir /opt $ctr
buildah run $ctr git clone --depth 1 https://github.com/Aleph-One-Marathon/mxe.git
buildah config --workingdir /opt/mxe $ctr
buildah run $ctr make -j`nproc` boost curl expat ffmpeg freetype glew jpeg libpng \
	sdl2 sdl2_image sdl2_mixer sdl2_net sdl2_ttf speex speexdsp zziplib

# Creating Clean Container

ctr2=$(buildah from ubuntu:20.04)
mount_ctr2=$(buildah mount $ctr2)

buildah run $ctr2 apt -y update
buildah run $ctr2 apt -y upgrade

mv $mount_ctr/opt/mxe $mount_ctr2/opt/mxe

# Commit Changes

buildah commit --format docker $ctr2 marathondevs/alephone-mxe
