FROM amazoncorretto:17-alpine

RUN apk add unzip curl bash

ENV RCON_VERSION="0.10.3"
ENV RCON_PASSWORD="MY_SECRET_KEY"
ENV EULA=true
ENV RCON_PORT=25575
ENV MINECRAFT_VERSION="1.18.2"
ENV ASTRAL_VERSION="2.0.4c"
ENV FABRIC_VERSION="0.14.14"
ENV FABRIC_INSTALLER_VERSION="0.11.2"
ENV SERVER_ICON=""

# Install RCON CLI client
WORKDIR /tmp
RUN curl -fsSL -o "rcon-cli.tar.gz" https://github.com/gorcon/rcon-cli/releases/download/v${RCON_VERSION}/rcon-${RCON_VERSION}-amd64_linux.tar.gz
RUN tar -xf rcon-cli.tar.gz
RUN install -m 755 rcon-${RCON_VERSION}-amd64_linux/rcon /usr/local/bin/rcon-cli
RUN sed -i "s/address\: \"\"/address\: \"127.0.0.1\:$RCON_PORT\"/g" rcon-${RCON_VERSION}-amd64_linux/rcon.yaml
RUN sed -i "s/password\: \"\"/password\: \"$RCON_PASSWORD\"/g" rcon-${RCON_VERSION}-amd64_linux/rcon.yaml
RUN sed -i "s/type\: \"\"/type\: \"rcon\"/g" rcon-${RCON_VERSION}-amd64_linux/rcon.yaml

RUN install -m 644 rcon-${RCON_VERSION}-amd64_linux/rcon.yaml /etc/rcon.yaml
RUN rm -r /tmp/*

# Clone modpack to /server
WORKDIR /server
RUN curl -fsSL -o "astral_server.zip" "https://mediafilez.forgecdn.net/files/4496/671/Create+Astral+Server+Pack+v${ASTRAL_VERSION}.zip"
RUN unzip "astral_server.zip" && rm "astral_server.zip"

# Download server jar
RUN curl -fsSL -o "server.jar" "https://meta.fabricmc.net/v2/versions/loader/${MINECRAFT_VERSION}/${FABRIC_VERSION}/${FABRIC_INSTALLER_VERSION}/server/jar"

# Configure server.properties
RUN sed -i 's/rcon.password=/rcon.password='$RCON_PASSWORD'/' server.properties
RUN sed -i 's/enable-rcon=false/enable-rcon=true/' server.properties

# Curl the server-icon.png
RUN if [[ -n "$SERVER_ICON" ]]; then curl -o server.icon.png ${SERVER_ICON}; fi

# Copy the entrypoint and make it executable
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

# USER minecraft:minecraft
# RUN chown -R minecraft:minecraft /server
# TODO - CREATE AND SET USER (and make owner of /server and entrypoint)
# TODO - MAKE MULTI-STAGE BUILD

VOLUME ["/server/world"]
EXPOSE 25565
ENTRYPOINT ["/bin/bash", "/server/entrypoint.sh"]