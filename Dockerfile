FROM ubuntu:trusty

ENV LANG en_US.UTF-8
RUN locale-gen $LANG

RUN apt-get update -q && \
    apt-get install -qy openjdk-7-jre-headless

ADD http://downloads.sourceforge.net/project/subsonic/subsonic/4.9/subsonic-4.9.deb /tmp/subsonic.deb
ADD http://dilerium.se/musiccabinet/subsonic-installer-standalone.zip /tmp/subsonic-installer-standalone.zip
RUN dpkg -i /tmp/subsonic.deb && \
    rm -rf /tmp/subsonic.deb && \
    mv /var/subsonic /var/subsonic.default && \
    ln -s /data /var/subsonic
    unzip -d /usr/share/subsonic -o /tmp/subsonic-installer-standalone.zip
    rm -rf /tmp/subsonic-installer-standalone.zip && \

# Don't fork to the background
RUN sed -i "s/ > \${LOG} 2>&1 &//" /usr/share/subsonic/subsonic.sh

ADD start.sh /start.sh

VOLUME ["/data"]
EXPOSE 4040

CMD ["/start.sh"]
