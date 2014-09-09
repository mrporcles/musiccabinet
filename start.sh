#! /bin/sh

set -e

[ ! -L /data/transcode ] && ln -s /var/subsonic.default/transcode /data/transcode

#sed '/-Dmusiccabinet.log.fileName/ a\ -Dmusiccabinet.jdbc.url=jdbc:postgresql://$DB_PORT_5432_TCP_ADDR:5432/musiccabinet \\' /usr/share/subsonic/subsonic.sh > /usr/share/subsonic/subsonic.sh 
#sed '/-Dmusiccabinet.log.fileName/ a\ -Dmusiccabinet.jdbc.initialurl=jdbc:postgresql://$DB_PORT_5432_TCP_ADDR:5432/template1 \\' /usr/share/subsonic/subsonic.sh > /usr/share/subsonic/subsonic.sh

echo $DB_PORT_5432_TCP_ADDR:5432

/usr/share/subsonic/subsonic.sh
