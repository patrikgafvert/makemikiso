#.SILENT:
SHELL:=$(shell which bash)
ARCH=x86_64
ISO_FILE=file.iso
REQUIRED_PROGRAMS=gcc make python3 curl jq bison gawk gperf xz
MISSING_FILES=$(foreach prog,$(REQUIRED_PROGRAMS),$(shell command -v $(prog) > /dev/null 2>&1 || echo -n >&2 "$(prog) "))
ROOT_DIR=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
OUT_BASE=$(ROOT_DIR)out/
SRC_BASE=$(ROOT_DIR)src/
DIST_BASE=$(ROOT_DIR)dist/
STAMP_BASE=$(ROOT_DIR)stamp/
INITRAMFS_BASE=$(OUT_BASE)initramfs/
ROOT_BASE=$(OUT_BASE)root/
KERNEL_ARGSV=console=tty0 console=ttyS0

HOSTNAME=netinstall
IPADDR=10.0.2.15
DEFGATEW=10.0.2.2
PRIDNS=8.8.8.8
SECDNS=8.8.4.4

KERNEL_FILE=bzImage
INITRAMFS_FILE=initramfs.cpio.xz
INITRAMFS_PATHS=/bin /dev /etc /etc/init.d /lib /mnt /mnt/root /proc /sbin /sys /home /usr /usr/bin /usr/sbin /usr/lib64 /var
INITRAMFS_FILES=/init /etc/inittab /etc/init.d/rcS /etc/passwd /etc/shadow /etc/group /etc/issue /etc/hosts /etc/hostname /etc/services /etc/protocols /etc/profile /etc/resolv.conf /etc/nsswitch.conf /etc/localtime

DOWNLOADCMD=curl -s -O -L -k
MAKEOPT=-j$(shell nproc)
DROPBEAR_PROGRAMS=dropbear dbclient dropbearkey dropbearconvert scp

MIKROTIKDEVICE="Mips_boot" "MMipsBoot" "Powerboot" "e500_boot" "440__boot" "tile_boot" "ARM__boot" "ARM64__boot"
MIKROTIKARCH="-arm" "-arm64" "-mipsbe" "-mmips" "-smips" "-tile" "-ppc" ""

VERSIONS_FILE=versions.mk

-include $(VERSIONS_FILE)

$(VERSIONS_FILE):
	@echo "Hämtar senaste versionerna över nätverket..."
	@echo "# Automatiskt genererade versioner - ta bort filen för att uppdatera" > $@
	@echo "MIKROTIKVER_STABLE := $$(curl -s http://upgrade.mikrotik.com/routeros/NEWESTa7.stable | cut -f1 -d' ')" >> $@
	@echo "GRUB_VER := $$(curl -s https://ftp.gnu.org/gnu/grub/ | grep -oE 'grub-[0-9]+\.[0-9]+(\.[0-9]+)?\.tar\.xz' | sed 's/grub-//' | sed 's/\.tar\.xz//' | sort -V | tail -1)" >> $@
	@echo "LINUX_VER := $$(curl -s https://www.kernel.org/releases.json | jq -r '.latest_stable.version')" >> $@
	@echo "SYSLINUX_VER := $$(curl -s https://www.kernel.org/pub/linux/utils/boot/syslinux/ | grep -oE 'syslinux-[0-9]+\.[0-9]+(\.[0-9]+)?\.tar\.(xz|gz)' | sed -E 's/syslinux-(.*)\.tar\.(xz|gz)/\1/' | sort -V | tail -1)" >> $@
	@echo "BUSYBOX_VER := $$(curl -s https://busybox.net/downloads/ | grep -oE 'busybox-[0-9]+\.[0-9]+\.[0-9]+\.tar\.bz2' | sed 's/busybox-//' | sed 's/\.tar\.bz2//' | sort -V | tail -1)" >> $@
	@echo "XORRISO_VER := $$(curl -s https://ftp.gnu.org/gnu/xorriso/ | grep -oE 'xorriso-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' | sed -E 's/xorriso-(.*)\.tar\.gz/\1/' | sort -Vu | tail -1)" >> $@
	@echo "GLIBC_VER := $$(curl -s https://ftp.gnu.org/gnu/glibc/ | grep -oE 'glibc-[0-9]+\.[0-9]+(\.[0-9]+)?\.tar\.xz' | sed -E 's/glibc-(.*)\.tar\.xz/\1/' | sort -V | tail -1)" >> $@
	@echo "DROPBEAR_VER := $$(curl -s https://github.com/mkj/dropbear/releases | grep -oE 'DROPBEAR_[0-9]+\.[0-9]+' | sed 's/DROPBEAR_//' | sort -Vu | tail -1)" >> $@
	@echo "ZLIB_VER := $$(curl -s https://github.com/madler/zlib/releases | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//' | sort -Vu | tail -1)" >> $@
	@echo "LIBCRYPT_VER := $$(curl -s https://github.com/besser82/libxcrypt/releases.atom | grep -oE '<title>v[0-9]+\.[0-9]+\.[0-9]+' | sed -E 's/<title>v//' | sort -Vu | tail -1)" >> $@
	@echo "MTOOLS_VER := $$(curl -s https://ftp.gnu.org/gnu/mtools/ | grep -oE 'mtools-[0-9]+\.[0-9]+\.[0-9]+\.tar\.bz2' | sed -E 's/mtools-(.*)\.tar\.bz2/\1/' | sort -Vu | tail -1)" >> $@
	@echo "UNIFONT_VER := $$(curl -s https://ftp.gnu.org/gnu/unifont/ | grep -oE 'unifont-[0-9]+\.[0-9]+\.[0-9]+' | sort -Vu | tail -1 | sed 's/unifont-//')" >> $@
	@echo "FREETYPE_VER := $$(curl -s https://download.savannah.gnu.org/releases/freetype/ | grep -oE 'freetype-[0-9]+\.[0-9]+\.[0-9]+\.tar\.xz' | sed 's/freetype-//' | sed 's/\.tar\.xz//' | sort -V | tail -1)" >> $@
	@echo "DNSMASQ_VER := $$(curl -s https://thekelleys.org.uk/dnsmasq/ | grep -oE 'dnsmasq-[0-9]+\.[0-9]+(\.[0-9]+)?\.tar\.gz' | sed -E 's/dnsmasq-(.*)\.tar\.gz/\1/' | sort -V | tail -1)" >> $@
	@echo "FILEUTIL_VER := $$(curl -s https://www.astron.com/pub/file/ | grep -oE 'file-[0-9]+\.[0-9]+\.tar\.gz' | sed -E 's/file-(.*)\.tar\.gz/\1/' | sort -V | tail -1)" >> $@
	@echo "Versioner sparade i $(VERSIONS_FILE)."
	@cat $(VERSIONS_FILE)

update-versions:
	rm -f $(VERSIONS_FILE)
	$(MAKE) $(VERSIONS_FILE)

MIKROTIKURL_ST=$(subst ",,"https://download.mikrotik.com/routeros/$(MIKROTIKVER_STABLE)/routeros-$(MIKROTIKVER_STABLE)$(device).npk")
MIKROTIKROUTEROS_ST=$(subst ",,"routeros-$(MIKROTIKVER_STABLE)$(device).npk")

MIKROTIK_NETINSTALL_VER=$(MIKROTIKVER_STABLE)
MIKROTIK_NETINSTALL_FILE=netinstall-
MIKROTIK_NETINSTALL_DIR=./
MIKROTIK_NETINSTALL_TARBALL=$(MIKROTIK_NETINSTALL_FILE)$(MIKROTIKVER_STABLE).tar.gz
MIKROTIK_NETINSTALL_URL=https://download.mikrotik.com/routeros/$(MIKROTIK_NETINSTALL_VER)/$(MIKROTIK_NETINSTALL_TARBALL)

GRUB_FILE=grub-$(GRUB_VER)
GRUB_DIR=$(GRUB_FILE)/
GRUB_TARBALL=$(GRUB_FILE).tar.xz
GRUB_URL=https://mirror.bahnhof.net/pub/gnu/grub/$(GRUB_TARBALL)
GRUB_MODULES=all_video disk part_gpt part_msdos linux normal configfile search search_label iso9660 ls test gzio multiboot2 efi_gop efi_uga font gfxterm videoinfo

LINUX_MAJOR=$(word 1,$(subst ., ,$(LINUX_VER)))
LINUX_FILE=linux-$(LINUX_VER)
LINUX_DIR=$(LINUX_FILE)/
LINUX_TARBALL=$(LINUX_FILE).tar.xz
LINUX_KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v$(LINUX_MAJOR).x/$(LINUX_TARBALL)

BUSYBOX_FILE=busybox-$(BUSYBOX_VER)
BUSYBOX_DIR=$(BUSYBOX_FILE)/
BUSYBOX_TARBALL=$(BUSYBOX_FILE).tar.bz2
BUSYBOX_URL=https://busybox.net/downloads/$(BUSYBOX_TARBALL)

XORRISO_FILE=xorriso-$(XORRISO_VER)
XORRISO_DIR=$(XORRISO_FILE)/
XORRISO_TARBALL=$(XORRISO_FILE).pl02.tar.gz
XORRISO_URL=https://mirror.bahnhof.net/pub/gnu/xorriso/$(XORRISO_TARBALL)

SYSLINUX_FILE=syslinux-$(SYSLINUX_VER)
SYSLINUX_DIR=$(SYSLINUX_FILE)/
SYSLINUX_TARBALL=$(SYSLINUX_FILE).tar.xz
SYSLINUX_URL=https://www.kernel.org/pub/linux/utils/boot/syslinux/$(SYSLINUX_TARBALL)
SYSLINUX_FILES=bios/mbr/isohdpfx.bin bios/core/isolinux.bin bios/com32/elflink/ldlinux/ldlinux.c32 bios/com32/libutil/libutil.c32 bios/com32/lib/libcom32.c32 bios/com32/mboot/mboot.c32

DROPBEAR_FILE=DROPBEAR_
DROPBEAR_DIR=dropbear-$(DROPBEAR_FILE)$(DROPBEAR_VER)/
DROPBEAR_TARBALL=$(DROPBEAR_FILE)$(DROPBEAR_VER).tar.gz
DROPBEAR_URL=https://github.com/mkj/dropbear/archive/refs/tags/$(DROPBEAR_TARBALL)

ZLIB_FILE=zlib-$(ZLIB_VER)
ZLIB_DIR=$(ZLIB_FILE)/
ZLIB_TARBALL=$(ZLIB_FILE).tar.gz
ZLIB_URL=https://github.com/madler/zlib/releases/download/v$(ZLIB_VER)/$(ZLIB_TARBALL)

LIBCRYPT_FILE=libxcrypt-$(LIBCRYPT_VER)
LIBCRYPT_DIR=$(LIBCRYPT_FILE)/
LIBCRYPT_TARBALL=$(LIBCRYPT_FILE).tar.xz
LIBCRYPT_URL=https://github.com/besser82/libxcrypt/releases/download/v$(LIBCRYPT_VER)/$(LIBCRYPT_TARBALL)

GLIBC_FILE=glibc-$(GLIBC_VER)
GLIBC_DIR=$(GLIBC_FILE)/
GLIBC_TARBALL=$(GLIBC_FILE).tar.xz
GLIBC_URL=https://mirror.bahnhof.net/pub/gnu/glibc/$(GLIBC_TARBALL)

MTOOLS_FILE=mtools-$(MTOOLS_VER)
MTOOLS_DIR=$(MTOOLS_FILE)/
MTOOLS_TARBALL=$(MTOOLS_FILE).tar.gz
MTOOLS_URL=https://mirror.bahnhof.net/pub/gnu/mtools/$(MTOOLS_TARBALL)

UNIFONT_FILE=unifont-$(UNIFONT_VER).bdf
UNIFONT_DIR=$(UNIFONT_FILE)/
UNIFONT_TARBALL=$(UNIFONT_FILE).gz
UNIFONT_URL=https://mirror.bahnhof.net/pub/gnu/unifont/unifont-$(UNIFONT_VER)/$(UNIFONT_TARBALL)

FREETYPE_FILE=freetype-$(FREETYPE_VER)
FREETYPE_DIR=$(FREETYPE_FILE)/
FREETYPE_TARBALL=$(FREETYPE_FILE).tar.xz
FREETYPE_URL=https://download.savannah.gnu.org/releases/freetype/$(FREETYPE_TARBALL)

DHTEST_VER=v1.5
DHTEST_FILE=master
DHTEST_TARBALL=$(DHTEST_FILE).tar.gz
DHTEST_DIR=dhtest-master/
DHTEST_URL=https://github.com/saravana815/dhtest/archive/$(DHTEST_TARBALL)

STRACE_VER=$(word 1,$(subst ., ,$(LINUX_VER))).$(word 2,$(subst ., ,$(LINUX_VER)))
STRACE_FILE=strace-$(STRACE_VER)
STRACE_DIR=$(STRACE_FILE)/
STRACE_TARBALL=$(STRACE_FILE).tar.xz
STRACE_URL=https://github.com/strace/strace/releases/download/v$(STRACE_VER)/strace-$(STRACE_VER).tar.xz

DNSMASQ_FILE=dnsmasq-$(DNSMASQ_VER)
DNSMASQ_TARBALL=$(DNSMASQ_FILE).tar.xz
DNSMASQ_DIR=$(DNSMASQ_FILE)/
DNSMASQ_URL=https://thekelleys.org.uk/dnsmasq/$(DNSMASQ_TARBALL)

FILEUTIL_FILE=file-$(FILEUTIL_VER)
FILEUTIL_TARBALL=$(FILEUTIL_FILE).tar.gz
FILEUTIL_DIR=$(FILEUTIL_FILE)/
FILEUTIL_URL=https://www.astron.com/pub/file/$(FILEUTIL_TARBALL)

define file_extra_deps_lst
depends bli part_gpt
endef

define file_localtime
TZif2UTCTZif2UTC
UTC0
endef

define file_issue
 _   _      _   _           _        _ _
| \ | | ___| |_(_)_ __  ___| |_ __ _| | |
|  \| |/ _ \ __| | '_ \/ __| __/ _` | | |
| |\  |  __/ |_| | | | \__ \ || (_| | | |
|_| \_|\___|\__|_|_| |_|___/\__\__,_|_|_|
endef

define file_hostname
$(HOSTNAME)
endef

define file_rcS
#!/bin/sh
ip link set lo up
ip link set eth0 up
ip addr add $(IPADDR)/24 brd + dev eth0
ip route add default via $(DEFGATEW)
endef

define file_profile
export PS1='[\u@\h \W]\$$ '
export EDITOR='/bin/vi'
clear
cat /etc/issue
echo
uname -a
busybox | head -1
echo
endef

define file_grub_early_cfg
search --no-floppy --set=root --label "NETINSTALL"
set prefix=($$root)/boot/grub
endef

define file_grub_cfg
loadfont unifont
terminal_output gfxterm
set gfxmode=auto
set gfxpayload=keep
set timeout=5
menuentry "Linux Mikrotik Netinstall" {
linux	/boot/$(KERNEL_FILE) $(KERNEL_ARGSV)
initrd	/boot/$(INITRAMFS_FILE)
}
endef

define file_inittab
::sysinit:/bin/hostname -F /etc/hostname
::sysinit:/etc/init.d/rcS
tty0::respawn:-/bin/login -f root
ttyS0::respawn:-/bin/login -f root
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
127.0.0.1 localhost.localdomain localhost
$(IPADDR) $(HOSTNAME).local $(HOSTNAME)
endef

define file_init
#!/bin/sh
mount -t proc -o noexec,nosuid,nodev proc /proc
mount -t sysfs -o noexec,nosuid,nodev sysfs /sys
mount -t devtmpfs -o exec,nosuid,mode=755,size=2M devtmpfs /dev
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

define file_resolv_conf
nameserver $(PRIDNS)
nameserver $(SECDNS)
endef

define file_kernelkconfig
CONFIG_64BIT=y
CONFIG_IA32_EMULATION=y
CONFIG_COMPAT_32BIT_TIME=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y

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
CONFIG_SHMEM=y

CONFIG_PCI=y
CONFIG_ACPI=y
CONFIG_ACPI_BUTTON=y
CONFIG_FUTEX=y
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_RSEQ=y
CONFIG_EXPERT=y
CONFIG_PRINTK=y

#Do serial devices like ttyS0
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y

# Bas i systemet
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_INPUT=y
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y

# BIOS Textläge
CONFIG_VGA_CONSOLE=y

# Modern EFI / VESA konsol via DRM (Ersätter gamla FB)
CONFIG_DRM=y
CONFIG_DRM_SILENT=y             # (Om den finns tillgänglig i din build)
CONFIG_DRM_SIMPLEDRM=y
CONFIG_SYSFB_SIMPLEFB=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FONTS=y
CONFIG_FONT_8x16=y

CONFIG_BLOCK=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_FILE_LOCKING=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y

#Run elf and script files.
CONFIG_BINFMT_ELF=y
CONFIG_BINFMT_SCRIPT=y

CONFIG_SYSFS=y
CONFIG_PROC_FS=y
CONFIG_PROC_SYSCTL=y

#Create temp file system.
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y

#Inotify support for userspace
CONFIG_INOTIFY_USER=y

#Auto make /dev and do mount it to /dev
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y

#Do support initramfs copressed with xz
CONFIG_RD_XZ=y

#Compressed kernel with xz.
CONFIG_KERNEL_XZ=y
# CONFIG_HAVE_KERNEL_GZIP is not set
# CONFIG_HAVE_KERNEL_BZIP2 is not set
# CONFIG_HAVE_KERNEL_LZMA is not set
CONFIG_HAVE_KERNEL_XZ=y
# CONFIG_HAVE_KERNEL_LZO is not set
# CONFIG_HAVE_KERNEL_LZ4 is not set
# CONFIG_HAVE_KERNEL_ZSTD is not set

#Put .config file as compressed in proc.
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
CONFIG_DNS_RESOLVER=y
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=y
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_ETHTOOL_NETLINK=y
endef

define file_syslinux_cfg
TIMEOUT 10
PROMPT 1
DEFAULT linux

LABEL linux
MENU LABEL Linux Mikrotik Netinstall
KERNEL /boot/$(KERNEL_FILE)
INITRD /boot/$(INITRAMFS_FILE)
APPEND $(KERNEL_ARGSV)
endef

export file_kernelkconfig file_busyboxkconfig file_init file_issue file_passwd file_group file_resolv_conf file_hostname file_hosts file_extra_deps_lst file_grub_early_cfg file_syslinux_cfg file_rcS file_nsswitch_conf file_profile file_shadow file_services file_protocols file_inittab file_localtime file_grub_cfg

# --- Riktiga utdatafiler som Make använder som mål/beroenden (istället för stamp-filer) ---
KERNEL_OUT=$(ROOT_BASE)boot/$(KERNEL_FILE)
INITRAMFS_CPIO=$(OUT_BASE)initramfs.cpio
INITRAMFS_OUT=$(ROOT_BASE)boot/$(INITRAMFS_FILE)
KERNEL_HDR=$(OUT_BASE).kernel-headers.stamp
GLIBC_LIBC=$(INITRAMFS_BASE)usr/lib64/libc.so.6
ZLIB_LIB=$(INITRAMFS_BASE)usr/lib64/libz.so
LIBCRYPT_LIB=$(INITRAMFS_BASE)usr/lib64/libcrypt.so.1
BUSYBOX_BIN=$(SRC_BASE)$(BUSYBOX_DIR)busybox
STRACE_BIN=$(SRC_BASE)$(STRACE_DIR)src/strace
DROPBEAR_BIN=$(SRC_BASE)$(DROPBEAR_DIR)dropbear
DNSMASQ_BIN=$(SRC_BASE)$(DNSMASQ_DIR)src/dnsmasq
FILEUTIL_BIN=$(INITRAMFS_BASE)usr/bin/file
XORRISO_BIN=$(SRC_BASE)$(XORRISO_DIR)xorriso/xorriso
MTOOLS_MFORMAT=$(SRC_BASE)$(MTOOLS_DIR)mformat
MTOOLS_MCOPY=$(SRC_BASE)$(MTOOLS_DIR)mcopy
FREETYPE_LIB=$(SRC_BASE)$(FREETYPE_DIR)objs/.libs/libfreetype.so
GRUB_MKIMAGE=$(SRC_BASE)$(GRUB_DIR)grub-mkimage
UNIFONT_BDF=$(DIST_BASE)unifont-$(UNIFONT_VER).bdf
BOOTX64_EFI=$(ROOT_BASE)EFI/BOOT/BOOTX64.EFI
EFI_IMG=$(ROOT_BASE)boot/grub/efi.img
UNIFONT_PF2=$(ROOT_BASE)boot/grub/fonts/unifont.pf2
GRUB_CFG=$(ROOT_BASE)boot/grub/grub.cfg
SYSLINUX_CFG=$(ROOT_BASE)boot/syslinux/syslinux.cfg
SYS_ISOHDPFX=$(ROOT_BASE)boot/syslinux/isohdpfx.bin
SYS_ISOLINUX=$(ROOT_BASE)boot/syslinux/isolinux.bin
ROUTEROS_NETINSTALL=$(DIST_BASE)$(MIKROTIK_NETINSTALL_TARBALL)

# Konfigfiler som packas in i initramfs
INITRAMFS_CONF_FILES=$(INITRAMFS_BASE)init $(INITRAMFS_BASE)etc/issue $(INITRAMFS_BASE)etc/inittab $(INITRAMFS_BASE)etc/hostname $(INITRAMFS_BASE)etc/passwd $(INITRAMFS_BASE)etc/shadow $(INITRAMFS_BASE)etc/group $(INITRAMFS_BASE)etc/hosts $(INITRAMFS_BASE)etc/resolv.conf $(INITRAMFS_BASE)etc/nsswitch.conf $(INITRAMFS_BASE)etc/profile $(INITRAMFS_BASE)etc/localtime $(INITRAMFS_BASE)etc/services $(INITRAMFS_BASE)etc/protocols $(INITRAMFS_BASE)etc/init.d/rcS

all: $(ISO_FILE)

# --- Hämta/packa upp källkod (varje katalogs utdragning används som ordning-only-beroende) ---
$(SRC_BASE)$(LINUX_DIR): $(VERSIONS_FILE)
	$(info fetch-kernel-$(LINUX_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(LINUX_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(LINUX_KERNEL_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(LINUX_TARBALL)
	touch $@

$(SRC_BASE)$(BUSYBOX_DIR): $(VERSIONS_FILE)
	$(info fetch-busybox-$(BUSYBOX_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(BUSYBOX_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(BUSYBOX_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(BUSYBOX_TARBALL)
	touch $@

$(SRC_BASE)$(XORRISO_DIR): $(VERSIONS_FILE)
	$(info fetch-xorriso-$(XORRISO_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(XORRISO_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(XORRISO_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(XORRISO_TARBALL)
	touch $@

$(SRC_BASE)$(GRUB_DIR): $(VERSIONS_FILE)
	$(info fetch-grub-$(GRUB_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(GRUB_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(GRUB_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(GRUB_TARBALL)
	touch $@

$(SRC_BASE)$(FREETYPE_DIR): $(VERSIONS_FILE)
	$(info fetch-freetype-$(FREETYPE_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(FREETYPE_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(FREETYPE_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(FREETYPE_TARBALL)
	touch $@

$(UNIFONT_BDF): $(VERSIONS_FILE)
	$(info fetch-unifont-$(UNIFONT_VER))
	mkdir -p $(DIST_BASE)
	if [ ! -f "$(DIST_BASE)$(UNIFONT_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(UNIFONT_URL); fi
	cd $(DIST_BASE) && gunzip -kf $(DIST_BASE)$(UNIFONT_TARBALL)

$(SRC_BASE)$(SYSLINUX_DIR): $(VERSIONS_FILE)
	$(info fetch-syslinux-$(SYSLINUX_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(SYSLINUX_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(SYSLINUX_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(SYSLINUX_TARBALL)
	touch $@

$(SRC_BASE)$(MTOOLS_DIR): $(VERSIONS_FILE)
	$(info fetch-mtools-$(MTOOLS_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(MTOOLS_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(MTOOLS_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(MTOOLS_TARBALL)
	touch $@

$(SRC_BASE)$(STRACE_DIR): $(VERSIONS_FILE)
	$(info fetch-strace-$(STRACE_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(STRACE_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(STRACE_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(STRACE_TARBALL)
	touch $@

$(SRC_BASE)$(DROPBEAR_DIR): $(VERSIONS_FILE)
	$(info fetch-dropbear-$(DROPBEAR_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(DROPBEAR_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(DROPBEAR_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(DROPBEAR_TARBALL)
	touch $@

$(SRC_BASE)$(ZLIB_DIR): $(VERSIONS_FILE)
	$(info fetch-zlib-$(ZLIB_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(ZLIB_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(ZLIB_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(ZLIB_TARBALL)
	touch $@

$(SRC_BASE)$(LIBCRYPT_DIR): $(VERSIONS_FILE)
	$(info fetch-libcrypt-$(LIBCRYPT_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(LIBCRYPT_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(LIBCRYPT_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(LIBCRYPT_TARBALL)
	touch $@

$(SRC_BASE)$(GLIBC_DIR): $(VERSIONS_FILE)
	$(info fetch-glibc-$(GLIBC_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(GLIBC_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(GLIBC_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(GLIBC_TARBALL)
	touch $@

$(SRC_BASE)$(DNSMASQ_DIR): $(VERSIONS_FILE)
	$(info fetch-dnsmasq-$(DNSMASQ_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(DNSMASQ_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(DNSMASQ_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(DNSMASQ_TARBALL)
	touch $@

$(SRC_BASE)$(FILEUTIL_DIR): $(VERSIONS_FILE)
	$(info fetch-fileutil-$(FILEUTIL_VER))
	mkdir -p $(DIST_BASE) $(SRC_BASE)
	if [ ! -f "$(DIST_BASE)$(FILEUTIL_TARBALL)" ]; then cd $(DIST_BASE) && $(DOWNLOADCMD) $(FILEUTIL_URL); fi
	cd $(SRC_BASE) && tar -xf $(DIST_BASE)$(FILEUTIL_TARBALL)
	touch $@

$(ROUTEROS_NETINSTALL): $(VERSIONS_FILE)
	$(info fetch-routeros)
	mkdir -p $(DIST_BASE)
	cd $(DIST_BASE) && $(foreach device,$(MIKROTIKARCH),$(DOWNLOADCMD) $(MIKROTIKURL_ST);)
	cd $(DIST_BASE) && $(DOWNLOADCMD) $(MIKROTIK_NETINSTALL_URL)
	touch $@

# --- Kompilera komponenter (riktiga filer som mål) ---
$(KERNEL_OUT): | $(SRC_BASE)$(LINUX_DIR)
	$(info compile-kernel-$(LINUX_VER))
	mkdir -p $(dir $(KERNEL_OUT))
	printf "%s\n" "$$file_kernelkconfig" > $(SRC_BASE)$(LINUX_DIR)mytinyconfig
	cd $(SRC_BASE)$(LINUX_DIR) && $(MAKE) distclean
	cd $(SRC_BASE)$(LINUX_DIR) && $(MAKE) KCONFIG_ALLCONFIG=mytinyconfig allnoconfig
	cd $(SRC_BASE)$(LINUX_DIR) && $(MAKE) $(MAKEOPT)
	ln -sfn $(SRC_BASE)$(LINUX_DIR)arch/x86_64/boot/$(KERNEL_FILE) $(KERNEL_OUT)
	touch $@

$(KERNEL_HDR): $(KERNEL_OUT) | $(SRC_BASE)$(LINUX_DIR)
	$(info install-kernel-headers-$(LINUX_VER))
	mkdir -p $(INITRAMFS_BASE)usr
	cd $(SRC_BASE)$(LINUX_DIR) && $(MAKE) headers_install ARCH=x86_64 INSTALL_HDR_PATH=$(INITRAMFS_BASE)usr
	touch $@

$(GLIBC_LIBC): $(KERNEL_HDR) | $(SRC_BASE)$(GLIBC_DIR)
	$(info compile-glibc-$(GLIBC_VER))
	mkdir -p $(SRC_BASE)$(GLIBC_DIR)build
	cd $(SRC_BASE)$(GLIBC_DIR) && sed -i 's/^# \(PARALLELMFLAGS\)\(.*\)/\1=$(MAKEOPT)/' Makefile.in
	cd $(SRC_BASE)$(GLIBC_DIR)build && ../configure \
		--prefix=/usr \
		--libdir=/usr/lib64 \
		--disable-werror \
		--with-headers=$(INITRAMFS_BASE)usr/include \
		--disable-nls \
		--disable-build-nscd \
		--disable-profile \
		--disable-crypt \
		--disable-timezone-tools \
		--disable-gconv-modules \
		CXXFLAGS="-O2 -g0" CFLAGS="-O2 -g0"
	cd $(SRC_BASE)$(GLIBC_DIR)build && $(MAKE) $(MAKEOPT)
	cd $(SRC_BASE)$(GLIBC_DIR)build && $(MAKE) $(MAKEOPT) install DESTDIR=$(INITRAMFS_BASE)

$(BUSYBOX_BIN): $(GLIBC_LIBC) | $(SRC_BASE)$(BUSYBOX_DIR)
	$(info compile-busybox-$(BUSYBOX_VER))
	cd $(SRC_BASE)$(BUSYBOX_DIR) && $(MAKE) distclean
	cd $(SRC_BASE)$(BUSYBOX_DIR) && $(MAKE) defconfig
	cd $(SRC_BASE)$(BUSYBOX_DIR) && sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' .config
	cd $(SRC_BASE)$(BUSYBOX_DIR) && sed -i 's/^CONFIG_FEATURE_IPV6=y/# CONFIG_FEATURE_IPV6 is not set/' .config
	cd $(SRC_BASE)$(BUSYBOX_DIR) && $(MAKE) $(MAKEOPT) CC="gcc --sysroot=$(INITRAMFS_BASE)" busybox

$(STRACE_BIN): $(GLIBC_LIBC) | $(SRC_BASE)$(STRACE_DIR)
	$(info compile-strace-$(STRACE_VER))
	cd $(SRC_BASE)$(STRACE_DIR) && CC="gcc --sysroot=$(INITRAMFS_BASE)" LDFLAGS='-pthread -s' ./configure
	cd $(SRC_BASE)$(STRACE_DIR) && $(MAKE) $(MAKEOPT)

$(DNSMASQ_BIN): $(GLIBC_LIBC) | $(SRC_BASE)$(DNSMASQ_DIR)
	$(info compile-dnsmasq-$(DNSMASQ_VER))
	cd $(SRC_BASE)$(DNSMASQ_DIR) && $(MAKE) $(MAKEOPT) CC="gcc --sysroot=$(INITRAMFS_BASE)" LDFLAGS="-s"
	cd $(SRC_BASE)$(DNSMASQ_DIR) && cp $(SRC_BASE)$(DNSMASQ_DIR)src/dnsmasq $(INITRAMFS_BASE)sbin

$(FILEUTIL_BIN): $(GLIBC_LIBC) | $(SRC_BASE)$(FILEUTIL_DIR)
	$(info compile-fileutil-$(FILEUTIL_VER))
	cd $(SRC_BASE)$(FILEUTIL_DIR) && CC="gcc --sysroot=$(INITRAMFS_BASE)" ./configure --prefix=/usr --disable-static LDFLAGS='-s' CFLAGS='-g0'
	cd $(SRC_BASE)$(FILEUTIL_DIR) && $(MAKE) $(MAKEOPT)
	cd $(SRC_BASE)$(FILEUTIL_DIR) && $(MAKE) install DESTDIR=$(INITRAMFS_BASE)

$(XORRISO_BIN): | $(SRC_BASE)$(XORRISO_DIR)
	$(info compile-xorriso-$(XORRISO_VER))
	cd $(SRC_BASE)$(XORRISO_DIR) && ./configure
	cd $(SRC_BASE)$(XORRISO_DIR) && $(MAKE) $(MAKEOPT)

$(FREETYPE_LIB): | $(SRC_BASE)$(FREETYPE_DIR)
	$(info compile-freetype-$(FREETYPE_VER))
	cd $(SRC_BASE)$(FREETYPE_DIR) && ./configure
	cd $(SRC_BASE)$(FREETYPE_DIR) && $(MAKE) $(MAKEOPT)

FREETYPE_LIB_PATH=$(SRC_BASE)$(FREETYPE_DIR)objs/.libs

$(GRUB_MKIMAGE): $(FREETYPE_LIB) | $(SRC_BASE)$(GRUB_DIR)
	$(info compile-grub-$(GRUB_VER))
	cd $(SRC_BASE)$(GRUB_DIR) && printf "%s\n" "$$file_extra_deps_lst" > grub-core/extra_deps.lst
	cd $(SRC_BASE)$(GRUB_DIR) && ./configure --enable-grub-mkfont --enable-target=x86_64 --with-platform=efi --disable-werror --enable-liblzma FREETYPE_CFLAGS="-I $(SRC_BASE)$(FREETYPE_DIR)include" FREETYPE_LIBS="-L $(SRC_BASE)$(FREETYPE_DIR)objs/.libs -lfreetype"
	cd $(SRC_BASE)$(GRUB_DIR) && $(MAKE) $(MAKEOPT)

$(MTOOLS_MFORMAT) $(MTOOLS_MCOPY): | $(SRC_BASE)$(MTOOLS_DIR)
	$(info compile-mtools-$(MTOOLS_VER))
	cd $(SRC_BASE)$(MTOOLS_DIR) && ./configure
	cd $(SRC_BASE)$(MTOOLS_DIR) && $(MAKE) $(MAKEOPT)

$(ZLIB_LIB): $(GLIBC_LIBC) | $(SRC_BASE)$(ZLIB_DIR)
	$(info compile-zlib-$(ZLIB_VER))
	cd $(SRC_BASE)$(ZLIB_DIR) && CC="gcc --sysroot=$(INITRAMFS_BASE)" LDFLAGS="-s" ./configure --prefix=/usr --libdir=/usr/lib64
	cd $(SRC_BASE)$(ZLIB_DIR) && $(MAKE) $(MAKEOPT)
	cd $(SRC_BASE)$(ZLIB_DIR) && $(MAKE) $(MAKEOPT) install DESTDIR=$(INITRAMFS_BASE)

$(LIBCRYPT_LIB): $(GLIBC_LIBC) | $(SRC_BASE)$(LIBCRYPT_DIR)
	$(info compile-libcrypt-$(LIBCRYPT_VER))
	cd $(SRC_BASE)$(LIBCRYPT_DIR) && CFLAGS="-Wno-error=discarded-qualifiers" CC="gcc --sysroot=$(INITRAMFS_BASE)" LDFLAGS="-s" ./configure --prefix=/usr --libdir=/usr/lib64
	cd $(SRC_BASE)$(LIBCRYPT_DIR) && $(MAKE) $(MAKEOPT)
	cd $(SRC_BASE)$(LIBCRYPT_DIR) && $(MAKE) $(MAKEOPT) install DESTDIR=$(INITRAMFS_BASE)

$(DROPBEAR_BIN): $(LIBCRYPT_LIB) $(ZLIB_LIB) $(GLIBC_LIBC) | $(SRC_BASE)$(DROPBEAR_DIR)
	$(info compile-dropbear-$(DROPBEAR_VER))
	cd $(SRC_BASE)$(DROPBEAR_DIR) && CC="gcc --sysroot=$(INITRAMFS_BASE)" LDFLAGS="-s" ./configure --prefix=/usr
	cd $(SRC_BASE)$(DROPBEAR_DIR) && $(MAKE) $(MAKEOPT) PROGRAMS="$(DROPBEAR_PROGRAMS)"
	cd $(SRC_BASE)$(DROPBEAR_DIR) && $(MAKE) install DESTDIR=$(INITRAMFS_BASE) PROGRAMS="$(DROPBEAR_PROGRAMS)"

$(INITRAMFS_OUT): $(BUSYBOX_BIN) $(STRACE_BIN) $(DROPBEAR_BIN) $(ZLIB_LIB) $(LIBCRYPT_LIB) $(DNSMASQ_BIN) $(GLIBC_LIBC) $(FILEUTIL_BIN) $(ROUTEROS_NETINSTALL) $(INITRAMFS_CONF_FILES) | $(SRC_BASE)$(LINUX_DIR) $(SRC_BASE)$(BUSYBOX_DIR)
	$(info make-initramfs)
	mkdir -p $(INITRAMFS_BASE)bin $(INITRAMFS_BASE)sbin $(INITRAMFS_BASE)usr/lib64 $(INITRAMFS_BASE)dev $(INITRAMFS_BASE)proc $(INITRAMFS_BASE)sys $(INITRAMFS_BASE)mnt $(INITRAMFS_BASE)root $(INITRAMFS_BASE)etc/init.d $(INITRAMFS_BASE)lib
	mkdir -p $(INITRAMFS_BASE)boot $(INITRAMFS_BASE)media/floppy $(INITRAMFS_BASE)media/cdrom $(INITRAMFS_BASE)opt $(INITRAMFS_BASE)run/lock $(INITRAMFS_BASE)srv $(INITRAMFS_BASE)tmp $(INITRAMFS_BASE)var/tmp
	mkdir -p $(INITRAMFS_BASE)etc/opt $(INITRAMFS_BASE)etc/sysconfig
	mkdir -p $(INITRAMFS_BASE)usr/include $(INITRAMFS_BASE)usr/src $(INITRAMFS_BASE)usr/lib/locale $(INITRAMFS_BASE)usr/lib/firmware
	mkdir -p $(INITRAMFS_BASE)usr/local/bin $(INITRAMFS_BASE)usr/local/sbin $(INITRAMFS_BASE)usr/local/lib $(INITRAMFS_BASE)usr/local/include $(INITRAMFS_BASE)usr/local/src
	mkdir -p $(INITRAMFS_BASE)usr/share/{color,dict,doc,info,locale,misc,terminfo,zoneinfo}
	mkdir -p $(INITRAMFS_BASE)usr/share/man/man{1,2,3,4,5,6,7,8}
	mkdir -p $(INITRAMFS_BASE)usr/local/share/{color,dict,doc,info,locale,misc,terminfo,zoneinfo}
	mkdir -p $(INITRAMFS_BASE)usr/local/share/man/man{1,2,3,4,5,6,7,8}
	mkdir -p $(INITRAMFS_BASE)var/{cache,local,log,mail,opt,spool}
	mkdir -p $(INITRAMFS_BASE)var/lib/{color,misc,locate}
	chmod 0750 $(INITRAMFS_BASE)root
	chmod 1777 $(INITRAMFS_BASE)tmp $(INITRAMFS_BASE)var/tmp $(INITRAMFS_BASE)run/lock
	ln -sf ../run $(INITRAMFS_BASE)var/run
	ln -sf ../run/lock $(INITRAMFS_BASE)var/lock
	$(foreach device,$(MIKROTIKARCH),cp -f $(DIST_BASE)$(MIKROTIKROUTEROS_ST) $(INITRAMFS_BASE)root/ ;)
	cd $(INITRAMFS_BASE)root && tar --no-same-owner -xf $(DIST_BASE)$(MIKROTIK_NETINSTALL_TARBALL)
	cp -f $(BUSYBOX_BIN) $(INITRAMFS_BASE)bin/busybox
	strip $(INITRAMFS_BASE)bin/busybox
	chmod 755 $(INITRAMFS_BASE)bin/busybox
	for app in $$($(BUSYBOX_BIN) --list-full); do \
		mkdir -p $(INITRAMFS_BASE)$$(dirname $$app) ; \
		ln -sf /bin/busybox $(INITRAMFS_BASE)$$app ; \
	done
	cp -f $(STRACE_BIN) $(INITRAMFS_BASE)sbin/strace
	chmod 755 $(INITRAMFS_BASE)sbin/strace
	if [ -d $(INITRAMFS_BASE)lib64 ]; then cp -an $(INITRAMFS_BASE)lib64/. $(INITRAMFS_BASE)usr/lib64/ && rm -rf $(INITRAMFS_BASE)lib64; fi
	if [ -d $(INITRAMFS_BASE)usr/lib ]; then cp -an $(INITRAMFS_BASE)usr/lib/. $(INITRAMFS_BASE)usr/lib64/ && rm -rf $(INITRAMFS_BASE)usr/lib; fi
	rm -rf $(INITRAMFS_BASE)usr/share/locale
	rm -rf $(INITRAMFS_BASE)usr/share/i18n
	rm -rf $(INITRAMFS_BASE)usr/share/doc
	rm -rf $(INITRAMFS_BASE)usr/share/info
	rm -rf $(INITRAMFS_BASE)usr/share/man
	rm -rf $(INITRAMFS_BASE)usr/include
	rm -f  $(INITRAMFS_BASE)usr/lib64/*.a
	find $(INITRAMFS_BASE) -type f -executable -exec strip --strip-unneeded {} \;
	rm -rf $(INITRAMFS_BASE)lib
	ln -sf usr/lib64 $(INITRAMFS_BASE)lib64
	ln -sf usr/lib64 $(INITRAMFS_BASE)lib
	cd $(SRC_BASE)$(LINUX_DIR) && ./usr/gen_initramfs.sh -o $(INITRAMFS_CPIO) $(INITRAMFS_BASE)
	cat $(INITRAMFS_CPIO) | xz -9 -T0 -C crc32 > $(INITRAMFS_OUT)
	touch $@

$(BOOTX64_EFI): $(GRUB_MKIMAGE) $(UNIFONT_BDF)
	$(info make-grub-mkimage)
	mkdir -p $(dir $(BOOTX64_EFI))
	cd $(SRC_BASE)$(GRUB_DIR) && printf "%s\n" "$$file_grub_early_cfg" > grub_early.cfg
	cd $(SRC_BASE)$(GRUB_DIR) && ./grub-mkimage --config="./grub_early.cfg" --prefix="/boot/grub" --output="$(BOOTX64_EFI)" --format="x86_64-efi" --compression="xz" --directory="./grub-core" $(GRUB_MODULES)
	touch $@

$(UNIFONT_PF2): $(GRUB_MKIMAGE) $(FREETYPE_LIB) $(UNIFONT_BDF)
	$(info make-grub-mkfont)
	mkdir -p $(dir $(UNIFONT_PF2))
	cd $(SRC_BASE)$(GRUB_DIR) && LD_LIBRARY_PATH=$(FREETYPE_LIB_PATH) ./grub-mkfont -o $(UNIFONT_PF2) $(UNIFONT_BDF)
	touch $@

$(GRUB_CFG):
	$(info make-grub.cfg)
	mkdir -p $(dir $(GRUB_CFG))
	printf "%s\n" "$$file_grub_cfg" > $(GRUB_CFG)
	touch $@

$(SYSLINUX_CFG): | $(SRC_BASE)$(SYSLINUX_DIR)
	$(info copy-syslinux-files-$(SYSLINUX_VER))
	mkdir -p $(dir $(SYSLINUX_CFG))
	$(foreach file,$(SYSLINUX_FILES),ln -sfn $(SRC_BASE)$(SYSLINUX_DIR)/$(file) $(ROOT_BASE)boot/syslinux/$(notdir $(file));)
	printf "%s\n" "$$file_syslinux_cfg" > $(SYSLINUX_CFG)
	touch $@

$(EFI_IMG): $(MTOOLS_MFORMAT) $(MTOOLS_MCOPY) $(BOOTX64_EFI)
	$(info make-grub-efi-image)
	mkdir -p $(dir $(EFI_IMG))
	cd $(SRC_BASE)$(MTOOLS_DIR) && ./mformat -i $(EFI_IMG) -C -f 1440 -N 0 ::
	cd $(SRC_BASE)$(MTOOLS_DIR) && ./mcopy -i $(EFI_IMG) -s $(ROOT_BASE)EFI ::
	touch $@

$(INITRAMFS_BASE)init:
	$(info init-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_init" > $@
	chmod +x $@

$(INITRAMFS_BASE)etc/issue:
	$(info issue-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_issue" > $@

$(INITRAMFS_BASE)etc/hostname:
	$(info hostname-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_hostname" > $@

$(INITRAMFS_BASE)etc/hosts:
	$(info hosts-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_hosts" > $@

$(INITRAMFS_BASE)etc/nsswitch.conf:
	$(info nsswitch-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_nsswitch_conf" > $@

$(INITRAMFS_BASE)etc/passwd:
	$(info passwd-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_passwd" > $@

$(INITRAMFS_BASE)etc/shadow:
	$(info shadow-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_shadow" > $@

$(INITRAMFS_BASE)etc/inittab:
	$(info inittab-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_inittab" > $@

$(INITRAMFS_BASE)etc/group:
	$(info group-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_group" > $@

$(INITRAMFS_BASE)etc/resolv.conf:
	$(info resolv-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_resolv_conf" > $@

$(INITRAMFS_BASE)etc/localtime:
	$(info localtime-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_localtime" > $@

$(INITRAMFS_BASE)etc/services:
	$(info services-file)
	mkdir -p $(dir $@)
	printf "%s" "$$file_services" | base64 -d | xz -d -T0 > $@

$(INITRAMFS_BASE)etc/protocols:
	$(info protocols-file)
	mkdir -p $(dir $@)
	printf "%s" "$$file_protocols" | base64 -d | xz -d -T0 > $@

$(INITRAMFS_BASE)etc/profile:
	$(info profile-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_profile" > $@

$(INITRAMFS_BASE)etc/init.d/rcS:
	$(info rcS-file)
	mkdir -p $(dir $@)
	printf "%s\n" "$$file_rcS" > $@
	chmod +x $@

$(ISO_FILE): $(XORRISO_BIN) $(KERNEL_OUT) $(INITRAMFS_OUT) $(EFI_IMG) $(BOOTX64_EFI) $(GRUB_CFG) $(UNIFONT_PF2) $(SYSLINUX_CFG) $(SYS_ISOHDPFX) $(SYS_ISOLINUX)
	$(info make-iso-file)
	mkdir -p $(dir $(ISO_FILE))
	$(XORRISO_BIN) -as mkisofs -output $@ -full-iso9660-filenames -joliet -rational-rock -sysid "LINUX" -volid "NETINSTALL" -follow-links -isohybrid-mbr $(SYS_ISOHDPFX) -eltorito-boot boot/syslinux/isolinux.bin -eltorito-catalog boot/syslinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat $(ROOT_BASE)
	touch $@

distclean:
	$(info $(notdir $@))
	git clean -ffdx

run:
	$(info "Run qemu <CTRL><a> <x> to exit.")
	qemu-system-x86_64 -m 2G -kernel $(ROOT_BASE)boot/$(KERNEL_FILE) -initrd $(ROOT_BASE)boot/$(INITRAMFS_FILE) -append "$(KERNEL_ARGSV)" -enable-kvm -cpu host -nic user,model=e1000e -nographic

run-iso:
	$(info "Run qemu <CTRL><a> <x> to exit.")
	qemu-system-x86_64 -m 2G -boot d -cdrom $(ISO_FILE) -enable-kvm -cpu max -nic user,model=e1000e -nographic

run-iso-efi:
	$(info "Run qemu <CTRL><a> <x> to exit. ")
	qemu-system-x86_64 -m 2G -boot d -cdrom $(ISO_FILE) -enable-kvm -cpu max -nic user,model=e1000e -nographic -pflash /usr/share/OVMF/OVMF_CODE_4M.fd

check_tools:
	$(info Please install these dependencies before running $(MAKEFILE_LIST) again.)
	$(info $(MISSING_FILES))

copy:
	scp file.iso patrik@192.168.0.25:Hämtningar

.PHONY: all test clean distclean update-versions run run-iso run-iso-efi check_tools copy passwd group shadow hosts networks protocols services ethers rpc root guest nobody root SHELL
