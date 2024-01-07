#!/bin/bash

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install git -y

git clone https://github.com/jacksonliam/mjpg-streamer

sudo apt-get install cmake libjpeg8-dev -y

sudo apt-get install gcc g++ -y

cd mjpg-streamer

cd mjpg-streamer-experimental

make

sudo make install

echo " "

/usr/local/bin/mjpg_streamer -i "input_uvc.so -r 640x480 -d /dev/video0 -f 24 -q 80" -o "output_http.so -p 8080 -w /usr/local/share/mjpg-streamer/www" 
