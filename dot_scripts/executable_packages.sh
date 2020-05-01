#!/bin/bash

HELP="Usage: sudo ./packages.sh <operation> [...]
Automatically install Arch Linux packages

Examples:
$ sudo ./packages.sh"

source $(dirname "$0")/shared.sh

if [ -z "$SUDO_USER" ]; then
    echo "$HELP"
    exit 1
fi


# 'bat' # A cat(1) clone with wings
# 'highlight' # Fast and flexible source code highlighter (CLI version)
# 'lsd'   # The next gen ls command
# 'odt2txt' # extracts the text out of OpenDocument Texts

BASE_PACKAGES=(
    'acpi'  # enable special ACPI functions or add information to /proc or /sys
    'atool' # A script for managing file archives of various types
    'blueman'   # a full featured Bluetooth manager   
    'bluez-utils'   # Development and debugging utilities for the bluetooth protocol stack
    'curl'  # An URL retrieval utility and library
    'dhcpcd' # DHCP client daemon
    'ffmpegthumbnailer' # Lightweight video thumbnailer that can be used by file managers
    'firewalld' # Firewall daemon with D-Bus interface
    'git'   # the fast distributed version control system
    'go-pie'    # Core compiler tools for the Go programming language
    'go-tools'  # Developer tools for the Go programming language
    'htop'  # Interactive process viewer
    'jq'    # Command-line JSON processor
    'less'  # A terminal based program for viewing text files
    'mediainfo' # Supplies technical and tag information about a video or audio file (CLI interface)
    'neofetch'  # A CLI system information tool written in BASH that supports displaying images.
    'openvpn'   # An easy-to-use, robust and highly configurable VPN (Virtual Private Network)
    'openssh'   # Premier connectivity tool for remote login with the SSH protocol
    'pacman-contrib'    # Contributed scripts and tools for pacman systems
    'poppler'   # PDF rendering library based on xpdf 3.0
    'ranger'    # Simple, vim-like file manager
    'tmux'  # A terminal multiplexer
    'usbguard'  # Software framework for implementing USB device authorization policies
    'whois' # Intelligent WHOIS client
    'zsh'   # A very advanced and programmable command interpreter (shell) for UNIX
)

GUI_PACKAGES=(
    'adobe-source-code-pro-fonts'   # Monospaced font family for user interface and coding environments
    'alacritty' # A cross-platform, GPU-accelerated terminal emulator
    'compton'   # compositor for X
    'evince'    # Document viewer (PDF, Postscript, djvu, tiff, dvi, XPS, SyncTex support with gedit, comics books (cbr,cbz,cb7 and cbt))
    'feh'   # Fast and light imlib2-based image viewer
    'firefox'
    'i3-gaps'   # A fork of i3wm tiling window manager with more features, including gaps
    'i3blocks'  # Define blocks for your i3bar status line
    'i3lock'    # Improved screenlocker based upon XCB and PAM
    'rofi'  # A window switcher, application launcher and dmenu replacement
    'xbindkeys' # Launch shell commands with your keyboard or your mouse under X
    'xfce4-notifyd' # Notification daemon for the Xfce desktop
    'xfce4-screenshooter'   # Plugin that makes screenshots for the Xfce panel
    'xorg'
)

AUR_PACKAGES=(
    'gotop' # Another terminal based graphical activity monitor
    'nerd-fonts-source-code-pro' # Patched font SourceCodePro from nerd-fonts library
    'oh-my-zsh-git' # A community-driven framework for managing your zsh configuration
    'mint-themes-git'   # Linux Mint themes
    'mint-y-icons'  # A flat, colorful, and modern theme based on Paper and Moka
)


if [ "$(uname -m)" == 'x86_64' ]; then
    BASE_PACKAGES+=(
        'reflector' # A Python 3 module and script to retrieve and filter the latest Pacman mirror list.
        'playerctl' # mpris media player controller and lib for spotify, vlc, audacious, bmp, xmms2, and others.
        'pulseaudio'    # A featureful, general-purpose sound server
        'pulseaudio-alsa'   # ALSA Configuration for PulseAudio
        'pulseaudio-bluetooth'  # Bluetooth support for PulseAudio
        'xfce4-power-manager'   # Power manager for Xfce desktop
    )
    GUI_PACKAGES+=(
        'pavucontrol'   # PulseAudio Volume Control
        'vlc'   # Multi-platform MPEG, VCD/DVD, and DivX player
        'xorg-xinit'    # X.Org initialisation program
    )
    AUR_PACKAGES+=(
        'pulseaudio-ctl'    # Control pulseaudio volume from the shell or mapped to keyboard shortcuts
    )
fi


function installAurPackages() {
    banner "I will install the AUR packages"
    packageIterator "yay" "${AUR_PACKAGES[@]}"
}

function installYay() {
    if pacman -Qs yay > /dev/null ; then
        return 0
    fi
    sudo -u "$SUDO_USER" -- sh -c "
    git clone https://aur.archlinux.org/yay.git;
    cd yay || return;
    yes | makepkg -si"
}

function installOhMyZsh() {
    local URL='https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh'
    banner "I will install Oh My Zsh and plugins"

    sudo -u "$SUDO_USER" -- sh -c "$(curl -fsSL $URL)"
    sudo -u "$SUDO_USER" -- sh -c "
    git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-history-substring-search ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
    cd ~/.oh-my-zsh/custom/themes/powerlevel9k
    git checkout next
    cd - &>/dev/null"
}

function configurePacman() {
    sed -i 's/#Color/Color\nILoveCandy/g' /etc/pacman.conf
    sed -i 's/#TotalDownload/TotalDownload/g' /etc/pacman.conf
}

function installSpacemacs() {
    if [ "$(uname -m)" == 'x86_64' ]; then
        banner "I will install spacemacs"

        sudo -u "$SUDO_USER" -- sh -c "
        git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d &>/dev/null
        cd ~/.emacs.d
        git checkout develop &>/dev/null
        cd - &>/dev/null"
    fi
}

function installPackages() {
    banner "I will install the base system"
    configurePacman
    packageIterator "pacman" "${BASE_PACKAGES[@]}"

   
    banner "I will install the GUI packages"
    packageIterator "pacman" "${GUI_PACKAGES[@]}"

    installYay
}





installPackages
installAurPackages
installOhMyZsh
installSpacemacs

banner "Done :)"
