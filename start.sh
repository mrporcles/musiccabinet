#! /bin/sh

set -e

[ ! -L /data/transcode ] && ln -s /var/subsonic.default/transcode /data/transcode

sed '/-Dmusiccabinet.log.fileName/ a\ -Dmusiccabinet.jdbc.url=jdbc:postgresql://'$DB_PORT_5432_TCP_ADDR':5432/musiccabinet \\' /usr/share/subsonic/subsonic.sh > /usr/share/subsonic/subsonictmp.sh 
sed '/-Dmusiccabinet.jdbc.url/ a\ -Dmusiccabinet.jdbc.initialurl=jdbc:postgresql://'$DB_PORT_5432_TCP_ADDR':5432/template1 \\' /usr/share/subsonic/subsonictmp.sh > /usr/share/subsonic/subsonicmc.sh

chmod +x /usr/share/subsonic/subsonicmc.sh

useradd postgres -p postgres

/usr/share/subsonic/subsonicmc.sh
