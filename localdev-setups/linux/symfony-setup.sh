#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Symfony install
echo 'deb [trusted=yes] https://repo.symfony.com/apt/ /' | sudo tee /etc/apt/sources.list.d/symfony-cli.list

#Fetch latest repo updates
sudo apt update & sudo apt upgrade -y

#Install Symfony-cli
sudo apt install symfony-cli

# Add ondrej/php repository
sudo apt install software-properties-common && sudo add-apt-repository ppa:ondrej/php -y
sudo apt update & sudo apt upgrade -y 

# Install PHP 8.1
sudo apt install php8.1 php8.1-fpm php8.1-cli -y
php --version

# Install required PHP Extensions for Symfony
sudo apt install php8.1-simplexml php8.1-mbstring php8.1-intl php8.1-pgsql

#Composer Setup
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

sudo mv composer.phar /usr/local/bin/composer

#Check Symfony requires
symfony check:requirements