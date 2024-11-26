@echo off
set /p confirm=This will setup rffmpeg on the Jellyfin docker image, copy the ssh public key and restart the rffmpeg_server container. Are you sure you want to continue (Y/N)?
if /i "%confirm%" neq "Y" exit /b

set /p user=Enter user and address (user@192.168.0.1):
set /p password=Enter sudo password:

echo Logging into Synology

ssh -t -i %USERPROFILE%\.ssh\id_rsa -p 24 %user% "echo %password% | sudo -S /usr/local/bin/docker exec jellyfin bash -c 'curl https://raw.githubusercontent.com/mat926/rffmpeg/master/rffmpeg_setup.sh -o /config/rffmpeg_setup.sh && chmod +x /config/rffmpeg_setup.sh && /config/rffmpeg_setup.sh' ; sudo -S /usr/local/bin/docker cp jellyfin:/config/.ssh/id_rsa.pub /volume1/docker/jellyfin/id_rsa.pub" || exit /b 1

scp -i %USERPROFILE%\.ssh\id_rsa -O -P 24 %user%:/volume1/docker/jellyfin/id_rsa.pub %USERPROFILE%\.ssh\rffmpeg\id_rsa.pub || exit /b 1

@REM CLEANUP
ssh -t -i %USERPROFILE%\.ssh\id_rsa -p 24 %user% "echo %password% | sudo -S /usr/local/bin/docker exec jellyfin rm /config/rffmpeg_setup.sh; sudo -S rm -f /volume1/docker/jellyfin/id_rsa.pub ; sudo -S /usr/local/bin/docker restart jellyfin" || exit /b 1

docker restart rffmpeg-server || exit /b 1

echo rffmpeg setup complete



