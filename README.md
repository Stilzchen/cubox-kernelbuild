# cubox-kernelbuild

This script tries to install the newest longterm kernel to a marvel dove cubox.
I use the script on a regular basis for my two little cuboxes.

The script checks the version of the newest available longterm kernel and present the results.
You have now the option to build the newest longterm or any other downloadable kernel. The scripts downloads the source, build zImage, dtb files and modules and copy the modules to the /lib directory. After that a working uImage will be build and copied to the /boot directory.
The debian wiki describes the required commands to setup a working kernel -> https://wiki.debian.org/InstallingDebianOn/SolidRun/CuBox
The used kernel config file is copied from the running kernel via 'zcat /proc/config.gz'.

As an alternative the running kernel sources can be used to update and rebuild things.

My original kernel config file was grapped from xilka kernel 4.10.17 (http://xilka.com/kernel/4/4.10/4.10.17/release/1/), because this one is well prepared and come with many useful modules enabled.

The uImage build process should work for older kernels including 6.1 and newer kernels including 6.6, where several file pathes (dtb, etc.) was modified.
