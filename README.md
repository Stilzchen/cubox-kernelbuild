# cubox-kernelbuild

This script tries to install the newest longterm kernel to a marvel dove cubox.

Its not part of this script to let you choose the longterm kernel branch.

The script checks the version of the newest available longterm kernel, downloads the source, build zImage, dtb files and modules and copy the modules to the /lib directory. After that a working uImage will be build and copied to the /boot directory.
The debian wiki describes the required commands to setup a working kernel -> https://wiki.debian.org/InstallingDebianOn/SolidRun/CuBox
The used kernel config file is copied from the running kernel via 'zcat /proc/config.gz'.

As an alternative the running kernel sources can be used, updated an rebuild.

My original kernel config file was grapped from xilka kernel 4.10.17 (http://xilka.com/kernel/4/4.10/4.10.17/release/1/), because this one is well prepared and come with many useful modules enabled.
