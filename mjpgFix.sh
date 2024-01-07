#!/bin/bash


if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root."
	exit 1
fi

GREEN='\e[32m'
RESET='\e[0m'
RED='\e[31m'

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

