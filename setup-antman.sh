#!/bin/bash
set -e
if [ ! -e toolchain ]; then
echo 'mkdir toolchain'
mkdir toolchain
elif [ ! -d toolchain ]; then
echo '$(pwd)/toolchain is not a directory'
exit 1
fi
echo 'Setting up toolchain in $(pwd)/toolchain'
cd toolchain
echo 'Download antman and sync'
bash <(curl -s "https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman") -S
echo 'Clone libarchive for bsdtar'
git clone https://github.com/libarchive/libarchive || true
#sudo apt install -y pkg-config m4 libtool automake autoconf
cd libarchive
echo 'Build libarchive'
bash build/autogen.sh
./configure
make -j$(nproc)
cd ..
echo 'Patch for glibc'
wget https://gist.githubusercontent.com/itsHanibee/fac63ea2fc0eca7b8d7dcbb7eb678c3b/raw/beacf8f0f71f4e8231eaa36c3e03d2bee9ae3758/patch-for-old-glibc.sh
export PATH=$(pwd)/libarchive:$PATH
bash patch-for-old-glibc.sh
echo 'Done'
