#!/bin/bash

# Script to install NVIDIA support on Arch Linux and configure bootloader

# Update the system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install required packages
echo "Installing NVIDIA drivers and utilities..."
sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

# Install optional packages for CUDA support (uncomment if needed)
# sudo pacman -S --noconfirm cuda

# Enable early loading of NVIDIA modules
echo "Enabling early loading of NVIDIA modules..."
sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

# Regenerate initramfs
echo "Regenerating initramfs..."
sudo mkinitcpio -P

# Create Xorg configuration file
echo "Creating Xorg configuration file..."
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/20-nvidia.conf > /dev/null <<EOT
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    Option "NoLogo" "true"
EndSection
EOT

# Enable NVIDIA DRM kernel mode setting
echo "Enabling NVIDIA DRM kernel mode setting..."

# Detect and configure bootloader
if [ -d "/boot/grub" ]; then
    echo "Detected GRUB. Updating GRUB configuration..."
    sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ nvidia-drm.modeset=1"/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
elif [ -d "/boot/loader" ]; then
    echo "Detected systemd-boot. Updating kernel parameters..."
    for conf in /boot/loader/entries/*.conf; do
        if ! grep -q "nvidia-drm.modeset=1" "$conf"; then
            sudo sed -i '/^options/ s/$/ nvidia-drm.modeset=1/' "$conf"
        fi
    done
elif [ -f "/boot/efi/EFI/refind/refind.conf" ]; then
    echo "Detected rEFInd. Updating kernel parameters..."
    if ! grep -q "nvidia-drm.modeset=1" /boot/efi/EFI/refind/refind.conf; then
        sudo sed -i '/^"Boot with standard options"/ s/"$/ nvidia-drm.modeset=1"/' /boot/efi/EFI/refind/refind.conf
    fi
elif [ -f "/boot/syslinux/syslinux.cfg" ]; then
    echo "Detected SYSLINUX. Updating kernel parameters..."
    if ! grep -q "nvidia-drm.modeset=1" /boot/syslinux/syslinux.cfg; then
        sudo sed -i '/^APPEND/ s/$/ nvidia-drm.modeset=1/' /boot/syslinux/syslinux.cfg
    fi
else
    echo "Unknown bootloader detected. Please manually add 'nvidia-drm.modeset=1' to your kernel parameters."
fi

echo "NVIDIA support installation complete. Please reboot your system."


