#!/bin/bash
#
# Compile script for hanikrnl.
# Copyright (C)2022 Ardany Jolón
SECONDS=0 # builtin bash timer
KERNEL_PATH=$PWD
AK3_DIR="$HOME/tc/AnyKernel3"
DEFCONFIG="vendor/chime_defconfig"
export KBUILD_BUILD_USER=hani
export KBUILD_BUILD_HOST=dungeon

# Install needed tools
if [[ $1 = "-n" || $1 = "--neutron" ]]; then
        mkdir toolchain
	cd toolchain

	curl -LO "https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman" || exit 1

	chmod -x antman

	echo 'Setting up toolchain in $(PWD)/toolchain'
	bash antman -S || exit 1

	echo 'Build libarchive for bsdtar'
	git clone https://github.com/libarchive/libarchive || true
	cd libarchive
	bash build/autogen.sh
	./configure
	make -j$(nproc)
	cd ..

	echo 'Patch for glibc'
	wget https://gist.githubusercontent.com/itsHanibee/fac63ea2fc0eca7b8d7dcbb7eb678c3b/raw/beacf8f0f71f4e8231eaa36c3e03d2bee9ae3758/patch-for-old-glibc.sh
	export PATH=$(pwd)/libarchive:$PATH
	bash patch-for-old-glibc.sh
fi

# Regenerate defconfig file
if [[ $1 = "-r" || $1 = "--regen" ]]; then
	make O=out ARCH=arm64 $DEFCONFIG savedefconfig
	cp out/defconfig arch/arm64/configs/$DEFCONFIG
	echo -e "\nSuccessfully regenerated defconfig at $DEFCONFIG"
fi

# Start building the kernel
if [[ $1 = "-b" || $1 = "--build" ]]; then
	export ARCH=arm64
	PATH=$PWD/toolchain/bin:$PATH
	export USE_HOST_LEX=yes
	mkdir -p out
	make O=out CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 $DEFCONFIG
	echo -e ""
	echo -e ""
	echo -e "*****************************"
	echo -e "**                         **"
	echo -e "** Starting compilation... **"
	echo -e "**                         **"
	echo -e "*****************************"
	echo -e ""
	echo -e ""
	make O=out CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip -j$(nproc) || exit 1

	kernel="out/arch/arm64/boot/Image"
	dtbo="out/arch/arm64/boot/dtbo.img"
	dtb="out/arch/arm64/boot/dtb.img"

	if [ -f "$kernel" ]; then
		# Set kernel name and version
		hash=$(git log -n 1 --pretty=format:'%h')
		lastcommit=$hash
		REVISION=4.19-hanikrnl.$lastcommit
		ZIPNAMEFull=""$REVISION"-beehive-chime-FULL.zip"
		ZIPNAMENoDTBO=""$REVISION"-beehive-chime-NoDTBO.zip"
		echo -e ""
		echo -e ""
		echo -e "********************************************"
		echo -e "\nKernel compiled succesfully! Zipping up...\n"
		echo -e "********************************************"
		echo -e ""
		echo -e ""
	if [ -d "$AK3_DIR" ]; then
		cp -r $AK3_DIR AnyKernel3
	elif ! git clone -q https://github.com/itsHanibee/AnyKernel3 -b master; then
			echo -e "\nAnyKernel3 repo not found locally and couldn't clone from GitHub! Aborting..."
	fi

		# Pack images into .zip
		cp $kernel AnyKernel3
		cp $dtbo AnyKernel3
		cp $dtb AnyKernel3

		rm -rf out/arch/arm64/boot
		cd AnyKernel3
		git checkout master &> /dev/null

		## Full .zip (Kernel, DTBO, DTB)
		if [[ $1 = "-f" || $1 = "--full" ]]; then
		zip -r9 "../$ZIPNAMEFull" * -x .git README.md *placeholder
		fi

		## Partial .zip (Kernel image only)
		if [[ $1 = "-p" || $1 = "--partial" ]]; then
		zip -r9 "../$ZIPNAMENoDTBO" * -x .git README.md *placeholder dtbo.img dtb.img
		fi

		cd ..

        echo -e ""
        echo -e ""
        echo -e "************************************************************"
        echo -e "**                                                        **"
        echo -e "**   Build completed in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s)!    **"
        echo -e "**                                                        **"
        echo -e "************************************************************"
        echo -e ""
        echo -e ""
	else
        echo -e "*****************************"
        echo -e "**                         **"
        echo -e "**   Compilation failed!   **"
        echo -e "**                         **"
        echo -e "*****************************"
	fi
	fi
