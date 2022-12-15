#!/bin/bash

# Author: Emma Taumoepeau

if [ "$EUID" -ne 0 ];then
    echo "Please run this script as root"
    exit 1
fi


echo "-------------------------------------------------------------------------------"
echo "Welcome to the Tarawera installation."
#echo "Please ensure system is up-to-date and meets the following prerequisites:"
echo ""
#echo "If installing on a Windows host, ensure you have the following packages installed: "
#echo "[*]  WSL 2.0 or higher"
#echo "[*]  WSL 2.0 Ubuntu 20.04 profile or higher"
echo "-------------------------------------------------------------------------------"

while true; do
    read -p "Do you want to proceed? (y/n) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done


apt-get update && apt-get -y install python3 python3-pip git curl zip unzip upx golang haproxy zlib1g -y

echo "Red Team Password: "
read -s redpasswordvar
echo "Blue Team Password: "
read -s bluepasswordvar
echo "-------------------------------------------------------------------------------"
echo "Tarawera installing.......";
echo "-------------------------------------------------------------------------------"


git clone https://github.com/EmmaMel/Tarawera.git --recursive --branch Automate
cd Tarawera

sed -i '/^users\:/q' conf/default.yml
sed -i "/users\:/ s/.*/users\:\n  blue\:\n    blue\: ${bluepasswordvar}\n  red\:\n    red\: ${redpasswordvar}/" conf/default.yml


git clone https://github.com/mitre/caldera.git --recursive --branch 4.1.0
cd caldera
rm requirements.txt
rm server.py
cd conf
rm default.yml
cd ../..
cp requirements.txt caldera/
cp server.py caldera/
cp default.yml caldera/conf/
cp default.yml caldera/conf/local.yml
cd caldera
pip3 install -r requirements.txt 
cd plugins/emu
./download_payloads.sh
cd ../
cd sandcat
./update-agents.sh
cd ../..

echo "-------------------------------------------------------------------------------"
echo "Tarawera installation complete!.......";
echo "Navigate to http://localhost:8888/ to access the web console."
echo "Login details can be found in mitreCaldera/caldera/conf/default.yml"
echo "-------------------------------------------------------------------------------"

python3 server.py


