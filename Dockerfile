# Use the official Jellyfin image as the base image
FROM jellyfin/jellyfin:latest

#Make sure line endings are LF
COPY  /rffmpeg /usr/local/bin/rffmpeg
COPY  /rffmpeg.yml.sample /etc/rffmpeg/rffmpeg.yml

# Update package list and install yq
RUN apt update && \
    curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/bin/yq && \
    chmod +x /usr/bin/yq && \
    #rffmpeg installation
    apt install -y openssh-client python3-click python3-yaml python3-requests && \
    chmod +x /usr/local/bin/rffmpeg && \
    ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffmpeg && \
    ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffprobe && \
    yq -i 'with(.rffmpeg.directories.persist ; . = "/run" | . style="double")' /etc/rffmpeg/rffmpeg.yml && \
    yq -i 'with(.rffmpeg.directories.state ; . = "/config/rffmpeg" | . style="double")' /etc/rffmpeg/rffmpeg.yml && \
    yq -i 'with(.rffmpeg.directories.owner ; . = "root" | . style="double")' /etc/rffmpeg/rffmpeg.yml && \
    yq -i 'with(.rffmpeg.directories.group ; . = "root" | . style="double")' /etc/rffmpeg/rffmpeg.yml && \
    yq -i 'with(.rffmpeg.remote.user ; . = "dockerlimited" | . style="double")' /etc/rffmpeg/rffmpeg.yml && \
    yq e '.rffmpeg.logging.debug = true' /etc/rffmpeg/rffmpeg.yml -i && \
    yq -i 'with(.rffmpeg.logging.logfile ; . = "/config/log/rffmpeg.log" | . style="double")' /etc/rffmpeg/rffmpeg.yml && \
    yq -i 'with(.rffmpeg.remote.args[0] ; . = "-i" | . style="double")' /etc/rffmpeg/rffmpeg.yml && \
    yq -i 'with(.rffmpeg.remote.args[1] ; . = "/config/.ssh/id_rsa" | . style="double")' /etc/rffmpeg/rffmpeg.yml && \
    rffmpeg init -y

CMD [ "--ffmpeg", "/usr/local/bin/ffmpeg" ]