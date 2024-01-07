#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root."
	exit 1
fi

GREEN='\e[32m'
RESET='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'

echo -e "${YELLOW}This script will attempt to fix mjpeg, without altering anything related to PiHole/Unbound.${RESET}"
echo -e "${YELLOW}Octoprint's Docker compose will be updated and mjpeg will be ran on the host device separately.${RESET}"
echo " "
echo -ne "${GREEN}Starting in 15..."
for i in {14..1}
do
	sleep 1
 	echo -ne "\rStarting in '$i'..."
done
echo -ne "\rStarting...${RESET}"
echo " "

cleanup(){
	echo " "
	echo -e "${GREEN}Terminating stream...${RESET}"
	kill $detect_pid
	wait $detect_pid 2>/dev/null
	echo -e "${GREEN}Stream terminated.${RESET}"
	echo " "
	echo -e "${GREEN}Did the script fix the mjpeg issue? (y/n)${RESET}"
	read -r answer
	echo " "

	if [[ "$answer" = "y" ]]; then
		echo -e "${GREEN}Pogchamp. Editing the script to run stream on startup...${RESET}"
		sleep 5
		wget -O /etc/systemd/system/mjpgstreamer.service https://raw.githubusercontent.com/Kclamberth/OctoPi-PiHole/main/systemdBoot
		sudo systemctl daemon-reload
		sudo systemctl enable mjpgstreamer.service
		sudo systemctl start mjpgstreamer.service
		echo " "
		echo -e "${GREEN}Check status of stream via 'sudo systemctl status mjpgstreamer.service'${RESET}"
	else
		echo -e "${RED}Abort mission.${RESET}"
	fi
}
#update docker-compose.yml for octoprint
echo -e "${GREEN}Updating Octoprint docker-compose.yml${RESET}"
sleep 5
wget -O docker-compose.yml https://raw.githubusercontent.com/Kclamberth/OctoPi-PiHole/main/docker-compose.yml
sudo docker stop $(docker ps -q)
mv docker-compose.yml /home/supergraham/octoprint/docker-compose.yml
sudo docker compose up -d 
echo " "

#update system & install dependencies
echo -e "${GREEN}Updating System & installing dependencies...${RESET}"
sleep 5
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install git -y
sudo apt-get install v4l-utils -y
git clone https://github.com/jacksonliam/mjpg-streamer
sudo apt-get install cmake libjpeg8-dev -y
sudo apt-get install gcc g++ -y
echo " "

#move to correct directory
cd mjpg-streamer
cd mjpg-streamer-experimental

echo -e "${GREEN}Compiling...${RESET}"
sleep 5
#compile
make
sudo make install
echo " "

#run stream
echo -e "${GREEN}Starting stream...${RESET}"
sleep 5
/usr/local/bin/mjpg_streamer -i "input_uvc.so -r 1920x1080 -d /dev/video0 -f 30 -q 80" -o "output_http.so -p 8080 -w /usr/local/share/mjpg-streamer/www" & detect_pid=$!

trap cleanup SIGINT
echo " "
echo "${YELLOW}Test the stream via http://ipAddress:8080. Once done, press ctrl+c (terminate) to move on.${RESET}"
wait $detect_pid
