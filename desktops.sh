#!/bin/bash

# Function to detect GPU and install appropriate drivers
install_gpu_drivers() {
    echo "Detecting GPU..."
    if lspci | grep -i nvidia > /dev/null; then
        echo "NVIDIA GPU detected. Installing NVIDIA drivers..."
        if command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm nvidia nvidia-utils
        elif command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y nvidia-driver
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y akmod-nvidia
        else
            echo "Unsupported package manager. Please install NVIDIA drivers manually."
        fi
    elif lspci | grep -i amd > /dev/null; then
        echo "AMD GPU detected. Installing AMD drivers..."
        if command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm xf86-video-amdgpu
        elif command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y xserver-xorg-video-amdgpu
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y xorg-x11-drv-amdgpu
        else
            echo "Unsupported package manager. Please install AMD drivers manually."
        fi
    else
        echo "Intel GPU detected. Installing Intel drivers..."
        if command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm xf86-video-intel
        elif command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y xserver-xorg-video-intel
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y xorg-x11-drv-intel
        else
            echo "Unsupported package manager. Please install Intel drivers manually."
        fi
    fi
}

# Function to install desktop environment
install_de() {
    local de=$1
    echo "Installing $de..."
    case $de in
        "GNOME")
            if command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm gnome gnome-extra
            elif command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y gnome gnome-shell ubuntu-gnome-desktop
            elif command -v dnf &> /dev/null; then
                sudo dnf groupinstall -y "GNOME Desktop Environment"
            else
                echo "Unsupported package manager. Please install GNOME manually."
            fi
            ;;
        "KDE Plasma")
            if command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm plasma kde-applications
            elif command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y kde-plasma-desktop
            elif command -v dnf &> /dev/null; then
                sudo dnf groupinstall -y "KDE Plasma Workspaces"
            else
                echo "Unsupported package manager. Please install KDE Plasma manually."
            fi
            ;;
        "Xfce")
            if command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm xfce4 xfce4-goodies
            elif command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y xfce4 xfce4-goodies
            elif command -v dnf &> /dev/null; then
                sudo dnf groupinstall -y "Xfce Desktop"
            else
                echo "Unsupported package manager. Please install Xfce manually."
            fi
            ;;
        "MATE")
            if command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm mate mate-extra
            elif command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y mate-desktop-environment mate-desktop-environment-extras
            elif command -v dnf &> /dev/null; then
                sudo dnf groupinstall -y "MATE Desktop"
            else
                echo "Unsupported package manager. Please install MATE manually."
            fi
            ;;
        "Cinnamon")
            if command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm cinnamon
            elif command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y cinnamon-desktop-environment
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y @cinnamon-desktop-environment
            else
                echo "Unsupported package manager. Please install Cinnamon manually."
            fi
            ;;
        "Hyprland")
            if command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm hyprland kitty waybar wofi
            elif command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y meson wget build-essential ninja-build cmake-extras cmake gettext gettext-base fontconfig libfontconfig-dev libffi-dev libxml2-dev libdrm-dev libxkbcommon-x11-dev libxkbregistry-dev libxkbcommon-dev libpixman-1-dev libudev-dev libseat-dev seatd libxcb-dri3-dev libvulkan-dev libvulkan-volk-dev vulkan-validationlayers-dev libvkfft-dev libgulkan-dev libegl-dev libgles2 libegl1-mesa-dev glslang-tools libinput-bin libinput-dev libxcb-composite0-dev libavutil-dev libavcodec-dev libavformat-dev libxcb-ewmh2 libxcb-ewmh-dev libxcb-present-dev libxcb-icccm4-dev libxcb-render-util0-dev libxcb-res0-dev libxcb-xinput-dev
                git clone https://github.com/hyprwm/Hyprland
                cd Hyprland
                meson build
                ninja -C build
                sudo ninja -C build install
                cd ..
                rm -rf Hyprland
            elif command -v dnf &> /dev/null; then
                sudo dnf copr enable solopasha/hyprland
                sudo dnf install hyprland
            else
                echo "Unsupported package manager. Please install Hyprland manually."
            fi
            ;;
        "DWM")
            if command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm base-devel libx11 libxft libxinerama freetype2 fontconfig
                git clone https://git.suckless.org/dwm
                cd dwm
                sudo make clean install
                cd ..
                rm -rf dwm
            elif command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y build-essential libx11-dev libxft-dev libxinerama-dev libfreetype6-dev libfontconfig1-dev
                git clone https://git.suckless.org/dwm
                cd dwm
                sudo make clean install
                cd ..
                rm -rf dwm
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y base-devel libX11-devel libXft-devel libXinerama-devel freetype-devel fontconfig-devel
                git clone https://git.suckless.org/dwm
                cd dwm
                sudo make clean install
                cd ..
                rm -rf dwm
            else
                echo "Unsupported package manager. Please install DWM manually."
            fi
            ;;
    esac
}

# Install GPU drivers
install_gpu_drivers

# Array of desktop environments
options=("GNOME" "KDE Plasma" "Xfce" "MATE" "Cinnamon" "Hyprland" "DWM" "Quit")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Menu function
menu() {
    echo -e "${YELLOW}Select a desktop environment to install:${NC}"
    for i in ${!options[@]}; do
        if [[ ${options[i]} == $1 ]]; then
            echo -e "${GREEN}> ${options[i]}${NC}"
        else
            case $i in
                0) echo -e "${RED}  ${options[i]}${NC}";;
                1) echo -e "${BLUE}  ${options[i]}${NC}";;
                2) echo -e "${MAGENTA}  ${options[i]}${NC}";;
                3) echo -e "${CYAN}  ${options[i]}${NC}";;
                4) echo -e "${YELLOW}  ${options[i]}${NC}";;
                5) echo -e "${GREEN}  ${options[i]}${NC}";;
                6) echo -e "${BLUE}  ${options[i]}${NC}";;
                7) echo -e "${RED}  ${options[i]}${NC}";;
            esac
        fi
    done
}

# Initialize selection
select=0

# Capture key presses
while true; do
    # Clear screen and show menu
    clear
    menu "${options[select]}"

    # Capture key press
    read -rsn1 key

    # Handle key press
    case "$key" in
        A) ((select > 0)) && ((select--));;  # Up arrow
        B) ((select < ${#options[@]}-1)) && ((select++));;  # Down arrow
        '') 
            if [[ "${options[select]}" == "Quit" ]]; then
                break
            else
                install_de "${options[select]}"
                read -p "Press enter to continue..."
            fi
            ;;
    esac
done

# Rainbow text function
rainbow_echo() {
    text="$1"
    colors=("\033[38;5;196m" "\033[38;5;202m" "\033[38;5;226m" "\033[38;5;082m" "\033[38;5;021m" "\033[38;5;093m")
    for (( i=0; i<${#text}; i++ )); do
        color_index=$((i % ${#colors[@]}))
        echo -en "${colors[$color_index]}${text:$i:1}"
    done
    echo -e "$NC"
}

rainbow_echo "Thank you for using the Desktop Environment Installer! by TechLogicals"




