#!/bin/bash

# Function to create big ASCII art
create_ascii_art() {
    local text="$1"
    local style="$2"
    figlet -f "$style" "$text"
}

# Check if figlet is installed
if ! command -v figlet &> /dev/null; then
    echo "figlet is not installed. Installing..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y figlet
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm figlet
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y figlet
    else
        echo "Unable to install figlet. Please install it manually and run this script again."
        exit 1
    fi
fi

# Array of available styles
styles=("standard" "slant" "banner" "big" "small" "script" "shadow")

# Prompt user for input
echo "Enter the text you want to convert to ASCII art:"
read user_input

# Prompt user for style
echo "Choose a style for your ASCII art:"
select style in "${styles[@]}"; do
    if [[ -n $style ]]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Create ASCII art
ascii_art=$(create_ascii_art "$user_input" "$style")

# Display ASCII art
echo "$ascii_art"

# Ask if user wants to save the ASCII art to a file
echo "Do you want to save the ASCII art to a file? (y/n)"
read save_choice

if [[ $save_choice == "y" || $save_choice == "Y" ]]; then
    echo "Enter the filename to save the ASCII art:"
    read filename
    echo "$ascii_art" > "$filename"
    echo "ASCII art saved to $filename"
    echo "Thanks for using Tech Logicals ASCII Art Generator!" 
fi
