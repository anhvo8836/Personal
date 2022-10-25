#!/bin/sh

clear

# UEFI Check
# The script will first check if the system has been booted in UEFI mode.
# It will exit with an error message if the system is not properly booted.

    if [ ! -d "/sys/firmware/efi/efivars" ]
    then
        echo "[Error!] System is not booted in UEFI mode. Please boot in UEFI mode & try again."
        exit 9999
    fi

# Start Screen

    echo "==| ARCH LINUX INSTALL SCRIPT |=="
    echo ""
    read -p "Press enter to begin the installation"
    echo ""
    sleep 2

# 1 - Pre-Installation

# 1.1 - Test Internet Connection
# Test the internet connection by sending quiet pings to the Arch website.

    echo "We will test your internet connection by sending 3 pings to the Arch Linux website"
    echo "The results will be displayed below"
    echo ""
    ping -c 3 -q archlinux.org
    echo ""
    sleep 2

# 1.2 - Update System Clock
# This will set the system clock to NTP.

    timedatectl set-ntp true &>/dev/null
    echo "The system clock has been synced to NTP"
    echo ""
    sleep 2

# 1.3 - Drive Preparation

# 1.3a - Drive Selection

    lsblk
    echo ""
    echo -ne 'Which drive will you be installing Arch Linux to? > ';read device
    echo "OK, Arch Linux will be installed to $device"
    echo ""
    sleep 2

# 1.3b - Create Partition(s)
# Choose whether the chosen driven should be formatted for a dual-boot
# installation.
# Dual-Boot option - This will create a single partition on the chosen drive.
# The partition will span the entire drive (100% usage). This is the default
# action.
# Single OS option - This will create an ESP and a root partition on the
# chosen drive.


    echo -ne 'Will you be dual-booting alongside another OS? > ';read dualboot

    case $dualboot in

    Y | y )

        echo "OK, $device will be partitioned for a dual-boot installation"
        echo ""
        (echo g ; echo n ; echo "1" ; echo "" ; echo "" ; w) > fdisk -W always $device
        echo ""
        echo "The root partition has been created on $device"
        echo ""

    ;;

    N | n )

        echo "OK, $device will be partitioned for a single OS installation"
        echo ""
        (echo g ; echo n ; echo "1" ; echo "" ; echo "+500M" ; echo "n" ; echo "2" ; echo "" ; echo "" ; w) > fdisk -W always $device
        echo ""
        echo "The root partition has been created on $device"
        echo ""

    ;;

    *)

        echo "OK, $device will be partitioned for a dual-boot installation"
        echo ""
        (echo g ; echo n ; echo "1" ; echo "" ; echo "" ; w) > fdisk -W always $device
        echo ""
        echo "The root partition has been created on $device"
        echo ""

    ;;

    esac
    sleep 2

# 1.3c - Set Partitions
# This will set the partitions as variables. This will allow for an automated
# mounting process

    lsblk
    echo ""
    echo -ne 'Locate the root partition > ';read main
    echo -ne 'Locate the ESP > ';read esp
    echo ""
    echo "$main has been set as the root parition"
    echo "$esp has been set as the ESP"
    echo ""
    sleep 2

# 1.3c - Format Partition(s)
# This will format the parition(s) as needed. The root parititon will be
# formatted to BTRFS file format will ARCH as the system label. If created
# during the partition creation stage, the ESP will be formatted to FAT32.

    case $dualboot in

    Y | y )

        echo "$main will now be formatted to BTRFS"
        echo ""
        mkfs.btrfs -f -L "ARCH" $main
        echo ""

    ;;

    N | n )

        echo "$main will now be formatted to BTRFS"
        echo ""
        mkfs.btrfs -f -L "ARCH" $main
        echo ""
        sleep 2

        echo "$esp will now be formatted to FAT32"
        echo ""
        mkfs.fat -F 32 -L "ESP" $esp
        echo ""

    ;;

    * )

        echo "$main will now be formatted to BTRFS"
        echo ""
        mkfs.btrfs -f -L "ARCH" $main
        echo ""

    ;;

    esac
    sleep 2

# 1.3d - Create and Mount Subvolumes
# This will create a subvolume at / (@), /var (@var), and /home (@home) on the
# main BTRFS partition. The script will also mount the subvolumes to the
# appropriate mount points.

    echo "The applicable subvolumes will now be created"
    echo ""
    mount $main /mnt
    btrfs su cr /mnt/@
    btrfs su cr /mnt/@var
    btrfs su cr /mnt/@home
    echo ""
    sleep 2

    umount /mnt
    mount -o defaults,noatime,compress=zstd,commit=120,subvol=@ $main /mnt
    mkdir -p /mnt/{var,home}
    mount -o defaults,noatime,compress=zstd,commit=120,subvol=@var $main /mnt/var
    mount -o defaults,noatime,compress=zstd,commit=120,subvol=@home $main /mnt/home
    echo "The subvolumes have been mounted as follows..."
    echo "@ -> /"
    echo "@var -> /var"
    echo "@home -> /home"
    echo ""
    sleep 2

# 1.3e - Mount ESP
# This will mount the pre-chosen ESP to the appropriate mount point

    mkdir -p /mnt/boot/efi
    mount $esp /mnt/boot/efi
    echo "$esp has been mounted"
    echo ""
    sleep 2

# 1.4 Installation Environment (pacman.conf)
# Configure the installation environment by editing the /etc/pacman.conf
# file. Color, Parallel Downloads, and the Multilib repository will be
# enabled during this step.

    sed -i 's/#Color/Color/' /etc/pacman.conf
    sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 25/' /etc/pacman.conf
    sed -i '93,94s/^#//' /etc/pacman.conf
    echo "Parallel downloads have been enabled and increased to 25"
    echo "The Multilib repository has been emabled"
    echo ""
    sleep 2

# 1.5 - Mirrorlist
# Refresh the mirrorlist and populate it with a sorted list of the fastest
# Canada, American, and Worlwide mirrors.

    echo "Please wait while a new mirrorlist is being generated."
    echo ""
    echo "Mirrors : Canada, US, Worldwide"
    echo "# of Mirrors : 50"
    echo "Protocol : http, https"
    echo "Sort by : Speed"
    echo "Save Location : /etc/pacman.d/mirrorlist"
    reflector --country 'Canada,US, ' --latest 50 --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist &>/dev/null # Hiding error message if any
    echo ""
    echo "A new list of mirrors has been generated."
    echo ""
    sleep 2

# 1.6 - Refresh Databases and Arch Linux keyring
# Refresh all of the repository databases as well as the Arch Linux keyring.
# Refreshing the keyring will help prevent package from not installing due
# to key issues.

    echo "The repository databases and Arch Linux keyring will now be refreshed"
    echo ""
    pacman -Syyy archlinux-keyring --noconfirm --disable-download-timeout
    echo ""
    sleep 2

# 2 - Installation

# 2.1 - Base Installation
# Install the packages for a base Arch Linux install

    echo "The base system will now be installed"
    echo "[Packages] 'base' 'linux-zen' 'linux-firmware'"
    sleep 2
    echo ""
    pacstrap /mnt baselinux-zen linux-firmware --needed --noconfirm --disable-download-timeout
    echo ""
    echo "The base system packages have been installed"
    echo ""
    sleep 2

# 2.2 - Extra Core Utilities
# Install additional utilities needed for more complete system toolkit

    echo "Additional system utilities will now be installed"
    echo "[Packages] 'base-devel' 'micro' 'man-pages' 'man-db' 'snapper' 'git' 'lsd' 'bat' 'htop'"
    sleep 2
    echo ""
    pacstrap /mnt base-devel micro man-pages man-db snapper git lsd bat htop --needed --noconfirm --disable-download-timeout
    echo ""
    echo "Additional system utilities have been installed"
    echo ""
    sleep 2

# 2.2 - FStab
# Generate the /etc/fstab file

    genfstab -U /mnt > /mnt/etc/fstab
    echo "The FStab file has been generated"
    echo ""
    sleep 2

# 2.3 - Chroot
# Copy over the script folder as well as the mirrorlist and pacman.conf files
# from the live ISO to the new root partition. This folder contains a setup
# script that will automatically run once in the chroot environment.

    cat /etc/pacman.d/mirrorlist > /mnt/etc/pacman.d/mirrorlist
    cat /etc/pacman.conf > /mnt/etc/pacman.conf
    cp -r ~/scripts /mnt

    echo "The mirrorlist has been copied to the new installation"
    echo "The pacman.conf files has been copied to the new installation"
    echo "The scripts folder has been copied to the new installation"
    echo ""
    sleep 2;clear

    arch-chroot sh /scripts/setup.sh

# Ending prompt (user-initiated reboot)

echo " ==| ARCH LINUX INSTALL SCRIPT |=="
echo ""
echo "Arch Linux has been installed and configured."
echo "Your system is ready to reboot."
echo "Remember to disconnect your installation media."
echo ""
read -p "Press enter to reboot your system"
clear
echo "Rebooting in 5s...";sleep 1
echo "Rebooting in 4s...";sleep 1
echo "Rebooting in 3s...";sleep 1
echo "Rebooting in 2s...";sleep 1
echo "Rebooting in 1s...";sleep 1
reboot
