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
    echo -e "\e[1;32m:: Configuring sudo to cache the password... [1/11]\e[0m"
    echo "Defaults timestamp_timeout=120" | sudo tee -a /etc/sudoers.d/password_timeout
}

# Install yay AUR helper
yay_install() {
    if yay_check; then
        return
    fi

    echo -e "\e[1;32m:: Installing yay AUR helper... [2/11]\e[0m"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd .. 
    rm -rf yay
}

# Install packages from the package list
pkg_install() {
    echo -e "\e[1;32m:: Installing packages... [3/11]\e[0m"
    if [ ! -f packages ]; then
        echo -e "\e[1;31mError: packages not found. Attempting to download from remote...\e[0m"
        curl -o packages.txt "https://raw.githubusercontent.com/xangelkawaiix/hyperland-bootstrap/main/packages"
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
    echo -e "\e[1;32m:: Cloning dotfiles repository... [4/11]\e[0m"
    REPO_NAME=$(basename -s .git https://github.com/xangelkawaiix/hyprland-dotfiles)
    git clone https://github.com/xangelkawaiix/hyprland-dotfiles.git "$REPO_NAME"
    cd "$REPO_NAME"
}

# Copy configuration files and folders
configs_copy() {
    echo -e "\e[1;32m:: Copying configuration files and folders... [5/11]\e[0m"
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
    echo -e "\e[1;32m:: Creating user directories... [6/11]\e[0m"
    xdg-user-dirs-update
}

# Configure Arch Linux mirror list
mirrors_config() {
    while true; do
        read -p "Do you want to configure the Arch Linux mirror list? (y/n): " response
        case $response in
            [Yy]* )
                echo -e "\e[1;32m:: Configuring Arch Linux mirror list... [7/11]\e[0m"
                sudo reflector --latest 100 --protocol https --protocol http --sort rate --save /etc/pacman.d/mirrorlist
                echo -e "\e[1;32mMirror list updated.\e[0m"
                break;;
            [Nn]* )
                echo -e "\e[1;32mSkipping mirror list configuration.\e[0m"
                break;;
            * )
                echo -e "\e[1;31mInvalid input. Please answer with 'y' or 'n'.\e[0m";;
        esac
    done
}

# Set timedatectl for Windows dual boot
timedatectl_set() {
    while true; do
        read -p "Do you want to set timedatectl for Windows dual boot? (y/n): " response
        case $response in
            [Yy]* )
                sudo timedatectl set-local-rtc 1
                echo -e "\e[1;32mTimedatectl set for Windows dual boot.[8/11]\e[0m"
                break;;
            [Nn]* )
                echo -e "\e[1;32mSkipping timedatectl configuration.\e[0m"
                break;;
            * )
                echo -e "\e[1;31mInvalid input. Please answer with 'y' or 'n'.\e[0m";;
        esac
    done
}

# Configure gpg-agent
gpg_config() {
    while true; do
        read -p "Do you want to configure gpg-agent? (y/n): " response
        case $response in
            [Yy]* )
                mkdir -p ~/.gnupg
                yay -S --needed --noconfirm pinentry-qt
                echo "pinentry-program /usr/bin/pinentry-qt" | tee ~/.gnupg/gpg-agent.conf
                echo "max-cache-ttl 60480000" | tee -a ~/.gnupg/gpg-agent.conf
                echo "default-cache-ttl 60480000" | tee -a ~/.gnupg/gpg-agent.conf
                echo -e "\e[1;32mGpg-agent configured.\e[0m"
                break;;
            [Nn]* )
                echo -e "\e[1;32mSkipping gpg-agent configuration.\e[0m"
                break;;
            * )
                echo -e "\e[1;31mInvalid input. Please answer with 'y' or 'n'.\e[0m";;
        esac
    done
}

# Change shell to zsh and install starship
zsh_starship() {
    echo -e "\e[1;32m:: Changing shell to zsh... [10/11]\e[0m"
    chsh -s /bin/zsh
    echo -e "\e[1;32m:: Installing starship...\e[0m"
    sh -c "$(curl -fsSL https://starship.rs/install.sh)"
}

# Run os-prober
os_prober_run() {
    echo -e "\e[1;32m:: Running os-prober... [11/11]\e[0m"
    sudo os-prober
}

# Main function
main() {
    sudo_cache
    yay_install
    pkg_install
    dotfiles_clone
    configs_copy
    user_dirs
    mirrors_config
    timedatectl_set
    gpg_config
    zsh_starship
    os_prober_run
    echo -e "\e[1;32mBootstrap complete!\e[0m"
}

# Run the main function
main
