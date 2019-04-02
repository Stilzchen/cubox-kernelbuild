#!/bin/bash

#some variables that will be used later
longtermkernel=$(curl -s https://www.kernel.org|grep -A2 longterm|head -n 2|tail -n1 |cut -d '<' -f3|cut -d '>' -f2)
longtermmajor=$(echo $longtermkernel|cut -d '.' -f1)
runningkernel=$(uname -r)


echo -e "##################################################
#                                                #
#  kernel install script for cubox dove          #
#                                                #
#  please be shure to mount /boot                #
#  before starting this script                   #
#                                                #
#  current longterm kernel version: \t$longtermkernel  #
#  running kernel version: \t\t$runningkernel  #
#                                                #
##################################################
"

function helpFunction {
echo -e "\n\nThis script tries to install the newest longterm kernel.\n
Its not part of this script to let you choose the longterm kernel branch.\n
The script checks the version of the newest available longterm kernel, download the source, build zImage, dtb files and modules and copy the modules to the /lib directory.\n
The used kernel config file is copied from the running kernel.\nThe original kernel config file was grapped from xilka kernel 4.10.17 (http://xilka.com/kernel/4/4.10/4.10.17/release/1/), because this one is well prepared and come with many useful modules enabled."
}

function doitFunction {
#get the kernel
echo "Get the new source and unpack it"
echo -e "curl -o /usr/src/linux-$longtermkernel.tar.xz https://cdn.kernel.org/pub/linux/kernel/v$longtermmajor.x/linux-$longtermkernel.tar.xz"
curl -o /usr/src/linux-$longtermkernel.tar.xz https://cdn.kernel.org/pub/linux/kernel/v$longtermmajor.x/linux-$longtermkernel.tar.xz

#unpack the kernel
pushd /usr/src/
tar xfv linux-$longtermkernel.tar.xz
rm *.tar.xz
popd

#copy running config to the new kernel source
zcat /proc/config.gz >> /usr/src/linux-$longtermkernel/.config

#go to the source main directory
pushd /usr/src/linux-$longtermkernel
echo "Merge config by using oldconfig"
yes "" | make oldconfig

echo "Build everything"
make -j3 zImage; make -j3 dtbs; make -j3 modules; make modules_install INSTALL_MOD_PATH=

echo "copy zImage and dtb file to one file"
cat arch/arm/boot/zImage arch/arm/boot/dts/dove-cubox.dtb > zImage.cubox
popd

echo "copy file to /boot directory"
mkimage -A arm -O linux -C none  -T kernel -a 0x00008000 -e 0x00008000 -n 'Linux-cubox' -d /usr/src/linux-$longtermkernel/zImage.cubox /boot/dove-cubox-$longtermkernel-uImage
echo -e "\nYEAH, it's done!\n\nPlease be shure to update your boot.src file or change kernel symlinks to your new kernel."
}


if [ $longtermkernel != $runningkernel ]; then
 read -p "Do you want to build the new longterm kernel (y/n)? Press h for help." choice
 case "$choice" in
   y|Y ) echo "yes" && doitFunction;;
   h|H ) echo "help" && helpFunction;;
   n|N ) echo "Ok, good bye";;
   * ) echo "invalid input, abort";;
 esac;
 else echo "running kernel and longterm kernel are the same, nothing to do"
fi
