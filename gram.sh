#!/bin/bash


GREEN='\e[32m'
RESET='\e[0m'
RED='\e[31m'

#run from home directory
cd /home/pi

#update system
echo -e "${GREEN}Updating System...${RESET}"
sleep 3
sudo apt update && sudo apt upgrade -y 

echo " "

#install docker
echo -e "${GREEN}Installing Docker and Docker compose...${RESET}"
sleep 3
sudo apt-get install -y curl
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
	export MAIN_DIRECTORY=$(pwd)
	cd ..
	wget -O docker-compose.yml https://raw.githubusercontent.com/Kclamberth/OctoPi-PiHole/main/docker-compose.yml 
	echo " "
	echo -e "${GREEN}Creating Octoprint...${RESET}"
	sleep 3
	sudo docker-compose up -d 
	#permissions for octoprint
	sudo chmod -R 777 elegoo
	sudo docker-compose restart
	e1=$?
	if [[ $e1 -eq 0 ]]; then
		echo -e "${GREEN}Octoprint succesfully installed.${RESET}"
  		sleep 3	
	fi

else
	echo -e "${RED}Docker or Docker compose FAILED install!${RESET}"
fi

#main pihole/unbound installation
echo -e "${GREEN}Installing Pihole/Unbound...${RESET}"
sleep 5

#pihole
curl -sSL https://install.pi-hole.net | bash
echo " "
echo -e "${GREEN}Change your Pihole webpage password...${RESET}"
pihole -a -p
echo -e "${GREEN}Visit your Pihole at http://LOCALHOSTIP/admin.${RESET}"
sleep 5

#unbound
echo -e "${GREEN}Installing Unbound...${RESET}"
sleep 3
sudo apt-get install -y unbound 
wget -O /etc/unbound/unbound.conf.d/pi-hole.conf https://raw.githubusercontent.com/Kclamberth/OctoPi-PiHole/main/unbound.txt
sudo service unbound restart
sudo service unbound status | grep Active

echo " "
echo -e "${GREEN}Finished installing Octoprint and Pihole/Unbound.${RESET}"
echo -e "${GREEN}Reach Octoprint at http://LOCALHOSTIP:4000, and Pihole at http://LOCALHOSTIP/admin ${RESET}"




