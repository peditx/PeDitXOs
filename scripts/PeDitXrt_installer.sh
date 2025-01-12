#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

clear

# Display the banner
echo -e "${RED}
 _______           _______  __   __     __    __            __          
|       \         |       \|  \ |  \   |  \  |  \          |  \         
| ▓▓▓▓▓▓▓\ ______ | ▓▓▓▓▓▓▓\\▓▓_| ▓▓_  | ▓▓  | ▓▓ ______  _| ▓▓_        
| ▓▓__/ ▓▓/      \| ▓▓  | ▓▓  \   ▓▓ \  \▓▓\/  ▓▓/      \|   ▓▓ \       
| ▓▓    ▓▓  ▓▓▓▓▓▓\ ▓▓  | ▓▓ ▓▓\▓▓▓▓▓▓   >▓▓  ▓▓|  ▓▓▓▓▓▓\\▓▓▓▓▓▓       
| ▓▓▓▓▓▓▓| ▓▓    ▓▓ ▓▓  | ▓▓ ▓▓ | ▓▓ __ /  ▓▓▓▓\| ▓▓   \▓▓ | ▓▓ __      
| ▓▓     | ▓▓▓▓▓▓▓▓ ▓▓__/ ▓▓ ▓▓ | ▓▓|  \  ▓▓ \▓▓\ ▓▓       | ▓▓|  \     
| ▓▓      \▓▓     \ ▓▓    ▓▓ ▓▓  \▓▓  ▓▓ ▓▓  | ▓▓ ▓▓        \▓▓  ▓▓     
 \▓▓       \▓▓▓▓▓▓▓\▓▓▓▓▓▓▓ \▓▓   \▓▓▓▓ \▓▓   \▓▓\▓▓         \▓▓▓▓      
                                          I  N  S  T  A  L  L  E  R                                                   
                                                   ${NC}\n"

# Welcome message
echo -e "${GREEN}Welcome to the PeDitXrt Installer for Linux!${NC}\n"
sleep 2

# Display the menu using dialog (available in most Linux distros)
CHOICE=$(dialog --title "PeDitXrt Installer" --menu "Please select the OS you want to install:" 15 60 6 \
"1" "OpenWRT" \
"2" "ImmortalWRT" \
"3" "PeDitXrt" \
"4" "Custom OS" \
"5" "Resizing Partition" \
"6" "MikroTik" 3>&1 1>&2 2>&3)

# Check if the user pressed Cancel or entered an invalid option
if [ $? -ne 0 ]; then
    echo "You have canceled the installation or selected an invalid option."
    exit 1
fi

# Handle the user's choice
case $CHOICE in
    1)
        echo "Installing OpenWrt"
        CPU_ARCH=$(uname -m)
        if [ "$CPU_ARCH" = "x86_64" ]; then
            DOWNLOAD_URL="https://downloads.openwrt.org/releases/23.05.4/targets/x86/64/openwrt-23.05.4-x86-64-generic-ext4-combined-efi.img.gz"
        elif [ "$CPU_ARCH" = "i686" ]; then
            DOWNLOAD_URL="https://downloads.openwrt.org/releases/23.05.4/targets/x86/generic/openwrt-23.05.4-x86-generic-generic-ext4-combined.img.gz"
        else
            echo "Unsupported CPU architecture: $CPU_ARCH"
            exit 1
        fi

        if [ -f "peditx.img.gz" ]; then
            echo "Removing old peditx.img.gz file..."
            rm peditx.img.gz
        fi

        echo "Downloading OpenWrt image..."
        curl -L -o peditx.img.gz "$DOWNLOAD_URL"
        gzip -d peditx.img.gz
        if [ -e "/dev/sda" ]; then
            TARGET_DISK="/dev/sda"
        else
            TARGET_DISK="/dev/vda"
        fi
        echo "Writing OpenWrt image to $TARGET_DISK..."
        dd if=peditx.img of="$TARGET_DISK" bs=4M status=progress
        ;;
    2)
        echo "Installing ImmortalWRT"
        CPU_ARCH=$(uname -m)
        if [ "$CPU_ARCH" = "x86_64" ]; then
            DOWNLOAD_URL="https://downloads.immortalwrt.org/releases/23.05.4/targets/x86/64/immortalwrt-23.05.4-x86-64-generic-ext4-combined.img.gz"
        elif [ "$CPU_ARCH" = "i686" ]; then
            DOWNLOAD_URL="https://downloads.immortalwrt.org/releases/23.05.4/targets/x86/generic/immortalwrt-23.05.4-x86-generic-generic-ext4-combined.img.gz"
        else
            echo "Unsupported CPU architecture: $CPU_ARCH"
            exit 1
        fi
        curl -L -o peditx.img.gz "$DOWNLOAD_URL"
        gzip -d peditx.img.gz
        if [ -e "/dev/sda" ]; then
            dd if=peditx.img of=/dev/sda bs=4M status=progress
        else
            dd if=peditx.img of=/dev/vda bs=4M status=progress
        fi
        ;;
    3)
        echo "Installing PeDitXrt"
        CPU_ARCH=$(uname -m)
        if [ "$CPU_ARCH" = "x86_64" ]; then
            DOWNLOAD_URL="https://github.com/peditx/PeDitXrt/releases/latest/download/PeDitXrt-x86-64-generic-ext4-combined.img.gz"
        elif [ "$CPU_ARCH" = "i686" ];then
            DOWNLOAD_URL="https://github.com/peditx/PeDitXrt/releases/latest/download/PeDitXrt-x86-generic-generic-ext4-combined.img.gz"
        else
            echo "Unsupported CPU architecture: $CPU_ARCH"
            exit 1
        fi
        curl -L -o peditx.img.gz "$DOWNLOAD_URL"
        gzip -d peditx.img.gz
        if [ -e "/dev/sda" ]; then
            dd if=peditx.img of=/dev/sda bs=4M status=progress
        else
            dd if=peditx.img of=/dev/vda bs=4M status=progress
        fi
        ;;
    4)
        echo "Installing Custom OS"
        read -p "Please insert the link: " link
        curl -L -o peditx.img.gz "$link"
        gzip -d peditx.img.gz
        if [ -e "/dev/sda" ]; then
            dd if=peditx.img of=/dev/sda bs=4M status=progress
        else
            dd if=peditx.img of=/dev/vda bs=4M status=progress
        fi
        ;;
    5)
        echo "Resizing Partition 2"
        read -p "Enter the size of partition 2 (in GB): " size
        echo "Resizing partition 2..."
        parted /dev/sda resizepart 2 "${size}GB"
        echo "Resizing file system of partition 2..."
        resize2fs /dev/sda2
        echo "Ok done! Thank you for using PeDitXrt installer. Subscribe to us on YouTube/Instagram/Telegram/Twitter @peditx"
        echo "Unmounting the USB flash drive..."
        umount /dev/sdb
        echo "Rebooting the system in 5 seconds..."
        sleep 5
        reboot
        ;;
    6)
        echo "Installing MikroTik PeDitX Mode"
        wget https://download.mikrotik.com/routeros/7.8/chr-7.8.img.zip -O chr.img.zip
        gunzip -c chr.img.zip > chr.img
        echo u > /proc/sysrq-trigger
        dd if=chr.img bs=1024 of=/dev/sda
        echo "sync disk"
        echo s > /proc/sysrq-trigger
        sleep 5
        echo "Ok, reboot"
        echo b > /proc/sysrq-trigger
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

exit 0
