#!/bin/bash
#
# Compile script for hanikrnl.
#
SECONDS=0 # builtin bash timer
KERNEL_PATH=$PWD
AK3_DIR="$HOME/tc/AnyKernel3"
DEFCONFIG="vendor/chime_defconfig"
export KBUILD_BUILD_USER=hani
export KBUILD_BUILD_HOST=dungeon

# Install needed tools
if [[ $1 = "-t" || $1 = "--tools" ]]; then
        mkdir toolchain
	cd toolchain

	curl -LO "https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman" || exit 1

	chmod -x antman

	echo 'Setting up toolchain in $(PWD)/toolchain'
	bash antman -S || exit 1

	echo 'Patch for glibc'
	bash antman --patch=glibc
fi

# Regenerate defconfig file
if [[ $1 = "-r" || $1 = "--regen" ]]; then
	make O=out ARCH=arm64 $DEFCONFIG savedefconfig
	cp out/defconfig arch/arm64/configs/$DEFCONFIG
	echo -e "\nSuccessfully regenerated defconfig at $DEFCONFIG"
fi

if [[ $1 = "-b" || $1 = "--build" ]]; then
	PATH=$PWD/toolchain/bin:$PATH
	mkdir -p out
	make O=out ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 $DEFCONFIG
	echo -e ""
	echo -e ""
	echo -e "*****************************"
	echo -e "**                         **"
	echo -e "** Starting compilation... **"
	echo -e "**                         **"
	echo -e "*****************************"
	echo -e ""
	echo -e ""
	make O=out ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 -j$(nproc) || exit 1

	kernel="out/arch/arm64/boot/Image"
	dtbo="out/arch/arm64/boot/dtbo.img"
	dtb="out/arch/arm64/boot/dtb.img"

	if [ -f "$kernel" ]; then
		rm *.zip 2>/dev/null
		# Set kernel name and version
		hash=$(git log -n 1 --pretty=format:'%h' | cut -c 1-7)
		lastcommit=$hash
		REVISION=4.19-hanikrnl.wip.$lastcommit
		ZIPNAME=""$REVISION"-chime-$(date '+%d.%m.%y-%H%M').zip"
		echo -e ""
		echo -e ""
		echo -e "********************************************"
		echo -e "\nKernel compiled succesfully! Zipping up...\n"
		echo -e "********************************************"
		echo -e ""
		echo -e ""
	if [ -d "$AK3_DIR" ]; then
		cp -r $AK3_DIR AnyKernel3
	elif ! git clone -q https://github.com/Dominium-Apum/AnyKernel3 -b personal; then
			echo -e "\nAnyKernel3 repo not found locally and couldn't clone from GitHub! Aborting..."
	fi
		cp $kernel AnyKernel3
		cp $dtbo AnyKernel3
		cp $dtb AnyKernel3

		cd AnyKernel3
		zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
		cd ..

        echo -e ""
        echo -e ""
        echo -e "************************************************************"
        echo -e "**                                                        **"
        echo -e "**   File name: $ZIPNAME   **"
        echo -e "**   Build completed in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s)!    **"
        echo -e "**                                                        **"
        echo -e "************************************************************"
        echo -e ""
        echo -e ""
	else
        echo -e ""
        echo -e ""
        echo -e "*****************************"
        echo -e "**                         **"
        echo -e "**   Compilation failed!   **"
        echo -e "**                         **"
        echo -e "*****************************"
	fi
	fi
