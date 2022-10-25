#!/bin/sh

# This script will create a work folder and an out for folder for the building process.
# It will build an Arch ISO based on a pre-configured releng profile and place an ISO
# file in the out folder once completed

    clear

    echo "==| ARCHISO |=="
    echo ""
    echo "Which profile do you want to build?"
    echo ""
    echo "1) Releng"
    echo "2) Test"
    echo ""
    echo -ne '> ';read profile
    echo ""
    read -p "Press enter to begin building the ISO"
    echo ""

    echo "[===================================]"
    echo ""
    mkdir -p ~/work

    case $profile in

    1)

        echo "Profile : Releng"
        echo ""
        echo "Enter your password to start the building process"
        echo ""
        sudo mkarchiso -v -w ~/work -o ~/ISOs ~/personal/iso/releng

    ;;

    2)

        echo "Profile : Test"
        echo ""
        echo "Enter your password to start the building process"
        echo ""
        sudo mkarchiso -v -w ~/work -o ~/ISOs ~/personal/iso/test

    ;;

    esac

    echo ""
    echo "The build process has completed"
    echo ""
    echo "[===================================]"
    echo ""

    echo "Enter your password to start the clean up process"
    echo ""
    yay -Scc
    echo ""
    echo "Please wait while the work folder is removed"
    sudo rm -rf ~/work
    echo ""

    echo "==| FINISHED |=="
    echo ""
    read -p "Press enter to exit"
    clear
