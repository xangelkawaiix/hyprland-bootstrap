# 🌸 Nishimiya's Dotfiles Bootstrap Script 🌸

This repository contains a bootstrap script to set up a new Arch Linux machine with my preferred packages and configurations. The script installs `yay` (AUR helper), clones my dotfiles repository, installs packages, copies configurations, and configures the Arch Linux mirror list.

## 🚀 Getting Started

### Prerequisites

- A fresh installation of Arch Linux. (Recommended)
- Internet connection.

> [!CAUTION]
>  **Best Run on Minimal Arch Linux-based Distributions**  
>   This script is designed to be run on minimal Arch Linux-based systems. Running it on a more customized setup may lead to **conflicts** or **issues** with existing configurations.
> 
>  **Configuration Overwrite Warning**  
>   This script **does not** backup your existing user configurations. It will most likely **overwrite** or cause conflicts with any existing configurations in your home directory. Be cautious if you have custom settings already in place.

> [!IMPORTANT]
> **No Automatic Uninstall for Dotfiles**  
>   The script does not include a mechanism for uninstalling or removing dotfiles. You will need to manually remove any dotfiles or configuration files added by the script from your system.

> [!TIP]
>  **Manual Package Removal**  
>   If you'd like to remove the packages installed by this script, you can manually inspect the `packages` file for a list of installed packages and remove them accordingly.

### Step-by-Step Instructions

1. **Download the Bootstrap Script**

   Clone this repository to your local machine:

   ```bash
   git clone https://github.com/xangelkawaiix/hyprland-bootstrap.git
   cd hyprland-bootstrap
   ```

3. **Make the Script Executable**

   Before running the script, make sure it is executable:

   `chmod +x bootstrap.sh`

4. **Run the Bootstrap Script**

   Execute the bootstrap script:

   `./bootstrap.sh`

### What the Script Does

- **Install yay AUR Helper**

   The script installs `yay`, an AUR helper that allows you to install packages from the Arch User Repository.

- **Clone Dotfiles Repository**

   The script clones my dotfiles repository and changes into the repository directory.

- **Install Packages**

   The script installs the packages listed in `packages`. The packages are organized into categories for easier management.

- **Copy Configuration Files**

   The script copies the configuration files and folders from the repository to the appropriate locations in your home directory. It also creates symbolic links for `.profile`, `.zshenv`, `.zshrc`, and `.zprofile`.

- **Configure Arch Linux Mirror List**

   The script uses `reflector` to update the Arch Linux mirror list with the fastest mirrors.
Set Timedatectl for Dual Boot
The script configures timedatectl to ensure proper time handling in a dual-boot setup with Windows.

- **Configure GPG Agent**
  
   The script configures the gpg agent to use pinentry-qt for handling passphrase prompts.

- **Install Starship Prompt**
  
   The script installs and configures the starship prompt for a modern, minimal command-line interface.

- **Detect Windows for Dual Boot**
  
   The script runs os-prober to detect any Windows installations for dual boot.

## 🛠️ Package List

The `packages` file contains a list of packages organized into categories. Each category is commented for easier navigation. The script reads this file and installs the packages using `yay`.

## 🌟 Support Me

If you find this project helpful and would like to support me, consider buying me a coffee on Trakteer:

[![Trakteer.id](https://img.shields.io/badge/Trakteer.id-%23FFDD00?style=for-the-badge&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAABJ1JREFUWIXtl01oE1EQx3/3Zie72U02m4BQqVQKpYig4EMQfCk+Gh8MPlQf+mB8MChWfCg+BB8EfDBWfAiqPlQfgg9BqVQKpVIoFKEUCgWbm81udv6Zne1lN9lsIiHi5CfZnd+8N2/mzZv3ZiYi/weZ75H5Hpnvkfke/28EwAxmMIMZzGAGM5jBDP4HMgMAM5jBDGYwgxnMYAYz+B/IDADMYAYzmMEMZjCDGfzPZAYAZjCDGcxgBjOYwQx+BzIDADOYwQxmMIMZzGAGM/gfyAwAzGAGM5jBDGYwgxn8D2QGAGYwgxnMYAYzmMEMZvA/kP8Bk6nY0MzHF+MAAAAASUVORK5CYII=)](https://trakteer.id/nishi.miya/tip)

## 📜 License

This project is licensed under the UNLICENSE. See the [LICENSE](LICENSE) file for details.

