SHELL:=$(shell which bash)
ARCH=x86_64
ROOT_DIR=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
OUT_BASE=$(ROOT_DIR)out/
SRC_BASE=$(ROOT_DIR)src/
DIST_BASE=$(ROOT_DIR)dist/
STAMP_BASE=$(ROOT_DIR)stamp/
INITRAMFS_BASE=$(OUT_BASE)initramfs/
ROOT_BASE=$(OUT_BASE)root/
INITRAMFS_FILE=initramfs.cpio.xz
DOWNLOADCMD=curl -s -O -L -k
MAKEOPT=-j$$(nproc)
DROPBEAR_PROGRAMS=dropbear dbclient dropbearkey dropbearconvert scp
MIKROTIKVER_STABLE=$$(curl -s http://upgrade.mikrotik.com/routeros/NEWESTa7.stable | cut -f1 -d' ')
MIKROTIKVER_TESTING=$$(curl -s http://upgrade.mikrotik.com/routeros/NEWESTa7.testing | cut -f1 -d' ')
MIKROTIKDEVICE="Mips_boot" "MMipsBoot" "Powerboot" "e500_boot" "440__boot" "tile_boot" "ARM__boot" "ARM64__boot"
MIKROTIKARCH="-arm" "-arm64" "-mipsbe" "-mmips" "-smips" "-tile" "-ppc" ""
MIKROTIKURL_ST=https://download.mikrotik.com/routeros/$(MIKROTIKVER_STABLE)/routeros-$(MIKROTIKVER_STABLE)$(device).npk
MIKROTIKURL_TE=https://download.mikrotik.com/routeros/$(MIKROTIKVER_TESTING)/routeros-$(MIKROTIKVER_TESTING)$(device).npk
PATHS="/bin" "/dev" "/etc" "/etc/init.d" "/lib" "/lib64" "/mnt" "/mnt/root" "/proc" "/sbin" "/sys" "/home" "/usr" "/usr/bin" "/usr/sbin" "/usr/lib64" "/var"

MIKROTIK_NETINSTALL_VER=$(MIKROTIKVER_STABLE)
MIKROTIK_NETINSTALL_FILE=netinstall-
MIKROTIK_NETINSTALL_DIR=
MIKROTIK_NETINSTALL_TARBALL=$(MIKROTIK_NETINSTALL_FILE)$(MIKROTIKVER_STABLE).tar.gz
MIKROTIK_NETINSTALL_URL=https://download.mikrotik.com/routeros/$(MIKROTIK_NETINSTALL_VER)/$(MIKROTIK_NETINSTALL_TARBALL)

LINUX_VER=6.11.4
LINUX_FILE=linux-$(LINUX_VER)
LINUX_DIR=$(LINUX_FILE)/
LINUX_TARBALL=$(LINUX_FILE).tar.xz
LINUX_KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)

BUSYBOX_VER=1.36.1
BUSYBOX_FILE=busybox-$(BUSYBOX_VER)
BUSYBOX_DIR=$(BUSYBOX_FILE)/
BUSYBOX_TARBALL=$(BUSYBOX_FILE).tar.bz2
BUSYBOX_URL=https://busybox.net/downloads/$(BUSYBOX_TARBALL)

XORRISO_VER=1.5.6
XORRISO_FILE=xorriso-$(XORRISO_VER)
XORRISO_DIR=$(XORRISO_FILE)
XORRISO_TARBALL=$(XORRISO_FILE).pl02.tar.gz
XORRISO_URL=https://www.gnu.org/software/xorriso/$(XORRISO_TARBALL)

GRUB_VER=2.12
GRUB_FILE=grub-$(GRUB_VER)
GRUB_DIR=$(GRUB_FILE)
GRUB_TARBALL=$(GRUB_FILE).tar.xz
GRUB_URL=https://ftp.gnu.org/gnu/grub/$(GRUB_TARBALL)

SYSLINUX_VER=6.04-pre1
SYSLINUX_FILE=syslinux-$(SYSLINUX_VER)
SYSLINUX_DIR=$(SYSLINUX_FILE)
SYSLINUX_TARBALL=$(SYSLINUX_FILE).tar.xz
SYSLINUX_URL=https://www.kernel.org/pub/linux/utils/boot/syslinux/Testing/6.04/$(SYSLINUX_TARBALL)
SYSLINUX_FILES=bios/mbr/isohdpfx.bin bios/core/isolinux.bin bios/com32/elflink/ldlinux/ldlinux.c32 bios/com32/libutil/libutil.c32 bios/com32/lib/libcom32.c32 bios/com32/mboot/mboot.c32

DROPBEAR_VER=2024.85
DROPBEAR_FILE=DROPBEAR_
DROPBEAR_DIR=dropbear-$(DROPBEAR_FILE)$(DROPBEAR_VER)
DROPBEAR_TARBALL=$(DROPBEAR_FILE)$(DROPBEAR_VER).tar.gz
DROPBEAR_URL=https://github.com/mkj/dropbear/archive/refs/tags/$(DROPBEAR_TARBALL)

GLIBC_VER=2.40
GLIBC_FILE=glibc-$(GLIBC_VER)
GLIBC_DIR=$(GLIBC_FILE)
GLIBC_TARBALL=$(GLIBC_FILE).tar.xz
GLIBC_URL=https://ftp.gnu.org/gnu/glibc/$(GLIBC_TARBALL)

MTOOLS_VER=4.0.44
MTOOLS_FILE=mtools-$(MTOOLS_VER)
MTOOLS_DIR=$(MTOOLS_FILE)
MTOOLS_TARBALL=$(MTOOLS_FILE).tar.gz
MTOOLS_URL=http://ftp.gnu.org/gnu/mtools/$(MTOOLS_TARBALL)

DHTEST_VER=v1.5
DHTEST_FILE=master
DHTEST_TARBALL=$(DHTEST_FILE).tar.gz
DHTEST_DIR=dhtest-master
DHTEST_URL=https://github.com/saravana815/dhtest/archive/$(DHTEST_TARBALL)

STRACE_VER=6.10
STRACE_FILE=strace-$(STRACE_VER)
STRACE_TARBALL=$(STRACE_FILE).tar.xz
STRACE_DIR=$(STRACE_FILE)/
STRACE_URL=https://github.com/strace/strace/releases/download/v$(STRACE_VER)/$(STRACE_TARBALL)

DNSMASQ_VER=2.90
DNSMASQ_FILE=dnsmasq-$(DNSMASQ_VER)
DNSMASQ_TARBALL=$(DNSMASQ_FILE).tar.xz
DNSMASQ_DIR=$(DNSMASQ_FILE)
DNSMASQ_URL=https://thekelleys.org.uk/dnsmasq/$(DNSMASQ_TARBALL)

define file_extra_deps_lst
depends bli part_gpt
endef

define file_issue
 _   _      _   _           _        _ _
| \ | | ___| |_(_)_ __  ___| |_ __ _| | |
|  \| |/ _ \ __| | '_ \/ __| __/ _` | | |
| |\  |  __/ |_| | | | \__ \ || (_| | | |
|_| \_|\___|\__|_|_| |_|___/\__\__,_|_|_|
endef

define file_hostname
netinstall
endef

define file_rcS
#!/bin/sh
ip link set lo up
ip link set eth0 up
ip addr add 10.0.2.15/24 brd + dev eth0
ip route add default via 10.0.2.2
endef

define file_profile
export PS1='[\u@\h \W]\$$ '
clear
cat /etc/issue
echo
uname -a
echo
endef

define file_inittab
::sysinit:/bin/hostname -F /etc/hostname
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
::ctrlaltdel:/sbin/reboot
endef

define file_services
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
endef

define file_protocols
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
Z/sCAAAAAARZWg==
endef

define file_nsswitch_conf
passwd:         files
group:          files
shadow:         files

hosts:          files dns
networks:       files dns

protocols:      files
services:       files
ethers:         files
rpc:            files
endef

define file_hosts
127.0.0.1	localhost
127.0.1.1	netinstall
endef

define file_default_cpio_list
file /bin/busybox       $(SRC_BASE)$(BUSYBOX_DIR)busybox        755 0 0
file /init              $(INITRAMFS_BASE)init                   755 0 0
file /etc/inittab       $(INITRAMFS_BASE)inittab                755 0 0
file /etc/init.d/rcS    $(INITRAMFS_BASE)rcS                    755 0 0
file /etc/passwd        $(INITRAMFS_BASE)passwd                 600 0 0
file /etc/shadow        $(INITRAMFS_BASE)shadow                 600 0 0
file /etc/group         $(INITRAMFS_BASE)group                  755 0 0
file /etc/issue         $(INITRAMFS_BASE)issue                  755 0 0
file /etc/hosts         $(INITRAMFS_BASE)hosts                  755 0 0
file /etc/hostname      $(INITRAMFS_BASE)hostname               755 0 0
file /etc/services      $(INITRAMFS_BASE)services               755 0 0
file /etc/protocols     $(INITRAMFS_BASE)protocols              755 0 0
file /etc/profile       $(INITRAMFS_BASE)profile                755 0 0
file /etc/resolv.conf   $(INITRAMFS_BASE)resolv.conf            755 0 0
file /etc/nsswitch.conf $(INITRAMFS_BASE)nsswitch.conf          755 0 0
file /sbin/strace       $(SRC_BASE)$(STRACE_DIR)src/strace      755 0 0
endef

define file_init
#!/bin/sh
mount -t proc -o noexec,nosuid,nodev proc /proc
mount -t sysfs -o noexec,nosuid,nodev sysfs /sys
mount -t devtmpfs -o exec,nosuid,mode=0755,size=2M devtmpfs /dev
mkdir -p /dev/shm
chmod +t /dev/shm
mount -t tmpfs -o nodev,nosuid,noexec shm /dev/shm
dmesg -n 1
exec /sbin/init "$$@"
endef

define file_passwd
root:x:0:0:root:/root:/bin/sh
guest:x:500:500:guest:/home/guest:/bin/sh
nobody:x:65534:65534:nobody:/proc/self:/dev/null
endef

define file_group
root:x:0:
guest:x:500:
nobody:x:65534:
endef

define file_shadow
root::::::::
guest:*:::::::
nobody:*:::::::
endef

define file_resolv
nameserver 8.8.8.8
nameserver 8.8.4.4
endef

define file_kernelkconfig
CONFIG_64BIT=y
CONFIG_IA32_EMULATION=y
CONFIG_COMPAT_32BIT_TIME=y

CONFIG_MULTIUSER=y
CONFIG_UID16=y

CONFIG_NO_HZ=y
CONFIG_HZ_1000=y
CONFIG_NO_HZ_IDLE=y
CONFIG_NO_HZ_COMMON=y
CONFIG_CPU_ISOLATION=y
CONFIG_POSIX_TIMERS=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y

CONFIG_PCI=y
CONFIG_ACPI=y
CONFIG_ACPI_BUTTON=y
CONFIG_FUTEX=y
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_RSEQ=y
CONFIG_EXPERT=y
CONFIG_PRINTK=y

CONFIG_VT=y
CONFIG_TTY=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_INPUT=y
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_VGA_CONSOLE=y
CONFIG_FB=y
CONFIG_FB_VESA=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FONTS=y
CONFIG_FONT_TER16x32=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_CLUT224=y

CONFIG_BLOCK=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_INITRD=y

CONFIG_CC_OPTIMIZE_FOR_SIZE=y

CONFIG_BINFMT_ELF=y
CONFIG_BINFMT_SCRIPT=y

CONFIG_SYSFS=y
CONFIG_PROC_FS=y
CONFIG_PROC_SYSCTL=y

CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y

CONFIG_RD_XZ=y
CONFIG_KERNEL_XZ=y
# CONFIG_HAVE_KERNEL_GZIP is not set
# CONFIG_HAVE_KERNEL_BZIP2 is not set
# CONFIG_HAVE_KERNEL_LZMA is not set
CONFIG_HAVE_KERNEL_XZ=y
# CONFIG_HAVE_KERNEL_LZO is not set
# CONFIG_HAVE_KERNEL_LZ4 is not set
# CONFIG_HAVE_KERNEL_ZSTD is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y

CONFIG_HW_RANDOM=y

CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_DEV=y

CONFIG_UNIX=y

CONFIG_NET=y
CONFIG_NET_CORE=y
CONFIG_NETDEVICES=y
CONFIG_ETHERNET=y
CONFIG_INET=y
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=y
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_ETHTOOL_NETLINK=y
endef

define file_grub_early_cfg
search --no-floppy --set=root --label "NETINSTALL"
set prefix=($root)/boot/grub
endef

define file_syslinux_cfg
TIMEOUT 10
PROMPT 1
DEFAULT linux

LABEL linux
MENU LABEL Linux
KERNEL /boot/bzimage
INITRD /boot/$(INITRAMFS_FILE)
endef

export file_kernelkconfig file_busyboxkconfig file_init file_issue file_passwd file_group file_resolv file_hostname file_hosts file_extra_deps_lst file_grub_early_cfg file_syslinux_cfg file_default_cpio_list file_rcS file_nsswitch_conf file_profile file_shadow file_services file_protocols file_inittab

all: stamp/makedir stamp/compile stamp/compile-strace stamp/filecopy stamp/init

stamp/filecopy: stamp/init-file stamp/issue-file stamp/passwd-file stamp/group-file stamp/resolv-file stamp/hostname-file stamp/hosts-file stamp/rcS-file stamp/nsswitch-file stamp/profile-file stamp/shadow-file stamp/services-file stamp/protocols-file stamp/inittab-file
	@echo Make files $@

stamp/compile: stamp/compile-kernel-$(LINUX_VER) stamp/compile-busybox
	@echo Make $@

stamp/makedir:
	mkdir -p $(OUT_BASE) $(STAMP_BASE) $(DIST_BASE) $(SRC_BASE) $(INITRAMFS_BASE) $(ROOT_BASE)boot
	@echo Make dirs $@

stamp/fetch-all: stamp/fetch-kernel stamp/fetch-busybox stamp/fetch-xorriso stamp/fetch-grub stamp/fetch-syslinux stamp/fetch-mtools stamp/fetch-dhtest stamp/fetch-glibc
	@echo Fetch $@

stamp/fetch-kernel-$(LINUX_VER):
	cd dist && $(DOWNLOADCMD) $(LINUX_KERNEL_URL)
	cd src && tar -xf ../dist/$(LINUX_TARBALL)
	@echo Fetch $@

stamp/fetch-busybox:
	cd dist && $(DOWNLOADCMD) $(BUSYBOX_URL)
	cd src && tar -xf ../dist/$(BUSYBOX_TARBALL)
	@echo Fetch $@

stamp/fetch-xorriso:
	cd dist && $(DOWNLOADCMD) $(XORRISO_URL)
	cd src && tar -xf ../dist/$(XORRISO_TARBALL)
	@echo Fetch $@

stamp/fetch-grub:
	cd dist && $(DOWNLOADCMD) $(GRUB_URL)
	cd src && tar -xf ../dist/$(GRUB_TARBALL)
	@echo Fetch $@

stamp/fetch-syslinux:
	cd dist && $(DOWNLOADCMD) $(SYSLINUX_URL)
	cd src && tar -xf ../dist/$(SYSLINUX_TARBALL)
	@echo Fetch $@

stamp/fetch-mtools:
	cd dist && $(DOWNLOADCMD) $(MTOOLS_URL)
	cd src && tar -xf ../dist/$(MTOOLS_TARBALL)
	@echo Fetch $@

stamp/fetch-dhtest:
	cd dist && $(DOWNLOADCMD) $(DHTEST_URL)
	cd src && tar -xf ../dist/$(DHTEST_TARBALL)
	@echo Fetch $@

stamp/fetch-strace:
	cd dist && $(DOWNLOADCMD) $(STRACE_URL)
	cd src && tar -xf ../dist/$(STRACE_TARBALL)
	@echo Fetch $@

stamp/fetch-dropbear:
	cd dist && $(DOWNLOADCMD) $(DROPBEAR_URL)
	cd src && tar -xf ../dist/$(DROPBEAR_TARBALL)
	@echo Fetch $@

stamp/fetch-glibc:
	cd dist && $(DOWNLOADCMD) $(GLIBC_URL)
	cd src && tar -xf ../dist/$(GLIBC_TARBALL)
	cd src/$(GLIBC_FILE) && mkdir build
	@echo Fetch $@

stamp/fetch-dnsmasq:
	cd dist && $(DOWNLOADCMD) $(DNSMASQ_URL)
	cd src && tar -xf ../dist/$(DNSMASQ_TARBALL)
	@echo Fetch $@

stamp/compile-kernel-$(LINUX_VER): stamp/fetch-kernel-$(LINUX_VER)
	printf "%s\n" "$$file_kernelkconfig" > src/$(LINUX_DIR)mytinyconfig
	cd src/$(LINUX_DIR) && $(MAKE) distclean
	cd src/$(LINUX_DIR) && $(MAKE) KCONFIG_ALLCONFIG=mytinyconfig allnoconfig
	cd src/$(LINUX_DIR) && $(MAKE) $(MAKEOPT)
	@echo Compile $@

stamp/compile-busybox: stamp/fetch-busybox
	cd src/$(BUSYBOX_DIR) && $(MAKE) distclean
	cd src/$(BUSYBOX_DIR) && $(MAKE) defconfig
	cd src/$(BUSYBOX_DIR) && sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' .config
	cd src/$(BUSYBOX_DIR) && sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
	cd src/$(BUSYBOX_DIR) && $(MAKE) $(MAKEOPT) busybox
	@echo Compile $@

stamp/compile-xorriso: stamp/fetch-xorriso
	cd src/$(XORRISO_DIR) && ./configure
	cd src/$(XORRISO_DIR) && $(MAKE) $(MAKEOPT)
	@echo Compile $@

stamp/compile-glibc: stamp/fetch-glibc
	cd src/$(GLIBC_DIR)/build && ../configure --prefix=$(INITRAMFS_BASE) CFLAGS="-Wno-error -O3"
	cd src/$(GLIBC_DIR)/build && $(MAKE) $(MAKEOPT)
	cd src/$(GLIBC_DIR)/build && $(MAKE) install
	@echo Compile $@

stamp/compile-strace: stamp/fetch-strace
	cd src/$(STRACE_DIR) && LDFLAGS='-static -pthread' ./configure
	cd src/$(STRACE_DIR) && $(MAKE) $(MAKEOPT)
	cd src/$(STRACE_DIR)/src && strip ./strace
	cd src/$(STRACE_DIR)/src && cp ./strace $(INITRAMFS_BASE)sbin
	@echo Compile $@

stamp/compile-grubmbr: stamp/fetch-grub
	cd src/$(GRUB_DIR) && printf "%s\n" "$$file_extra_deps_lst" > grub-core/extra_deps.lst
	cd src/$(GRUB_DIR) && ./configure --target=i386 --with-platform=pc --disable-werror
	cd src/$(GRUB_DIR) && $(MAKE) $(MAKEOPT)
	@echo Compile $@

stamp/compile-grubefi: stamp/fetch-grub
	#cd src/$(GRUB_DIR) && $(MAKE) clean
	cd src/$(GRUB_DIR) && printf "%s\n" "$$file_extra_deps_lst" > grub-core/extra_deps.lst
	cd src/$(GRUB_DIR) && ./configure --target=x86_64 --with-platform=efi --disable-werror --enable-liblzma
	cd src/$(GRUB_DIR) && $(MAKE) $(MAKEOPT)
	@echo Compile $@

stamp/compile-dhtest: stamp/fetch-dhtest
	cd src/$(DHTEST_DIR) && $(MAKE) $(MAKEOPT)
	@echo Compile $@

stamp/compile-dropbear: stamp/fetch-dropbear
	cd src/$(DROPBEAR_DIR) && ./configure --enable-static
	cd src/$(DROPBEAR_DIR) && $(MAKE) PROGRAMS="$(DROPBEAR_PROGRAMS)"
	@$(foreach prog,$(DROPBEAR_PROGRAMS),strip src/$(DROPBEAR_DIR)/$(prog);cp src/$(DROPBEAR_DIR)/$(prog) $(INITRAMFS_BASE)bin;)
	@echo Compile $@

stamp/compile-dnsmasq: stamp/fetch-dnsmasq
	cd src/$(DNSMASQ_DIR) && $(MAKE) $(MAKEOPT)
	cd src/$(DNSMASQ_DIR) && cp src/dnsmasq $(INITRAMFS_BASE)sbin
	@echo Compile $@

stamp/init:
	echo -n > $(INITRAMFS_BASE)default_cpio_list
	echo "dir /root 700 0 0" >> $(INITRAMFS_BASE)default_cpio_list
	$(foreach item,$(PATHS),echo "dir $(item) 755 0 0" >> $(INITRAMFS_BASE)default_cpio_list;)
	printf "%s\n" "$$file_default_cpio_list" >> $(INITRAMFS_BASE)default_cpio_list
	for file in $$($(ROOT_DIR)src/$(BUSYBOX_DIR)busybox --list-full); do echo "slink /$$file /bin/busybox 777 0 0"; done >> $(INITRAMFS_BASE)default_cpio_list
	cd src/$(LINUX_DIR) && ./usr/gen_initramfs.sh -o $(OUT_BASE)initramfs.cpio $(INITRAMFS_BASE)default_cpio_list
	cat $(OUT_BASE)initramfs.cpio | xz -9 -C crc32 > $(ROOT_BASE)$(INITRAMFS_FILE)
	@echo Initramfs was created $@

stamp/fetch-routeros:
	@$(foreach device,$(MIKROTIKARCH),echo $(DOWNLOADCMD) $(MIKROTIKURL_ST);)
	@$(foreach device,$(MIKROTIKARCH),echo $(DOWNLOADCMD) $(MIKROTIKURL_TE);)

stamp/get-netinstall-bootcode: stamp/compile-dhtest
	sudo ./netinstall-cli -a 127.0.0.2 routeros-7.15.3.npk & echo $$! > netinstall.pid
	$(foreach var,$(MIKROTIKDEVICE),sudo src/dhtest-master/dhtest -T 5 -o "$(var)" -i lo;curl -s tftp://127.0.0.1/linux.arm > netinstall_bootcode_$(var);)
	sudo kill -9 $$(cat netinstall.pid)
	rm netinstall.pid

stamp/grub-mkimage:
	cd src/$(GRUB_DIR) && printf "%s\n" "$$file_grub_early_cfg" > grub_early.cfg
	cd src/$(GRUB_DIR) && ./grub-mkimage --config="./grub_early.cfg" --prefix="/boot/grub" --output="bootx64.efi" --format="x86_64-efi" --compression="xz" --directory="./grub-core" all_video disk part_gpt part_msdos linux normal configfile search search_label efi_gop fat iso9660 cat echo ls test true help gzio multiboot2 efi_uga efitextmode

stamp/compile-mtools: stamp/fetch-mtools
	cd src/$(MTOOLS_DIR) && ./configure
	cd src/$(MTOOLS_DIR) && $(MAKE) $(MAKEOPT)
	@echo Compile $@

stamp/cp_syslinux_files: stamp/fetch-syslinux
	@$(foreach file,$(SYSLINUX_FILES),cp src/$(SYSLINUX_DIR)/$(file) $(ROOT_BASE)boot/syslinux/$(notdir $(file));)
	@printf "%s\n" "$$file_syslinux_cfg" > $(ROOT_BASE)boot/syslinux/syslinux.cfg

stamp/mtools: stamp/fetch-mtools
	cd src/$(MTOOLS_DIR) && ./mformat -i $(ROOT_BASE)boot/grub/efi.img -C -f 1440 -N 0 ::
	cd src/$(MTOOLS_DIR) && ./mcopy -i $(ROOT_BASE)boot/grub/efi.img -s $(DESTDIR)/efi ::
	cd src/$(MTOOLS_DIR) && touch -md "@$(SOURCE_DATE_EPOCH)" $(ROOT_BASE)boot/grub/efi.img

stamp/init-file:
	printf "%s\n" "$$file_init" > $(INITRAMFS_BASE)init
	@echo Make file $@

stamp/issue-file:
	printf "%s\n" "$$file_issue" > $(INITRAMFS_BASE)issue
	@echo Make file $@

stamp/hostname-file:
	printf "%s\n" "$$file_hostname" > $(INITRAMFS_BASE)hostname
	@echo Make file $@

stamp/hosts-file:
	printf "%s\n" "$$file_hosts" > $(INITRAMFS_BASE)hosts
	@echo Make file $@

stamp/nsswitch-file:
	printf "%s\n" "$$file_nsswitch_conf" > $(INITRAMFS_BASE)nsswitch.conf
	@echo Make file $@

stamp/passwd-file:
	printf "%s\n" "$$file_passwd" > $(INITRAMFS_BASE)passwd
	@echo Make file $@

stamp/shadow-file:
	printf "%s\n" "$$file_shadow" > $(INITRAMFS_BASE)shadow
	@echo Make file $@

stamp/inittab-file:
	printf "%s\n" "$$file_inittab" > $(INITRAMFS_BASE)inittab
	@echo Make file $@

stamp/group-file:
	printf "%s\n" "$$file_group" > $(INITRAMFS_BASE)group
	@echo Make file $@

stamp/resolv-file:
	printf "%s\n" "$$file_resolv" > $(INITRAMFS_BASE)resolv.conf
	@echo Make file $@

stamp/services-file:
	printf "%s" "$$file_services" | base64 -d | xz -d > $(INITRAMFS_BASE)services
	@echo Make file $@

stamp/protocols-file:
	printf "%s" "$$file_protocols" | base64 -d | xz -d > $(INITRAMFS_BASE)protocols
	@echo Make file $@

stamp/profile-file:
	printf "%s\n" "$$file_profile" > $(INITRAMFS_BASE)profile
	@echo Make file $@

stamp/rcS-file:
	printf "%s\n" "$$file_rcS" > $(INITRAMFS_BASE)rcS
	@echo Make file $@

stamp/ver:
	@echo $(MIKROTIKVER_STABLE)
	@echo $(MIKROTIKVER_TESTING)

clean:
	@echo "Cleaning build ..."
	$(RM) -r $(SRC_BASE) $(DIST_BASE) $(STAMP_BASE) $(OUT_BASE)
run:
	qemu-system-x86_64 -m 2G -kernel $(SRC_BASE)$(LINUX_DIR)arch/x86_64/boot/bzImage -initrd $(ROOT_BASE)$(INITRAMFS_FILE) -append "console=ttyS0" -enable-kvm -cpu host -nic user,model=e1000e -nographic

.PHONY: printvars
printvars:
	@$(foreach V,$(sort $(.VARIABLES)),$(if $(filter-out environment% default automatic,$(origin $V)),$(warning $V=$($V) ($(value $V)))))
dir:
	echo $(CURDIR)
