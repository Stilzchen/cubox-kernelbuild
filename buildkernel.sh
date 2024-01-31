#!/bin/bash

longtermkernel=$(curl -s https://www.kernel.org|grep -A2 longterm|head -n 2|tail -n1 |cut -d '<' -f3|cut -d '>' -f2)
longtermmajor=$(echo $longtermkernel|cut -d '.' -f1)
runningkernel=$(uname -r)


echo -e "#########################################################
#							#
#  kernel build and install script for cubox dove	#
#							#
#  please be shure to mount /boot			#
#  before starting this script				#
#							#
#  current longterm kernel version:\t$longtermkernel		#
#  running kernel version:\t\t$runningkernel		#
#							#
#########################################################
"

function helpFunction {
echo -e "\n\nThis script tries to install the newest longterm kernel.\n
Its not part of this script to let you choose the longterm kernel branch.\n\n
The script checks the version of the newest available longterm kernel, downloads the source, let you modify the cnfig file if needed, build zImage, dtb files and modules and copy kernel to /boot and modules to the /lib directory.\n
The used kernel config file is copied from the running kernel.\nThe original kernel config file was grapped from xilka kernel 4.10.17 (http://xilka.com/kernel/4/4.10/4.10.17/release/1/), because this one is well prepared and come with many useful modules enabled.\n\n
As an alternative you can rebuild your running kernel and edit your config first.\n"
}

function startnewkernelFunction {
#read -p "Press enter to continue"
#get the kernel
echo "Get the new source and unpack it"
echo $longtermkernel
echo -e "curl -o /usr/src/linux-$longtermkernel.tar.xz https://cdn.kernel.org/pub/linux/kernel/v$longtermmajor.x/linux-$longtermkernel.tar.xz"
curl -o /usr/src/linux-$longtermkernel.tar.xz https://cdn.kernel.org/pub/linux/kernel/v$longtermmajor.x/linux-$longtermkernel.tar.xz

#unpack the kernel
pushd /usr/src/
tar xfv linux-$longtermkernel.tar.xz
rm *.tar.xz
popd

#copy running config to the new kernel source
zcat /proc/config.gz >> /usr/src/linux-$longtermkernel/.config
}

function noconfigFunction {
#go to the source main directory
pushd /usr/src/linux-$kernel
echo "Merge config by using oldconfig ..."
yes "" | make oldconfig
}

function menuconfigFunction {
#go to the source main directory
pushd /usr/src/linux-$kernel
echo "starting  menuconfig ..."
make menuconfig
}

function xconfigFunction {
#go to the source main directory
pushd /usr/src/linux-$kernel
echo "starting xconfig ..."
make xconfig
}

function nconfigFunction {
#go to the source main directory
pushd /usr/src/linux-$kernel
echo "starting nconfig ..."
make nconfig
}

function buildFunction {
pushd /usr/src/linux-$kernel
echo "Build everything"
make -j3 zImage; make -j3 dtbs; make -j3 modules; make modules_install INSTALL_MOD_PATH=

echo "copy zImage and dtb file to one file"
cat arch/arm/boot/zImage arch/arm/boot/dts/dove-cubox.dtb > zImage.cubox
popd

echo "copy file to /boot directory"
mkimage -A arm -O linux -C none  -T kernel -a 0x00008000 -e 0x00008000 -n 'Linux-cubox' -d /usr/src/linux-$kernel/zImage.cubox /boot/dove-cubox-$kernel-uImage
echo -e "\nYEAH, it's done!\n\nPlease be shure to update your boot.src file or change kernel symlinks to your new kernel."
}

function caseFunction ()
{
if [ $longtermkernel != $runningkernel ]; then
 echo -e "Do you want to build the new longterm kernel?\n"
 read -p "Please type y (yes), n (no), r (rebuild) or h (help). " choice
 case "$choice" in 
   y|Y ) echo "yes" && kernel=$(echo $longtermkernel) && startnewkernelFunction && prepareFunction;;
   r|R ) echo "rebuild" && kernel=$(echo $runningkernel) && prepareFunction;;
   h|H ) echo "help" && helpFunction && caseFunction;;
   n|N ) echo "Ok, good bye";;
   * ) echo -e "\ninvalid input, please type y (yes), n (no), r (rebuild) or h (help)\n" && caseFunction;;
 esac;
 else
#  echo "running kernel and longterm kernel are the same, nothing to do"
 read -p "Running kernel and longterm kernel are the same. Do you want to rebuild the running kernel (y/n)? Press h for help. " choice
 case "$choice" in 
   y|Y ) echo "yes" && kernel=$(echo $runningkernel) && prepareFunction;;
   h|H ) echo "help" && helpFunction && caseFunction;;
   n|N ) echo "Ok, good bye";;
   * ) echo -e "\ninvalid input, please type y (yes), n (no) or h (help)\n" && caseFunction;;
 esac;
fi
}

function prepareFunction () {
 echo -e "\nDo you want to modify your kernel config file?\n"
 read -p "Please type m (menuconfig), n (nconfig), x (xconfig) or o (oldconfig with default yes (no user interaction))" choice
 case "$choice" in 
   m|M ) echo "yes with menuconfig" && menuconfigFunction && buildFunction;;
   n|N ) echo "yes with nconfig" && nconfigFunction && buildFunction;;
   x|X ) echo "yes with xconfig" && xconfigFunction && buildFunction;;
   o|O ) echo "no, just build it" && noconfigFunction &&buildFunction;;
   * ) echo -e "\ninvalid input" && prepareFunction;;
 esac;
}
caseFunction
