#!/bin/bash
# Function to get available drives
get_available_drives() {
    lsblk -ndo NAME,SIZE,TYPE | awk '$3=="disk" {print "/dev/"$1" ("$2")"}'
}

# Function to install base Arch Linux
install_base_arch() {
    print_message "$BLUE" "Installing base Arch Linux..."

    # Select installation drive
    mapfile -t drives < <(get_available_drives)
    drives+=("Back to main menu")
    display_colored_menu "Select installation drive:" "${drives[@]}"
    drive_choice=$?

    if [ $drive_choice -eq ${#drives[@]}-1 ]; then
        return
    fi

    selected_drive=$(echo "${drives[$drive_choice]}" | cut -d' ' -f1)
    print_message "$BLUE" "Selected drive: $selected_drive"

    # Get user input for various settings
    read -p "Enter desired hostname: " hostname
    read -p "Enter desired username: " username
    read -s -p "Enter password for $username: " user_password
    echo
    read -s -p "Enter root password: " root_password
    echo

    # Get region/timezone
    read -p "Enter your timezone (e.g., America/New_York): " timezone

    # Get keyboard layout
    read -p "Enter your keyboard layout (e.g., us): " keyboard_layout

    # Update system clock
    timedatectl set-ntp true

    # Partition the disk
    parted $selected_drive mklabel gpt
    parted $selected_drive mkpart ESP fat32 1MiB 513MiB
    parted $selected_drive set 1 esp on
    parted $selected_drive mkpart primary ext4 513MiB 100%

    # Format the partitions
    mkfs.fat -F32 "${selected_drive}1"
    mkfs.ext4 "${selected_drive}2"

    # Mount the file systems
    mount "${selected_drive}2" /mnt
    mkdir /mnt/boot
    mount "${selected_drive}1" /mnt/boot

    # Install base packages and additional networking tools
    pacstrap /mnt base base-devel linux linux-firmware efibootmgr networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober mtools dosfstools git python

    # Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab

    # Create a setup script to run inside the chroot environment
    cat > /mnt/setup.sh <<EOF
#!/bin/bash
# Set time zone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

# Set locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set keyboard layout
echo "KEYMAP=$keyboard_layout" > /etc/vconsole.conf

# Set hostname
echo "$hostname" > /etc/hostname

# Set root password
echo "root:$root_password" | chpasswd

# Create new user and add to sudo group
useradd -m -G wheel -s /bin/bash $username
echo "$username:$user_password" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Install and configure bootloader (systemd-boot)
bootctl install
echo "default arch" > /boot/loader/loader.conf
echo "timeout 3" >> /boot/loader/loader.conf
echo "editor 0" >> /boot/loader/loader.conf
echo "title Arch Linux" > /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value ${selected_drive}2) rw" >> /boot/loader/entries/arch.conf

# Enable NetworkManager
systemctl enable NetworkManager
EOF

    # Make the setup script executable
    chmod +x /mnt/setup.sh

    # Run the setup script in the chroot environment
    arch-chroot /mnt /setup.sh

    # Remove the setup script
    rm /mnt/setup.sh

    print_message "$GREEN" "Base Arch Linux installation completed with EFI boot and networking setup."
    print_message "$YELLOW" "Please reboot your system to complete the installation."
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to display a colored menu
display_colored_menu() {
    local prompt=$1
    shift
    local options=("$@")
    local selected=0

    tput civis  # Hide cursor

    while true; do
        clear
        print_message "$BLUE" "$prompt"
        echo

        for i in "${!options[@]}"; do
            if [ $i -eq $selected ]; then
                print_message "$GREEN" "> ${options[$i]}"
            else
                echo "  ${options[$i]}"
            fi
        done

        read -rsn1 key
        case "$key" in
            A) ((selected > 0)) && ((selected--)) ;;
            B) ((selected < ${#options[@]} - 1)) && ((selected++)) ;;
            '') break ;;
        esac
    done

    tput cnorm  # Show cursor

    return $selected
}

# Function to get available drives
get_available_drives() {
    lsblk -ndo NAME,SIZE,TYPE | awk '$3=="disk" {print "/dev/"$1" ("$2")"}'
}

# Function to install base Arch Linux
install_base_arch() {
    print_message "$BLUE" "Installing base Arch Linux..."

    # Select installation drive
    mapfile -t drives < <(get_available_drives)
    drives+=("Back to main menu")
    display_colored_menu "Select installation drive:" "${drives[@]}"
    drive_choice=$?

    if [ $drive_choice -eq ${#drives[@]}-1 ]; then
        return
    fi

    selected_drive=$(echo "${drives[$drive_choice]}" | cut -d' ' -f1)
    print_message "$BLUE" "Selected drive: $selected_drive"

    # Get user input for various settings
    read -p "Enter desired hostname: " hostname
    read -p "Enter desired username: " username
    read -s -p "Enter password for $username: " user_password
    echo
    read -s -p "Enter root password: " root_password
    echo

    # Get region/timezone
    read -p "Enter your timezone (e.g., America/New_York): " timezone

    # Get keyboard layout
    read -p "Enter your keyboard layout (e.g., us): " keyboard_layout

    # Update system clock
    timedatectl set-ntp true

    # Partition the disk
    parted $selected_drive mklabel gpt
    parted $selected_drive mkpart ESP fat32 1MiB 513MiB
    parted $selected_drive set 1 esp on
    parted $selected_drive mkpart primary ext4 513MiB 100%

    # Format the partitions
    mkfs.fat -F32 "${selected_drive}1"
    mkfs.ext4 "${selected_drive}2"

    # Mount the file systems
    mount "${selected_drive}2" /mnt
    mkdir /mnt/boot
    mount "${selected_drive}1" /mnt/boot

    # Install base packages and additional networking tools
    pacstrap /mnt base base-devel linux linux-firmware efibootmgr networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober mtools dosfstools git python

    # Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab

    # Create a setup script to run inside the chroot environment
    cat > /mnt/setup.sh <<EOF
#!/bin/bash
# Set time zone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

# Set locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set keyboard layout
echo "KEYMAP=$keyboard_layout" > /etc/vconsole.conf

# Set hostname
echo "$hostname" > /etc/hostname

# Set root password
echo "root:$root_password" | chpasswd

# Create new user and add to sudo group
useradd -m -G wheel -s /bin/bash $username
echo "$username:$user_password" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Install and configure bootloader (systemd-boot)
bootctl install
echo "default arch" > /boot/loader/loader.conf
echo "timeout 3" >> /boot/loader/loader.conf
echo "editor 0" >> /boot/loader/loader.conf
echo "title Arch Linux" > /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value ${selected_drive}2) rw" >> /boot/loader/entries/arch.conf

# Enable NetworkManager
systemctl enable NetworkManager
EOF

    # Make the setup script executable
    chmod +x /mnt/setup.sh

    # Run the setup script in the chroot environment
    arch-chroot /mnt /setup.sh

    # Remove the setup script
    rm /mnt/setup.sh

    print_message "$GREEN" "Base Arch Linux installation completed with EFI boot and networking setup."
    print_message "$YELLOW" "Please reboot your system to complete the installation."
}

# Main menu options
main_options=(
    "Install base Arch Linux"
    "Exit"
)

# Main loop
while true; do
    display_colored_menu "Arch Linux Installation Menu" "${main_options[@]}"
    choice=$?

    case $choice in
        0)
            install_base_arch
            ;;
        1)
            print_message "$YELLOW" "Exiting..."
            exit 0
            ;;
    esac

    print_message "$YELLOW" "Press any key to continue..."
    read -n 1 -s
done
