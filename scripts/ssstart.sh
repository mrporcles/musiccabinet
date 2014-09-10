#! /bin/sh

set -e

[ ! -L /ssdata/transcode ] && ln -s /var/subsonic.default/transcode /ssdata/transcode

/usr/share/subsonic/subsonic.sh
