#!/bin/bash

USERNAME=$(whoami)
USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)

# Safeguarding by confirming user intentions before proceeding.
read -p "This script will modify system settings and install multiple packages. Continue? (y/n) " confirmation
if [[ "$confirmation" != "y" ]]; then
    echo "Aborting installation."
    exit 1
fi

echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo -f /tmp/$USERNAME
if ! sudo visudo -c -f /tmp/$USERNAME; then
    echo "Sudoers file is invalid. Exiting." >&2
    exit 1
fi

sudo mv /tmp/$USERNAME /etc/sudoers.d/$USERNAME

sudo apt-get update -y && apt-get upgrade -y

#################
#  Basic tools  #
#################

echo "Installing basic tools..."
sudo apt-get install -y git curl wget vim zsh tmux htop tree nmap net-tools zip openssh-server \
                        libmcrypt-dev libicu-dev libxml2-dev libxslt1-dev libnss3-tools snapd \
                        libfreetype6-dev libjpeg62-turbo-dev libxrender1 libfontconfig1 libfuse2 \
                        libx11-dev libxtst6 libpng-dev zlib1g-dev libjpeg-dev libonig-dev libwebp-dev \
                        libqt5svg5 jpegoptim optipng webp gnupg2 libpq-dev libzip-dev unzip sudo make \
                        xz-utils tk-dev libffi-dev liblzma-dev python-openssl libncurses5-dev libncursesw5-dev

sudo systemctl disable apache2

###################
# PHP & Composer  #
###################

echo "Installing PHP and Composer..."
echo "Select a PHP version to install:"
echo "1) PHP 7.4"
echo "2) PHP 8.0"
echo "3) PHP 8.1"
echo -n "Enter your choice (1-3): "
read choice

case $choice in
    1) PHP_VERSION="php7.4" ;;
    2) PHP_VERSION="php8.0" ;;
    3) PHP_VERSION="php8.1" ;;
    *) echo "Invalid choice, exiting."; exit 1 ;;
esac

sudo apt-get install -y $PHP_VERSION $PHP_VERSION-cli $PHP_VERSION-fpm $PHP_VERSION-pgsql $PHP_VERSION-xml \
                        $PHP_VERSION-mbstring $PHP_VERSION-curl $PHP_VERSION-zip $PHP_VERSION-intl \
                        $PHP_VERSION-gd $PHP_VERSION-imagick $PHP_VERSION-xdebug $PHP_VERSION-ldap \
                        $PHP_VERSION-xsl $PHP_VERSION-unzip

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

composer --version

#######################
#  Node / yarn / npm  #
#######################

echo "Installing Node.js, npm and yarn..."
curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn \
    && npm install -g npm

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "Installing npx..."
npm install -g npx

##########
#  Java  #
##########

echo "Installing Java..."
echo "Select a Java version to install:"
echo "1) OpenJDK 8"
echo "2) OpenJDK 11"
echo "3) OpenJDK 17"
echo -n "Enter your choice (1-3): "
read java_choice

case $java_choice in
    1) JAVA_PACKAGE="openjdk-8-jdk" ;;
    2) JAVA_PACKAGE="openjdk-11-jdk" ;;
    3) JAVA_PACKAGE="openjdk-17-jdk" ;;
    *) echo "Invalid choice, exiting."; exit 1 ;;
esac

echo "Installing $JAVA_PACKAGE..."
sudo apt-get install -y $JAVA_PACKAGE
sudo update-alternatives --config java

############
#  Python  #
############

echo "Installing Python..."
echo "Sélectionnez la version de Python à installer :"
echo "1) Python 2.7"
echo "2) Python 3.6"
echo "3) Python 3.7"
echo "4) Python 3.8"
echo "5) Python 3.9"
echo "6) Python 3.10"
read -p "Entrez votre choix (nombre entre 1 et 6) : " choice

# Installation de la version sélectionnée
case $choice in
    1) sudo apt-get install -y python2.7 ;;
    2) sudo apt-get install -y python3.6 ;;
    3) sudo apt-get install -y python3.7 ;;
    4) sudo apt-get install -y python3.8 ;;
    5) sudo apt-get install -y python3.9 ;;
    6) sudo apt-get install -y python3.10 ;;
    *) echo "Choix invalide. Installation annulée."; exit 1 ;;
esac

echo "Python installé avec succès."

#############
#  Symfony  #
#############

echo "Installing Symfony CLI..."
curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
sudo apt install symfony-cli

###############
#  oh-my-zsh  #
###############

echo "Installing oh-my-zsh..."
echo "Avant de procéder à l'installation de Powerlevel10k, veuillez télécharger et installer les polices suivantes pour assurer un affichage correct du thème :"
echo "1. MesloLGS NF Regular: https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
echo "2. MesloLGS NF Bold: https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
echo "3. MesloLGS NF Italic: https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
echo "4. MesloLGS NF Bold Italic: https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"

echo "Veuillez ouvrir ces liens dans un navigateur web et télécharger chaque fichier de police. Installez ensuite les polices en double-cliquant sur les fichiers téléchargés ou en les ajoutant au gestionnaire de polices de votre système."

read -p "Appuyez sur [Enter] une fois les polices installées pour continuer avec l'installation de Powerlevel10k."

sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

sudo cp -f ./.zshrc $USER_HOME/.zshrc

zsh
#Type p10k configure if the configuration wizard doesn't start automatically

###############
#  Workspace  #
###############

echo "Creating workspace directory..."
sudo mkdir -p $USER_HOME/dev
sudo chmod -R 777 $USER_HOME/dev

wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.3.1.31116.tar.gz
sudo tar -xzf jetbrains-toolbox-2.3.1.31116.tar.gz /opt
sudo mv /opt/jetbrains-toolbox-2.3.1.31116 /opt/jetbrains-toolbox
sudo ln -sf /opt/jetbrains/jetbrains-toolbox /usr/local/bin/jetbrains

######################
#  Chrome & firefox  #
######################

echo "Installing Chrome and Firefox..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get install -f

CHROMEVERSION=$(google-chrome --version)
CHROMEDRIVER_URL="https://storage.googleapis.com/chrome-for-testing-public/$CHROME_VERSION/linux64/chromedriver-linux64.zip"
wget $CHROMEDRIVER_URL

tar -xzf chromedriver-linux64.zip
sudo mv chromedriver /usr/local/bin/

echo chromedriver --version

sudo snap install firefox

sudo cp -f ./updateChromeDriver.sh /usr/local/bin/updateChromeDriver.sh
sudo chmod 777 /usr/local/bin/updateChromeDriver.sh
echo 'DPkg::Post-Invoke {"/usr/local/bin/updateChromeDriver.sh";};' | sudo tee /etc/apt/apt.conf.d/99runscript > /dev/null

#################
#  Platform sh  #
#################

echo "Installing Platform.sh CLI"
curl -fsSL https://raw.githubusercontent.com/platformsh/cli/main/installer.sh | bash

sudo apt-get update -y && apt-get upgrade -y








