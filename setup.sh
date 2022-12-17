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


DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y install python3 python3-pip git curl zip unzip upx golang haproxy zlib1g -y

echo "Red Team Password: "
read -s redpasswordvar
echo "Blue Team Password: "
read -s bluepasswordvar
echo "-------------------------------------------------------------------------------"
echo "Tarawera installing.......";
echo "-------------------------------------------------------------------------------"

sed -i '/^users\:/q' default.yml
sed -i "/users\:/ s/.*/users\:\n  blue\:\n    blue\: ${bluepasswordvar}\n  red\:\n    red\: ${redpasswordvar}/" default.yml

#git clone https://github.com/EmmaMel/Tarawera.git --recursive --branch Automate
#cd Tarawera



git clone https://github.com/mitre/caldera.git --recursive --branch 4.1.0
cd caldera
rm requirements.txt
rm server.py
git clone --depth 1 https://github.com/center-for-threat-informed-defense/adversary_emulation_library.git plugins/emu/data/adversary-emulation-plans
cd conf
rm default.yml

#sed -i '/^users\:/q' conf/default.yml
#sed -i "/users\:/ s/.*/users\:\n  blue\:\n    blue\: ${bluepasswordvar}\n  red\:\n    red\: ${redpasswordvar}/" conf/default.yml


cd ../..
cp default.yml caldera/conf/
cp requirements.txt caldera/
cp server.py caldera/
#cp default.yml caldera/conf/
#cp default.yml caldera/conf/local.yml
cd caldera
pip3 install -r requirements.txt 
cd plugins/emu
./download_payloads.sh




cd ../

#pluginDirectory=$(pwd) >> /dev/null
#cd builder
#sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
#bash -c './install.sh'
#setsid install.sh >/dev/null 2>&1 < /dev/null &
#( exec "${pluginDirectory}/builder/install.sh" )
#gnome-terminal -e "bash -c ~/install.sh;bash"
#USER=$(printf '%s\n' "${SUDO_USER:-$USER}")



#usermod $USER -a -G docker
#apt-get remove -y docker docker-engine docker.io containerd runc
#apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' -y
#apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io



#bash --rcfile <(echo '. ~/install.sh;bash')


#bash --rcfile <(echo '$pluginDirectory/builder/install.sh;bash')
#yes | ./install_packages.sh pkgs.txt
#cd $pluginDirectory
#cd../
cd sandcat
./update-agents.sh
cd ../
cp -r emu/payloads/* emu/data/adversary-emulation-plans/*
cd ../

echo "-------------------------------------------------------------------------------"
echo "Tarawera installation complete!.......";
echo "Navigate to http://localhost:8888/ to access the web console."
echo "Login details can be found in Tarawera/caldera/conf/default.yml"
echo "To gracefully terminate the server, enter:"
echo "   Ctrl C"
echo "To restart the server, navigate to Tarawera/caldera/ and enter:"
echo "   python3 server.py"
echo "-------------------------------------------------------------------------------"

python3 server.py

