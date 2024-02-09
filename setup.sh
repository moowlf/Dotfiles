
LOG_FILE=/tmp/dotfiles_setup.log
CurrentPath=$(pwd)
cd /tmp

function message {
    echo -e "\e[37m$1\e[0m"
}

function fail {
    echo -e "\e[93m$1\e[0m"
}

function success {
    echo -e "\e[92m$1\e[0m"
}

function print_result_installation_pkg {

    if [ $? -ne 0 ]
    then
        fail " |- Failed to install $1"
    else
        success " |+ Successfully installed $1"
    fi
}

function install_pkg {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yqq install $1 > $LOG_FILE 2>&1
    print_result_installation_pkg $1
}


# -----------------------------------------------------------------------------
message "[+] Package Setup"
message " |+ Updating package manager"
sudo apt-get -qq update && \
    sudo apt-get -yqq upgrade
if [ $? -ne 0 ]
then
    fail " |+ Updating package manager failed!"
    exit 1
else
    success " |+ Updating package manager done!"
fi

# ----------------------------------------------------------------------------
# Deal with packages

message "\n[+] Main Package Installation"

dpkg-query -s flatpak &>/dev/null

if [ $? -ne 0 ]
then
    install_pkg "flatpak"
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fail " Flatpak was not installed but this script installed it for you. Please restart!"
    exit 1
else
    success " |+ Flatpak is installed!"
fi

pkgs=(

    # Dev
    g++
    python3
    git
    cmake

    # Gnome
    gnome-tweaks
    gnome-session
    gnome-calculator
    gnome-control-center
    policykit-1-gnome

    # System
    zsh
    alacritty
    apt-transport-https
    curl
    htop
    tree
    xclip
    wget
    ca-certificates

    # Others
    fonts-firacode
    telegram-desktop
)

for pkg in "${pkgs[@]}"
do
    install_pkg ${pkg}
done

# VSCode
curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" --output vscode.deb --silent && \
    install_pkg ./vscode.deb && rm vscode.deb

# Discord
curl -L https://discord.com/api/download\?platform\=linux\&format\=deb --output discord.deb --silent && \
    install_pkg ./discord.deb && rm discord.deb

# IntelliJ
curl -L "https://data.services.jetbrains.com/products/download?platform=linux&code=TBA" -o toolbox.tar.gz --silent && \
    tar -xf toolbox.tar.gz && \
    cd $(find . -maxdepth 1 -type d -name jetbrains-toolbox-\* -print | head -n1) && \
    sudo mv jetbrains-toolbox /opt/jetbrains && rm /tmp/toolbox.tar.gz
print_result_installation_pkg "JetBrains Toolbox"

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh $1 > $LOG_FILE 2>&1
rm get-docker.sh
print_result_installation_pkg "docker"

# Firefox
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla 
sudo apt update
install_pkg firefox

# Spotify
curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && install_pkg spotify-client

## Make necessary dirs
mkdir -p $HOME/.dotfiles/zsh

message "[+] Porting config files"
cp "$CurrentPath/configs/.nanorc" "$HOME"
cp "$CurrentPath/configs/.zshrc" "$HOME"
cp "$CurrentPath/configs/aliases.zsh" "$HOME/.dotfiles/zsh"

# -----------------------------------------------------------------------------
# Zsh Files
# -----------------------------------------------------------------------------
message "[+] Install oh-my-zsh"

# Install Antigen for zsh
curl -L http://git.io/antigen -o "$HOME"/.dotfiles/zsh/antigen.zsh -s

# --- OH-MY-ZSH
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o installzsh.sh -s
ZSH="$HOME/.dotfiles/zsh/oh-my-zsh" sh installzsh.sh --keep-zshrc
rm installzsh.sh