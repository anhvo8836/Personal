#!/bin/sh

# Chroot Start Screen

    echo "==| SETUP |=="
    echo ""
    echo "We are now in the chroot envrionment"
    echo ""

# Choose installation method
# The setup process will differ depending on the chosen installation method.
# The script will set the applicable hostname and install the appropriate
# set of applications. The default action is to set up for a PC installation.

    echo "Are you installing on a PC or a Virtual Machine?"
    echo ""
    echo "1) PC"
    echo "2) Virtual Machine"
    echo ""
    echo -ne '> ';read install_method
    echo ""

    case "$install_method" in

        1 )

            echo "OK, A PC setup process will be performed"

        ;;

        2 )

            echo "OK, A virtual machine setup process will be performed"

        ;;

        * )

            echo "OK, A PC setup process will be performed"

        ;;

    esac
    echo ""
    sleep 2

# 1. Refresh Databases
# Refresh the repository databases for the newly created Arch Linux
# installation.

    pacman -Syyy

# 2. System Optimization
# Set up swap space, fstrim service, and parallel compiling. Enabling
# parallel compiling with allowing for the CPU to use all cores
# available when building packages from source.

    echo "+-----------------------------+"
    echo "| Recommended Swap Size       |"
    echo "+-----------------+-----------+"
    echo "| RAM Size        | Swap Size |"
    echo "+-----------------+-----------+"
    echo "| Less than 2GB   | RAM x2    |"
    echo "| 2GB - 8GB       | RAM       |"
    echo "| More than 8GB   | RAM x0.5  |"
    echo "+-----------------+-----------+"
    echo ""

    availMemMb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    gb=$(awk "BEGIN {print $availMemMb/1024/1024}")
    gb=$(echo $gb | awk '{print ($0-int($0)<0.499)?int($0):int($0)+1}')
    echo -e Available Physical RAM: $gb\GB
    echo ""

    echo "How much space would you like to allocate to swap?"
    echo "Eg. Enter 2G to allocate 2GB of swap space"
    echo ""
    echo -ne 'Swap size > ';read swapsize
    echo ""
    echo "$swapsize will be allocated to swap..."
    echo ""
    sleep 2

        mkdir -p /etc/modules-load.d
        touch /etc/modules-load.d/zram.conf
        echo "zram" > /etc/modules-load.d/zram.conf

        mkdir -p /etc/modprobe.d/
        touch /etc/modprobe.d/zram.conf
        echo "options zram num_devices=1" > /etc/modprobe.d/zram.conf

        mkdir -p /etc/udev/rules.d/
        touch /etc/udev/rules.d/99-zram.rules
        echo "KERNEL==\"zram0\",ATTR{disksize}=\"$swapsize\" RUN=\"/usr/bin/mkswap /dev/zram0\",TAG+=\"systemd\"" > /etc/udev/rules.d/99-zram.rules

        mkdir -p /etc/systemd/system/
        touch /etc/systemd/system/zram.service
        echo -e [Unit]'\n'Description=Swap with zram'\n'After=multi-user.target'\n\n'[Service]'\n'Type=oneshot'\n'RemainAfterExit=true'\n'ExecStartPre=/sbin/mkswap /dev/zram0'\n'ExecStart=/sbin/swapon /dev/zram0'\n'ExecStop=/sbin/swapoff /dev/zram0'\n\n'[Install]'\n'WantedBy=multi-user.target >> /etc/systemd/system/zram.service

        systemctl enable zram.service
        echo ""

    echo "Swap (zram) has been set up with $swapsize allocated"
    echo ""
    sleep 2

    echo "The FStrim timer will now be enabled"
    echo ""
    systemctl enable fstrim.timer
    echo ""
    sleep 2

    echo "Parallel compiling will now be enabled"
    echo ""
    sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf
    sleep 2

# 3. Timezone and Localization

# 3a - Set Timezone
# Set the timezone to America/Toronto by setting up the appropriate links.

    echo "The system-wide timezone will be set to America/Toronto"
    echo ""
    ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
    sleep 2

# 3b - Set System Language
# Set the appropriate system-wide locales (American English).

    echo "The system-wide language will now be set to American English"
    echo ""
    sed -i '171s/^#//' /etc/locale.gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    locale-gen
    echo ""
    sleep 2

# 4 - Network Configuration
# Configure the network on the newly created installation. Skipping this
# step will render the system without internet upon rebooting. The hostname
# will be set according to the chosen setup method

    echo "The appropriate packages will now be downloaded and installed to configure your network"
    echo "[Packages] 'networkmanager' 'network-manager-applet'"
    echo "The system's hostname will also be set"
    echo ""
    sleep 2

    pacman -S networkmanager network-manager-applet
    echo ""
    systemctl enable NetworkManager.service
    echo ""

    case "$install_method" in

    1) # PC

        echo "arch-pc" > /etc/hostname # Set the hostname
        echo -e 127.0.0.1'\t'localhost'\n'::1'\t\t'localhost'\n'127.0.1.1'\t'arch-pc >> /etc/hosts

    ;;

    2)

        echo "arch-vm" > /etc/hostname # Set the hostname
        echo -e 127.0.0.1'\t'localhost'\n'::1'\t\t'localhost'\n'127.0.1.1'\t'arch-vm >> /etc/hosts

    ;;

    *) # PC

        echo "arch-pc" > /etc/hostname # Set the hostname
        echo -e 127.0.0.1'\t'localhost'\n'::1'\t\t'localhost'\n'127.0.1.1'\t'arch-pc >> /etc/hosts

    ;;

    esac
    sleep 2

# 5 - User Accounts
# This section will enable the root account by setting a password for it.
# It will also create a superuser account with a desired name, change the
# user's default shell to Fish, add the user to the wheel group, and
# enable the wheel group to execute commands at the terminal.

    echo "Let's set the password for the root account."
    echo ""
    passwd
    echo ""
    sleep 2

    echo "Let's create a superuser"
    echo ""
    echo "What will the name of your user account be?"
    echo -ne 'Username > ';read username
    useradd -m $username
    echo "$username has been created"
    echo ""

    echo "Let's set the password for $username"
    passwd $username
    echo ""

    echo "$username will now be added to the wheel group"
    usermod -aG wheel $username
    sed -i '85s/^#//' /etc/sudoers
    echo ""

    echo "$username's default shell will be changed to fish"
    echo ""
    pacman -S fish --needed --noconfirm --disable-download-timeout
    echo ""
    chsh -s /bin/fish $username
    echo ""
    sleep 2

# 6 - Video Drivers
# Install the appropiate drivers according to the chosen setup method

    case "$install_method" in

    1) # PC

        echo "The AMD/ATI (Open-source) drivers will be installed"
        echo "[Packages] 'mesa' 'xf86-video-amdgpu' 'xf86-video-ati' 'libva-mesa-driver' 'vulkan-radeon'"
        echo ""
        pacman -S mesa xf86-video-amdgpu xf86-video-ati libva-mesa-driver vulkan-radeon --needed --noconfirm --disable-download-timeout
        echo ""
        echo "The AMD/ATI (Open-source drivers have been installed"

    ;;

    2) # VM

        echo "The VMWare / Virtualbox / QEMU drivers will be installed"
        echo "[Packages] 'mesa' 'xf86-video-vmware'"
        echo ""
        pacman -S mesa xf86-video-vmware --needed --noconfirm
        echo ""
        echo "The VMWare / Virtualbox / QEMU drivers have been installed"

    ;;

    * )

        echo "The AMD/ATI (Open-source) drivers will be installed"
        echo "[Packages] 'mesa' 'xf86-video-amdgpu' 'xf86-video-ati' 'libva-mesa-driver' 'vulkan-radeon'"
        echo ""
        pacman -S mesa xf86-video-amdgpu xf86-video-ati libva-mesa-driver vulkan-radeon --needed --noconfirm --disable-download-timeout
        echo ""
        echo "The AMD/ATI (Open-source drivers have been installed"

    ;;

    esac
    echo ""
    sleep 2

# 7 - Audio Server (Pipewire)
# Install Pipewire on the new system

    echo "Pipewire will be installed"
    echo "[Packages] 'pipewire' 'wireplumber' 'pipewire-pulse' 'pipewire-alsa' 'pipewire-jack' 'gst-plugin-pipewire' 'libpulse'"
    echo ""
    pacman -S pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack gst-plugin-pipewire libpulse --needed --disable-download-timeout
    echo ""
    echo "Pipewire has been installed"
    echo ""
    sleep 2

# 8 - Printer Support
# Install printer support on the new system

    echo "The packages need for printer support will now be installed"
    echo "[Packages] 'gutenprint' 'ghostscript'"
    echo ""
    pacman -S gutenprint ghostscript --needed --noconfirm --disable-download-timeout
    echo ""
    systemctl enable cups.service
    echo ""
    echo "Printer support packages has been installed"
    echo "The CUPS Printer service has been started"
    echo ""
    sleep 2

# 9 - Desktop Environment

# 9a - KDE Plasma
# Install KDE Plasma on the new system and enable the SDDM display manager

    echo "The Plasma desktop will be installed"
    echo "[Packages] 'xorg-server' 'xorg-xinit' 'ark' 'bluedevil' 'breeze-gtk' 'dolphin' 'discover' 'drkonqi' 'kate' 'kcalc' 'kdeconnect' 'kde-gtk-config' 'kdeplasma-addons' 'kgamma5' 'khotkeys' 'kinfocenter' 'konsole' 'kscreen' 'ksshaskpass' 'kwallet-pam' 'kwayland-integration' 'oxygen' 'oxygen-sounds' 'plasma-browser-integration' 'plasma-desktop' 'plasma-disks' 'plasma-firewall' 'plasma-nm' 'plasma-pa' 'plasma-systemmonitor' 'plasma-thunderbolt' 'plasma-vault' 'plasma-workspace-wallpapers' 'plasma-wayland-session' 'print-manager' 'powerdevil' 'xdg-desktop-portal-kde' 'egl-wayland' 'sddm' 'sddm-kcm'"
    echo ""
    pacman -S xorg-server xorg-xinit ark bluedevil breeze-gtk dolphin discover drkonqi kate kcalc kdeconnect kde-gtk-config kdeplasma-addons kgamma5 khotkeys kinfocenter konsole kscreen ksshaskpass kwallet-pam kwayland-integration oxygen oxygen-sounds plasma-browser-integration plasma-desktop plasma-disks plasma-firewall plasma-nm plasma-pa plasma-systemmonitor plasma-thunderbolt plasma-vault plasma-workspace-wallpapers plasma-wayland-session print-manager powerdevil xdg-desktop-portal-kde egl-wayland sddm sddm-kcm --needed --noconfirm --disable-download-timeout
    echo ""
    systemctl enable sddm.service
    echo ""
    echo "The Plasma desktop has been installed."
    echo ""
    sleep 2

# 9b - Applications
# Install additional applications on the new system

    echo "Applications will now be installed on the system"
    echo "[Packages] 'caprine' 'firefox' 'qbittorrent' 'vlc'"
    echo ""
    pacman -S caprine firefox qbittorrent vlc
    echo ""

# 10 - Bootloader
# Install GRUB as the bootloader using the ESP mounted at /boot/efi.

    echo "The appropiate packages will now be downloaded to install the bootloader"
    echo "[Packages] 'grub' 'os-prober' 'ntfs-3g' 'efibootmgr' 'amd-ucode'"
    echo ""
    pacman -S grub os-prober ntfs-3g efibootmgr amd-ucode --needed --noconfirm --disable-download-timeout
    echo ""

    echo "GRUB will now be installed as the bootloader"
    echo ""
    grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
    echo ""

    mkdir -p /boot/grub/themes
    cp -r /scripts/themes/asus /boot/grub/themes/asus
    sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=-1/' /etc/default/grub
    sed -i 's/GRUB_THEME=/GRUB_THEME="/boot/grub/themes/asus/theme.txt"/' /etc/default/grub
    sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub

    echo "The timer has been disabled in the default GRUB config file"
    echo "The GRUB theme has been set in the default GRUB config file"
    echo "OS Prober has been enabled in the default GRUB config file"
    echo ""

    echo "OS-Prober will now be enabled to detect any other installed OS"
    echo ""
    os-prober
    echo ""

    echo "The GRUB configuration file will now be created"
    echo ""
    grub-mkconfig -o /boot/grub/grub.cfg
    echo ""

# End

echo "==| FINISHED |=="
sleep 2
clear;exit
