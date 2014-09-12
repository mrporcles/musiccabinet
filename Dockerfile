FROM ubuntu:trusty

ENV LANG en_US.UTF-8
RUN locale-gen $LANG
ENV POSTGRES_VERSION 9.3

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc 
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
  echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main $POSTGRES_VERSION" > /etc/apt/sources.list.d/pgdg.list && \
  apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get -qy install language-pack-en && \
    export LANGUAGE=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    export LC_ALL=en_US.UTF-8 && \
    apt-get clean && \
    rm -Rf /var/cache/apt && \
    DEBIAN_FRONTEND=noninteractive locale-gen en_US.UTF-8 &&\
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales &&\
    update-locale LANG=en_US.UTF-8

RUN LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libpq5 \
    postgresql-$POSTGRES_VERSION \
    postgresql-client-$POSTGRES_VERSION \
    postgresql-contrib-$POSTGRES_VERSION && \
    apt-get clean && \
    rm -Rf /var/cache/apt

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible. 
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf

# Note: This container has no native volume, its expected to run with --volumes-from another

EXPOSE 5432

# SUBSONIC STARTS HERE
RUN apt-get update -q && \
    apt-get install -qy openjdk-7-jre-headless && \
    apt-get install -qy unzip

ADD http://downloads.sourceforge.net/project/subsonic/subsonic/4.9/subsonic-4.9.deb /tmp/subsonic.deb
ADD http://dilerium.se/musiccabinet/subsonic-installer-standalone.zip /tmp/subsonic-installer-standalone.zip

RUN dpkg -i /tmp/subsonic.deb && \
    rm -rf /tmp/subsonic.deb && \
    mv /var/subsonic /var/subsonic.default && \
    ln -s /data /var/subsonic && \
    unzip -d /usr/share/subsonic -o /tmp/subsonic-installer-standalone.zip && \
    mv -f /usr/share/subsonic/subsonic-installer-standalone/* /usr/share/subsonic/. && \
    rm -rf /usr/share/subsonic/subsonic-installer-standalone && \
    rm -rf /tmp/subsonic-installer-standalone.zip

# Don't fork to the background
RUN sed -i "s/ > \${LOG} 2>&1 &//" /usr/share/subsonic/subsonic.sh

ADD start.sh /start.sh
RUN chmod +x /start.sh && \
    chmod +x /usr/share/subsonic/subsonic.sh

VOLUME ["/data","/var/lib/postgresql/9.3/main","etc/postgresql/9.3/main"]
EXPOSE 4040

CMD ["/start.sh"]
