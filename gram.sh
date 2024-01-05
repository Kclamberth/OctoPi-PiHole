#!/bin/bash


GREEN='\e[32m'
RESET='\e[0m'
RED='\e[31m'

#run from home directory
cd ~

#update system
echo -e "${GREEN}Updating System...${RESET}"
sleep 3
sudo apt update && sudo apt upgrade -y 

echo " "

#install docker
echo -e "${GREEN}Installing Docker and Docker compose...${RESET}"
sleep 3
sudo apt-get install -y docker
sudo apt-get install -y docker-compose

echo " "

#check versions
echo -e "${GREEN}VERSIONS:${RESET}"
echo -e "${GREEN}$( docker --version && docker-compose --version )${RESET}"
e0=$?

#main octoprint installation
if [[ $e0 -eq 0 ]]; then
	echo " "
	echo -e "${GREEN}Docker and Docker compose successfully installed.${RESET}"
	echo -e "${GREEN}Continuing installation...${RESET}"
	mkdir octoprint
	cd octoprint
	mkdir elegoo
	cd elegoo
	mainDirectory=$( pwd )
	cd ..
	wget -O docker-compose.yml https://raw.githubusercontent.com/Kclamberth/OctoPi-PiHole/main/docker-compose.yml 
	echo " "
	echo -e "${GREEN}Starting Octoprint...${RESET}"
	sleep 3
	sudo docker-compose up -d 
	#permissions for octoprint
	sudo chmod -R 777 elegoo
	sudo docker-compose restart
	e1=$?
	if [[ $e1 -eq 0 ]]; then
		echo -e "${GREEN}Octoprint succesfully installed.${RESET}"
		
	fi

else
	echo -e "${RED}Docker or Docker compose FAILED install!${RESET}"
fi

#main pihole/unbound installation
echo -e "${GREEN}Installing Pihole/Unbound...${RESET}"

cd ~
mkdir pihole
cd pihole

echo -e "${GREEN}Downloading Docker Compose file...${RESET}"
wget -O docker-compose.yml https://raw.githubusercontent.com/Kclamberth/OctoPi-PiHole/main/pihole-compose.yml
echo -e "${GREEN}Enter a password for Pi-hole's web interface:${RESET}"
read -s PIHOLE_PASSWORD
export PIHOLE_WEBPASSWORD=$PIHOLE_PASSWORD

echo -e "${GREEN}Starting Pihole/Unbound...${RESET}"
sudo docker-compose up -d
echo " "
sudo docker ps -a
echo -e "${GREEN}Finished installing Octoprint and Pihole/Unbound.${RESET}"



