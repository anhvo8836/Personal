#!/bin/sh

clear

echo "==| UPDATE REPOSITORY |=="
echo ""
read -p "Press enter to begin"
echo ""
echo "[===============================================]"
echo ""

# 1 - Navigate to the repository folder

    cd ~/personal

# 2 - Update the git index

    echo "The Git index will now be updated"
    echo ""
    git add -v .
    echo ""
    echo "[===============================================]"
    echo ""

# 3 - Create a commit

    echo "What would you like your commit message to be?"
    echo -ne '> ';read commit
    echo ""
    git commit -m "$commit"
    echo ""
    echo "[===============================================]"
    echo ""

# 4 - Push to Remote Repository

    echo "The local repository will now be pushed to the remote repository"
    echo ""
    git push origin main

echo ""
echo "[===============================================]"
echo ""
echo "==| FINISHED |=="
echo ""
echo "Your remote repository has been updated and should
be up to date."
echo ""
read -p "Press enter to exit"
clear
