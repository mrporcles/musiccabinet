#! /bin/sh

set -e

[ ! -L /ssdata/transcode ] && ln -s /var/subsonic.default/transcode /ssdata/transcode

sed '/-Dmusiccabinet.log.fileName/ a\ -Dmusiccabinet.jdbc.url=jdbc:postgresql://'$DB_PORT_5432_TCP_ADDR':5432/musiccabinet \\' /usr/share/subsonic/subsonic.sh > /usr/share/subsonic/subsonictmp.sh 
sed '/-Dmusiccabinet.jdbc.url/ a\ -Dmusiccabinet.jdbc.initialurl=jdbc:postgresql://'$DB_PORT_5432_TCP_ADDR':5432/template1 \\' /usr/share/subsonic/subsonictmp.sh > /usr/share/subsonic/subsonicmc.sh

chmod +x /usr/share/subsonic/subsonicmc.sh

/usr/share/subsonic/subsonicmc.sh
