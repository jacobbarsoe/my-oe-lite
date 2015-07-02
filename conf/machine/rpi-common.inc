MACHINE_CPU	= "arm-1176jzfs"
MACHINE_ABI	= "hard"
FW_SRCREV = "commit=3ab17ac25e92ade48325472994b6660c5efd05b5"
FW_DATE   = "20130821"

MACHINE_USE_kernel_defconfig = "bcmrpi_defconfig"
MACHINE_USE_kernel_imagetype = "zImage"

MACHINE_USE_fwupdate_sda="SDA=mmcblk0p"
MACHINE_USE_fwupdate_bootcmd2="BOOTCMD2=\"sed -i s/mmcblk0p2/mmcblk0p3/ /tmp/g/cmdline.txt\""
MACHINE_USE_fwupdate_bootcmd3="BOOTCMD3=\"sed -i s/mmcblk0p3/mmcblk0p2/ /tmp/g/cmdline.txt\""