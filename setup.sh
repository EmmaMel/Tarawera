#!/bin/bash

# Author: Emma Taumoepeau

if [ "$EUID" -ne 0 ];then
    echo "Please run this script as root"
    exit 1
fi


echo "-------------------------------------------------------------------------------"
echo "Welcome to the Tarawera installation."
echo "Please ensure system is up-to-date and meets the following prerequisites:"
echo ""
echo "If installing on a Unix host, ensure you have the following packages installed: "
echo "[*]  Docker version 20.10.17 or higher"
echo "[*]  git version 2.31.1 or higher"
echo ""
echo "If installing on a Windows host, ensure you have the following packages installed: "
echo "[*]  WSL 2.0 or higher"
echo "[*]  git version 2.31.1 or higher"
echo "[*]  Docker installed to WSL 2.0"
echo "[*]  WSL 2.0 Ubuntu 20.04 profile"
echo "[*]  git version 2.30 or higher on Ubuntu profile"
echo "-------------------------------------------------------------------------------"

while true; do
    read -p "Do you want to proceed? (y/n) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

read -p 'Docker Container name: ' containernamevar
echo "Red Team Password: "
read -s redpasswordvar
echo "Blue Team Password: "
read -s bluepasswordvar
echo "-------------------------------------------------------------------------------"
echo "Tarawera installing.......";
echo "-------------------------------------------------------------------------------"


# Check for docker, progress if located otherwise exit
if ! docker version ; then
   #echo "Docker not found. Please install Docker and try again"
  echo "Docker not found. Installing Docker....."
  snap install docker
  #exit 1

elif docker version ; then
  echo "Docker Found, Continuing"
fi

mkdir TaraweraCaldera
cd TaraweraCaldera
git clone https://github.com/mitre/caldera.git --recursive --branch 4.1.0
cd caldera
rm Dockerfile
cd ../..
cp Dockerfile TaraweraCaldera/caldera/
cd TaraweraCaldera/caldera

# Update passwords
sed -i '/^users\:/q' conf/default.yml
sed -i "/users\:/ s/.*/users\:\n  blue\:\n    blue\: ${bluepasswordvar}\n  red\:\n    red\: ${redpasswordvar}/" conf/default.yml

# Pull Caldera Docker Image
# if docker pull mitre/caldera ; then
#   echo "Docker Caldera Image pull successful"
# else
#   echo "Error. Failed pulling mitre/calder image from DockerHub. Please manually try to pull."
#   exit 1
# fi

# Build and run Docker Image
#docker build . --build-arg WIN_BUILD=true -t mitre/caldera
#sudo docker run -it -d --name ${containernamevar} --hostname ${containernamevar} -p 7010:7010 -p 7011:7011 -p 7012:7012 -p 8888:8888 mitre/caldera
docker build . --build-arg WIN_BUILD=true -t caldera:latest
docker run -it -d --name ${containernamevar} --hostname ${containernamevar} -p 7010:7010 -p 7011:7011 -p 7012:7012 -p 8888:8888 caldera:latest
sleep 10

# Update and restart Docker
docker exec ${containernamevar} bash -c "apt-get update"
docker exec ${containernamevar} bash -c "apt-get upgrade -y"
docker exec -it ${containernamevar} bash -c "apt-get install upx -y"
docker update --restart=always ${containernamevar}
sleep 5
docker container restart ${containernamevar}
sleep 5

echo "-------------------------------------------------------------------------------"
echo "Tarawera installation complete!.......";
echo "Navigate to http://localhost:8888/ to access the web console."
echo "Login details can be found in mitreCaldera/caldera/conf/default.yml"
echo "-------------------------------------------------------------------------------"
