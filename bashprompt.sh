y#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install required packages
install_packages() {
    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y curl
    elif command_exists pacman; then
        sudo pacman -Syu --noconfirm curl
    elif command_exists dnf; then
        sudo dnf install -y curl
    else
        echo "Unsupported package manager. Please install curl manually."
        exit 1
    fi
}

# Install Starship
install_starship() {
    if ! command_exists starship; then
        echo "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh
    else
        echo "Starship is already installed."
    fi
}

# Install Zoxide
install_zoxide() {
    if ! command_exists zoxide; then
        echo "Installing Zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    else
        echo "Zoxide is already installed."
    fi
}

# Configure Starship
configure_starship() {
    mkdir -p ~/.config
    cat > ~/.config/starship.toml << EOL
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

[directory]
style = "blue"

[git_branch]
symbol = "🌱 "
style = "green"

[git_status]
style = "red"

[time]
disabled = false
format = '🕙[\[ $time \]]($style) '
time_format = "%T"
style = "grey"

[cmd_duration]
min_time = 500
format = "⏱️ [$duration]($style) "
style = "yellow"

[battery]
full_symbol = "🔋"
charging_symbol = "🔌"
discharging_symbol = "⚡"

[[battery.display]]
threshold = 30
style = "bold red"

[package]
symbol = "📦 "

[rust]
symbol = "🦀 "

[python]
symbol = "🐍 "

[nodejs]
symbol = "⬢ "

[memory_usage]
symbol = "🧠 "
disabled = false
threshold = -1
style = "bold dimmed green"

[aws]
symbol = "🅰 "

[docker_context]
symbol = "🐳 "

[kubernetes]
symbol = "☸ "
EOL
}

# Configure shell (Bash or Zsh)
configure_shell() {
    if [ -n "$BASH_VERSION" ]; then
        config_file="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        config_file="$HOME/.zshrc"
    else
        echo "Unsupported shell. Please use Bash or Zsh."
        exit 1
    fi

    # Add Starship init
    echo 'eval "$(starship init $SHELL)"' >> "$config_file"

    # Add Zoxide init and alias
    echo 'eval "$(zoxide init $SHELL)"' >> "$config_file"
    echo 'alias cd="z"' >> "$config_file"

    # Enable autocompletion
    echo 'if [ -f /usr/share/bash-completion/bash_completion ]; then' >> "$config_file"
    echo '    . /usr/share/bash-completion/bash_completion' >> "$config_file"
    echo 'elif [ -f /etc/bash_completion ]; then' >> "$config_file"
    echo '    . /etc/bash_completion' >> "$config_file"
    echo 'fi' >> "$config_file"

    echo "Shell configuration updated. Please restart your shell or source $config_file"
}

# Main execution
install_packages
install_starship
install_zoxide
configure_starship
configure_shell

echo -e "\e[38;5;196mS\e[38;5;202me\e[38;5;226mt\e[38;5;082mu\e[38;5;021mp\e[38;5;093m \e[38;5;196mc\e[38;5;202mo\e[38;5;226mm\e[38;5;082mp\e[38;5;021ml\e[38;5;093me\e[38;5;196mt\e[38;5;202me\e[38;5;226m!\e[38;5;082m \e[38;5;021mE\e[38;5;093mn\e[38;5;196mj\e[38;5;202mo\e[38;5;226my\e[38;5;082m \e[38;5;021my\e[38;5;093mo\e[38;5;196mu\e[38;5;202mr\e[38;5;226m \e[38;5;082mn\e[38;5;021me\e[38;5;093mw\e[38;5;196m \e[38;5;202mc\e[38;5;226mo\e[38;5;082ml\e[38;5;021mo\e[38;5;093mr\e[38;5;196mf\e[38;5;202mu\e[38;5;226ml\e[38;5;082m \e[38;5;021mp\e[38;5;093mr\e[38;5;196mo\e[38;5;202mm\e[38;5;226mp\e[38;5;082mt\e[38;5;021m \e[38;5;093mw\e[38;5;196mi\e[38;5;202mt\e[38;5;226mh\e[38;5;082m \e[38;5;021mt\e[38;5;093mi\e[38;5;196mm\e[38;5;202me\e[38;5;226m \e[38;5;082md\e[38;5;021mi\e[38;5;093ms\e[38;5;196mp\e[38;5;202ml\e[38;5;226ma\e[38;5;082my\e[38;5;021m \e[38;5;093ma\e[38;5;196mn\e[38;5;202md\e[38;5;226m \e[38;5;082me\e[38;5;021mn\e[38;5;093mh\e[38;5;196ma\e[38;5;202mn\e[38;5;226mc\e[38;5;082me\e[38;5;021md\e[38;5;093m \e[38;5;196mn\e[38;5;202ma\e[38;5;226mv\e[38;5;082mi\e[38;5;021mg\e[38;5;093ma\e[38;5;196mt\e[38;5;202mi\e[38;5;226mo\e[38;5;082mn\e[38;5;021m!\e[38;5;093m \e[38;5;196mb\e[38;5;202my\e[38;5;226m \e[38;5;082mT\e[38;5;021me\e[38;5;093mc\e[38;5;196mh\e[38;5;202mL\e[38;5;226mo\e[38;5;082mg\e[38;5;021mi\e[38;5;093mc\e[38;5;196ma\e[38;5;202ml\e[38;5;226ms\e[0m"
