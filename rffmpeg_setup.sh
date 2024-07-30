#!/bin/sh

#This script should be run in the docker container

apt update 
curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/bin/yq
chmod +x /usr/bin/yq

#rffmpeg setup
apt update 
apt install -y openssh-client python3-click python3-yaml python3-requests wget
wget https://raw.githubusercontent.com/mat926/rffmpeg/master/rffmpeg -O /usr/local/bin/rffmpeg #my version supports switching hardware acceleration
chmod +x /usr/local/bin/rffmpeg
ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffmpeg
ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffprobe
mkdir -p /etc/rffmpeg
wget https://raw.githubusercontent.com/mat926/rffmpeg/master/rffmpeg.yml.sample -O /etc/rffmpeg/rffmpeg.yml

yq -i 'with(.rffmpeg.directories.persist ; . = "/run" | . style="double")' /etc/rffmpeg/rffmpeg.yml
yq -i 'with(.rffmpeg.directories.state ; . = "/config/rffmpeg" | . style="double")' /etc/rffmpeg/rffmpeg.yml
yq -i 'with(.rffmpeg.directories.owner ; . = "root" | . style="double")' /etc/rffmpeg/rffmpeg.yml
yq -i 'with(.rffmpeg.directories.group ; . = "root" | . style="double")' /etc/rffmpeg/rffmpeg.yml
yq -i 'with(.rffmpeg.remote.user ; . = "dockerlimited" | . style="double")' /etc/rffmpeg/rffmpeg.yml
yq -i 'with(.rffmpeg.logging.logfile ; . = "/config/log/rffmpeg.log" | . style="double")' /etc/rffmpeg/rffmpeg.yml
#yq e '.rffmpeg.logging.debug = true' /etc/rffmpeg/rffmpeg.yml -i
yq -i 'with(.rffmpeg.remote.args[0] ; . = "-i" | . style="double")' /etc/rffmpeg/rffmpeg.yml
yq -i 'with(.rffmpeg.remote.args[1] ; . = "/config/.ssh/id_rsa" | . style="double")' /etc/rffmpeg/rffmpeg.yml

#Restart the container after changing the path
#https://matrix.to/#/!PEnnsqywkTLXsTNlAI:matrix.org/$SyaJz0kwWOGyoHfDAGlt9e_vKvZ4kweM_EwTdIdjLFo?via=bonifacelabs.ca&via=matrix.org
yq -i '.EncodingOptions.EncoderAppPathDisplay = "/usr/local/bin/ffmpeg"' /config/config/encoding.xml


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