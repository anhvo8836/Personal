#!/bin/sh

clear

echo "==| SYSTEM MAINTENANCE |=="
echo ""
read -p "Press enter to begin"
echo ""
echo "[=================================================]"
echo ""

# 1. Update System
# Update all of the repository databases and upgrade any
# packages that need upgrading

    echo "The system will now be updated"
    echo ""
    yay -Syyu
    echo ""
    echo "The system has been updated"
    echo ""
    echo "[=================================================]"
    echo ""

# 2. Clean Orphans
# Search the system for any orphan packages (packages not needed
# by any other package) remove any that are found

    echo "Now checking for any orphan packages"
    echo "Any orphan packages found will be removed"
    echo ""
    yay -Qttdq | yay -Rns -
    echo ""
    echo "[=================================================]"
    echo ""

# 3. Clean Package Cache
# Clean out the Pacman package cache to reclaim hard drive

    echo "Enter y to the following prompts to clean out your package cache"
    echo ""
    yay -Scc
    echo ""
    echo "[=================================================]"
    echo ""

# 4. Update Git Repositories
# Update and push all git repositories to their remotes

echo "==| FINISHED |=="
echo ""
echo "Your repository databases and system packages have been updated"
echo "Orphan packages have been identified and removed"
echo "Your package cache has been cleared"
echo ""
read -p "Press enter to exit"
clear

