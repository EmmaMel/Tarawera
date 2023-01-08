#!/bin/bash
# Shell script to automate, clone and configure Caldera.
# Author: Emma Taumoepeau


if [ "$EUID" -ne 0 ];then
    echo "Please run this script as root"
    exit 1
fi


homeDirectory=$(pwd) >> /dev/null


echo "-------------------------------------------------------------------------------"
echo "Welcome to the Tarawera installation."
echo "Please ensure system is up-to-date"
echo "-------------------------------------------------------------------------------"

while true; do
    read -p "Do you want to proceed? (y/n) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Install neccessary packages
DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y install python3 python3-pip git curl zip unzip upx golang haproxy zlib1g -y

echo "Red Team Password: "
read -s redpasswordvar
echo "Blue Team Password: "
read -s bluepasswordvar
echo "-------------------------------------------------------------------------------"
echo "Tarawera installing.......";
echo "-------------------------------------------------------------------------------"

# Modify passwords in default.yml configuration file to be user specified.
sed -i '/^users\:/q' default.yml
sed -i "/users\:/ s/.*/users\:\n  blue\:\n    blue\: ${bluepasswordvar}\n  red\:\n    red\: ${redpasswordvar}/" default.yml

# Modify IP address in default.yml configuration file to be host IP address.
IP=$(hostname  -I | cut -f1 -d' ')
IP="${IP%"${IP##*[![:space:]]}"}" 
sed -i "s/0.0.0.0/$IP/g" default.yml

git clone https://github.com/mitre/caldera.git --recursive --branch 4.1.0
cd caldera
calderaDirectory=$(pwd) >> /dev/null

# Remove files in Caldera directory to be replaced by Tarawera files.
rm requirements.txt
rm server.py
git clone --depth 1 https://github.com/center-for-threat-informed-defense/adversary_emulation_library.git plugins/emu/data/adversary-emulation-plans
cd conf
rm default.yml

# Copy Tarawera files into Caldera directory.
cd $homeDirectory
cp default.yml caldera/conf/
cp requirements.txt caldera/
cp server.py caldera/

cd caldera

# Install python-pip dependencies
pip3 install -r requirements.txt 

# Download payloads into the Emu plugin
cd plugins/emu
./download_payloads.sh

cd ../
cd sandcat
./update-agents.sh
cd ../
cp -r emu/payloads/* emu/data/adversary-emulation-plans/*
cd ../
cd plugins/emu/data/adversary-emulation-plans/apt29/Emulation_Plan/yaml
rm APT29.yaml
cd $homeDirectory
cp APT29.yaml caldera/plugins/emu/data/adversary-emulation-plans/apt29/Emulation_Plan/yaml/
cd $calderaDirectory

echo "-------------------------------------------------------------------------------"
echo "Tarawera installation complete!.......";
echo "Navigate to http://$IP:8888/ to access the web console."
echo "-----------------------------"
echo "|     Login credentials:    |"        
echo "|     Username:    red      |" 
echo "|     Username:    blue     |" 
echo "-----------------------------"
echo "Passwords are user specified and can be found in Tarawera/caldera/conf/default.yml"
echo "To gracefully terminate the server, enter:"
echo "   Ctrl C"
echo "To restart the server, navigate to Tarawera/caldera/ and enter:"
echo "   python3 server.py"
echo "-------------------------------------------------------------------------------"

python3 server.py

