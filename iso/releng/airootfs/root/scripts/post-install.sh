#!/bin/sh

clear

# Start screen

echo "==| POST-INSTALL |=="
echo ""

    echo "Hello, $USER"
    echo ""
    read -p "Press enter to begin the post-install script"
    sleep 2
    echo ""

# 1 - Install Yay
# Install Yay to enable the AUR. This will allow AUR packages to be installed
# at the command line as opposed to building from source

    echo "Yay will now be installed..."
    git clone https://aur.archlinux.org/yay.git
    echo ""
    cd yay
    makepkg -si
    echo ""
    cd ~
    rm -rf yay
    echo "Yay has been installed."
    echo "You can now install AUR packages at the command line by using yay -S"
    echo ""
    sleep 2

# 2 - Applications
# Install snap-pac, BTRFS Assistant (AUR), Arch Update Notifier (AUR), and Starship prompt (Source) to the new system

    echo "Snap-Pac will now be installed"
    echo ""
    yay -S snap-pac --needed --noconfirm --disable-download-timeout
    echo ""
    echo "Snap-Pac has been installed"
    echo ""
    sleep 2

    echo "BTRFS Assistant will now be installed"
    echo ""
    yay -S btrfs-assistant --needed --noconfirm --disable-download-timeout
    echo ""
    echo "BTRFS Assistant has been installed."
    echo ""
    sleep 2

    echo "Arch Update Notifier will now be installed"
    echo ""
    plasma5-applets-kde-arch-update-notifier
    echo ""
    echo "Arch Update Notifier has been installed"
    echo ""
    sleep 2

    echo "The starship prompt will now be installed"
    echo ""
    curl -sS https://starship.rs/install.sh | sh
    export STARSHIP_CONFIG=~/.config/starship.toml
    echo ""

# 3 - Personal Repository
# Clone personal repository from Github

    echo "Now cloning your personal repository from Github"
    echo ""
    mkdir -p ~/Git
    cd ~/Git
    git clone https://github.com/anhvo8836/arch
    cd ~
    echo ""
    echo "Your personal repository has been cloned into a folder called 'Git' in your home folder"
    echo ""

# 4 - Create/Update Config Files
# Create a config file for snapper as well as update newly created Starship prompt and Fish
# config files with ones from personal repository

    echo "Your Fish and Starship prompt config files are now being updated"
    echo ""
    touch ~/.config/starship.toml
    cat ~/Git/arch/configs/starship.toml > ~/.config/starship.toml
    cat ~/Git/arch/configs/config.fish > ~/.config/fish/config.fish
    sleep 2

    echo "One moment while a config file for Snapper is created"
    snapper -c root create-config /
    sleep 2

# 5 - Pacman Hooks
# Copy pacman hooks folder from personal repository to the appropriate location on the
# system (/etc/pacman.d)

    echo "One moment while we copy over your pacman hooks..."
    echo ""
    sudo -s mkdir -p /etc/pacman.d/hooks
    sudo -s cp -r ~/Git/arch/hooks /etc/pacman.d

# End Screen

echo "==| FINISHED |=="
echo ""
echo "The post-install script has completed"
echo "The script will now exit and the system will be rebooted for all changes to take affect"
echo ""
echo "Rebooting in 5s...";sleep 1
echo "Rebooting in 4s...";sleep 1
echo "Rebooting in 3s...";sleep 1
echo "Rebooting in 2s...";sleep 1
echo "Rebooting in 1s...";sleep 1
clear;reboot
