#!/bin/sh

#This script should be run in the docker container


#Restart the container after changing the path
#https://matrix.to/#/!PEnnsqywkTLXsTNlAI:matrix.org/$SyaJz0kwWOGyoHfDAGlt9e_vKvZ4kweM_EwTdIdjLFo?via=bonifacelabs.ca&via=matrix.org
#yq -i '.EncodingOptions.EncoderAppPathDisplay = "/usr/local/bin/ffmpeg"' /config/config/encoding.xml


rffmpeg init -y
rffmpeg add 192.168.0.118

mkdir -p /config/.ssh/
mkdir -p /root/.ssh/
rm -rf /config/.ssh/*
ssh-keygen -t rsa -f /config/.ssh/id_rsa -q -N ""
chmod 600 /config/.ssh/id_rsa
ssh-keyscan 192.168.0.118 | tee -a /root/.ssh/known_hosts

echo "Copy the /config/.ssh/id_rsa.pub file to server"
echo "The container needs to be restarted for changes to take effect"


#FOR TESTING
# rffmpeg run lscpu | grep 'Model name'
# cd /media/tv/Baby\ Reindeer\ \(2024\)\ \[tvdbid-417223\]/Season\ 01/
# rffmpeg run /usr/lib/jellyfin-ffmpeg/ffmpeg -hwaccel cuda -i %USERPROFILE%\Downloads\test_video.mkv -c:v hevc_nvenc  -f null -