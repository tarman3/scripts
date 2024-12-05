#! /bin/bash

yay -Ps

RED='\033[0;31m'
NC='\033[0m'

echo -e "\n${RED}Remove all the cached packages that are not currently installed${NC}"
# sudo pacman -Sc --noconfirm
yay -Sc --noconfirm

# echo -e "\n${RED}Deletes all cached versions of installed and uninstalled packages, except  one past version${NC}"
# sudo paccache -rk1

echo -e "\n${RED}Update packages${NC}"
# sudo pacman -Syu
yay -Syu --noconfirm

# echo
# read -p "Update AUR packages (N/y)? " check
# if [[ ${check:0:1} == 'y' ]] || [[ ${check:0:1} == 'Y' ]]
#     then
#         yay -Syu
#         echo -e "\n${RED}-------------------"
#         read -p "Press Enter to exit"
# fi


echo -e "\n${RED}-------------------"
read -p "Press Enter to exit"
