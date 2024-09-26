#!/bin/bash

# Check if yay is installed
yay_check() {
    if command -v yay &> /dev/null; then
        echo -e "\e[1;32m:: yay is already installed. Skipping installation...\e[0m"
        return 0
    else
        return 1
    fi
}

# Configure sudo to cache the password
sudo_cache() {
    echo -e "\e[1;32m:: Configuring sudo to cache the password... [1/12]\e[0m"
    echo "Defaults timestamp_timeout=120" | sudo tee -a /etc/sudoers.d/password_timeout
}

# Install Chaotic AUR
chaotic_aur() {
    echo -e "\e[1;32m:: Installing Chaotic AUR... [2/12]\e[0m"
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    echo "[chaotic-aur]" | sudo tee -a /etc/pacman.conf
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

    # Check and enable multilib repository if not already enabled
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo -e "\e[1;32m:: Enabling multilib repository...\e[0m"
        sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
    fi
}

# Install yay AUR helper
yay_install() {
    if yay_check; then
        return
    fi

    echo -e "\e[1;32m:: Installing yay AUR helper... [3/12]\e[0m"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd .. 
    rm -rf yay
}

# Install packages from the package list
pkg_install() {
    echo -e "\e[1;32m:: Installing packages... [4/12]\e[0m"
    if [ ! -f packages ]; then
        echo -e "\e[1;31mError: packages not found. Attempting to download from remote...\e[0m"
        curl -o packages "https://raw.githubusercontent.com/xangelkawaiix/hyprland-bootstrap/main/packages"
        if [ $? -ne 0 ]; then
            echo -e "\e[1;31mError: Failed to download packages from remote.\e[0m"
            exit 1
        fi
    fi

    # Install packages listed in packages.txt
    yay -S --needed --noconfirm $(cat packages)
}

# Clone dotfiles repository
dotfiles_clone() {
    echo -e "\e[1;32m:: Cloning dotfiles repository... [5/12]\e[0m"
    REPO_NAME=$(basename -s .git https://github.com/xangelkawaiix/hyprland-dotfiles)
    git clone https://github.com/xangelkawaiix/hyprland-dotfiles.git "$REPO_NAME"
    cd "$REPO_NAME"
}

# Copy configuration files and folders
configs_copy() {
    echo -e "\e[1;32m:: Copying configuration files and folders... [6/12]\e[0m"
    cp -r .config/* ~/.config/
    echo -e "\e[1;34mCopying .config/* -> ~/.config/\e[0m"
    cp -r .local/bin/* ~/.local/bin/
    echo -e "\e[1;34mCopying .local/bin/* -> ~/.local/bin/\e[0m"

    # Create soft links for .profile, .zshenv, and .zshrc
    ln -sf ~/.config/shell/profile ~/.profile
    ln -sf ~/.config/zsh/.zshenv ~/.zshenv
    ln -sf ~/.config/zsh/.zshrc ~/.zshrc
    ln -sf ~/.config/zsh/.zprofile ~/.zprofile
}

# Create user folders using xdg-user-dirs-update
user_dirs() {
    echo -e "\e[1;32m:: Creating user directories... [7/12]\e[0m"
    xdg-user-dirs-update
}

# Configure Arch Linux mirror list
mirrors_config() {
    echo -e "\e[1;32m:: Configuring Arch Linux mirror list... [8/12]\e[0m"
    sudo reflector --latest 100 --protocol https --protocol http --sort rate --save /etc/pacman.d/mirrorlist
    echo -e "\e[1;32mMirror list updated.\e[0m"
}

# Set timedatectl for Windows dual boot
timedatectl_set() {
    echo -e "\e[1;32m:: Setting timedatectl for Windows dual boot... [9/12]\e[0m"
    sudo timedatectl set-local-rtc 1
}

# Configure gpg-agent
gpg_config() {
    echo -e "\e[1;32m:: Configuring gpg-agent... [10/12]\e[0m"
    mkdir -p ~/.gnupg
    yay -S --needed --noconfirm pinentry-qt
    echo "pinentry-program /usr/bin/pinentry-qt" | tee ~/.gnupg/gpg-agent.conf
    echo "max-cache-ttl 60480000" | tee -a ~/.gnupg/gpg-agent.conf
    echo "default-cache-ttl 60480000" | tee -a ~/.gnupg/gpg-agent.conf
}

# Change shell to zsh and install starship
zsh_starship() {
    echo -e "\e[1;32m:: Changing shell to zsh... [11/12]\e[0m"
    chsh -s /bin/zsh
    echo -e "\e[1;32m:: Installing starship...\e[0m"
    sh -c "$(curl -fsSL https://starship.rs/install.sh)"
}

# Run os-prober
os_prober_run() {
    echo -e "\e[1;32m:: Running os-prober... [12/12]\e[0m"
    sudo os-prober
}

# GRUB theme configuration
grub_theme_setup() {
    echo -e "\e[1;33m:: Notice :: GRUB only supports 1080p and up for theme display.\e[0m"
    read -p "Are you using GRUB? (yes/no): " grub_use
    if [[ "$grub_use" != "yes" ]]; then
        echo -e "\e[1;32mSkipping GRUB theme configuration.\e[0m"
        return
    fi

    echo -e "\e[1;32m:: Starting GRUB theme setup.\e[0m"
    echo "1. Elegant"
    echo "2. Wuthering Wave"
    read -p "Select theme (1/2): " theme_choice

    case $theme_choice in
        1)
            git clone https://github.com/vinceliuice/Elegant-grub2-themes.git
            cd Elegant-grub2-themes
            read -p "Background theme variant (Default: forest) [forest|mojave|mountain|wave]: " theme
            read -p "Theme style variant (Default: window) [window|float|sharp]: " style
            read -p "Picture display side (Default: left) [left|right]: " side
            read -p "Background color variant (Default: dark) [dark|light]: " color
            read -p "Screen display variant (Default: 1080p) [1080p|2k|4k]: " screen
            read -p "Show a logo on picture (Default: default) [default|system]: " logo
            sudo ./install.sh -b -t "$theme" -p "$style" -i "$side" -c "$color" -s "$screen" -l "$logo"
            cd ..
            rm -rf Elegant-grub2-themes
            ;;
        2)
            git clone https://github.com/vinceliuice/Wuthering-grub2-themes.git
            cd Wuthering-grub2-themes
            read -p "Background theme variant (Default: changli) [changli|jinxi|jiyan|yinlin|anke|weilinai|kakaluo|jianxin]: " theme
            read -p "Screen display variant (Default: 1080p) [1080p|2k|4k]: " screen
            sudo ./install.sh -b -t "$theme" -s "$screen"
            cd ..
            rm -rf Wuthering-grub2-themes
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

# Install powerpill
install_powerpill() {
    echo -e "\e[1;32m:: Installing powerpill... [13/13]\e[0m"
    echo -e "\e[1;33mPowerpill is a pacman wrapper that uses parallel and segmented downloading to try to speed up downloads for Pacman. By default, Powerpill is configured to use Reflector to retrieve the current list of mirrors from the Arch Linux server's web API and use them for parallel downloads. This is to make sure that there are enough servers in the list for significant speed improvements.\e[0m"
    read -p "Do you want to install powerpill? [y/n]: " install_powerpill
    if [[ "$install_powerpill" == "y" ]]; then
        yay -S --needed --noconfirm powerpill
        echo -e "\e[1;32mTo use powerpill, you can type \`sudo powerpill -S\` or \`sudo powerpill -Syu\`\e[0m"
    else
        echo -e "\e[1;32mSkipping powerpill installation.\e[0m"
    fi
}

# Main function
main() {
    sudo_cache           # Step 1: Configure sudo to cache the password
    chaotic_aur          # Step 2: Install Chaotic AUR
    yay_install          # Step 3: Install yay AUR helper
    pkg_install          # Step 4: Install packages
    dotfiles_clone       # Step 5: Clone dotfiles repository
    configs_copy         # Step 6: Copy configuration files and folders
    user_dirs            # Step 7: Create user directories
    mirrors_config       # Step 8: Configure Arch Linux mirror list
    timedatectl_set      # Step 9: Set timedatectl for Windows dual boot
    gpg_config           # Step 10: Configure gpg-agent
    zsh_starship         # Step 11: Change shell to zsh and install starship
    os_prober_run        # Step 12: Run os-prober to detect Windows installation
    grub_theme_setup     # Optional: GRUB theme configuration
    install_powerpill    # Optional: Install powerpill
}

# Execute main function
main
