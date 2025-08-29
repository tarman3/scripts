#! /bin/bash

# yay -Ps

RED='\033[0;31m'
NC='\033[0m'

echo -e "\n${RED}Clean /var/cache/pacman/pkg${NC}"
sudo rm --recursive --force /var/cache/pacman/pkg/download*


echo -e "\n${RED}Remove all cached packages${NC}"
# sudo pacman -Scc
sudo rm --force /var/cache/pacman/pkg/*
sudo rm --recursive --force /home/user/.cache/yay/*

# echo -e "\n${RED}Remove all the cached packages that are not currently installed${NC}"
# sudo pacman -Sc --noconfirm
yay -Sc --noconfirm


# echo -e "\n${RED}Deletes all cached versions of installed and uninstalled packages, except  one past version${NC}"
# sudo paccache -rk1


echo -e "\n${RED}Update packages${NC}"
# sudo pacman -Syu
# systemd-inhibit --what=idle:sleep yay -Syu --noconfirm
mkdir -p /tmp/yay-cache
kde-inhibit --power --screenSaver yay -Syu --noconfirm --cachedir '/tmp/yay-cache'


echo -e "\n${RED}-------------------"
read -p "Press Enter to exit"
