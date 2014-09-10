# MusicCabinet (Subsonic/PostgresSQL) (http://www.postgresql.org/)

FROM phusion/baseimage:0.9.13
MAINTAINER Paul Wiggett <mrporcles@gmail.com>

# Ensure we create the cluster with UTF-8 locale
RUN locale-gen en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# Disable SSH (Not using it at the moment).
# RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Install the latest postgresql
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes \
        postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 && \
    /etc/init.d/postgresql stop
    
# Install JRE & Unzip
RUN apt-get install -qy openjdk-7-jre-headless && \
	apt-get install -qy unzip

# Install other tools.
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y pwgen inotify-tools

# Download Subsonic & MusicCabinet
ADD http://downloads.sourceforge.net/project/subsonic/subsonic/4.9/subsonic-4.9.deb /tmp/subsonic.deb
ADD http://dilerium.se/musiccabinet/subsonic-installer-standalone.zip /tmp/subsonic-installer-standalone.zip

# Install Subsonic & Musiccabinet\
RUN dpkg -i /tmp/subsonic.deb && \
    rm -rf /tmp/subsonic.deb && \
    mv /var/subsonic /var/subsonic.default && \
    ln -s /ssdata /var/subsonic && \
    unzip -d /usr/share/subsonic -o /tmp/subsonic-installer-standalone.zip && \
    mv -f /usr/share/subsonic/subsonic-installer-standalone/* /usr/share/subsonic/. && \
    rm -rf /usr/share/subsonic/subsonic-installer-standalone && \
    rm -rf /tmp/subsonic-installer-standalone.zip

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Cofigure the database to use our data dir.
RUN sed -i -e"s/data_directory =.*$/data_directory = '\/pgdata'/" /etc/postgresql/9.3/main/postgresql.conf
# Allow connections from anywhere.
RUN sed -i -e"s/^#listen_addresses =.*$/listen_addresses = '*'/" /etc/postgresql/9.3/main/postgresql.conf
RUN echo "host    all    all    0.0.0.0/0    md5" >> /etc/postgresql/9.3/main/pg_hba.conf

# Expose PostGres & Subsonic Ports
EXPOSE 5432
EXPOSE 4040
ADD scripts /scripts
RUN chmod +x /scripts/pgstart.sh && \
	chmod +x /scripts/ssstart.sh && \
	chmod +x /usr/share/subsonic.sh

RUN touch /firstrun

# Don't fork subsonic to the background
RUN sed -i "s/ > \${LOG} 2>&1 &//" /usr/share/subsonic/subsonic.sh

# Add daemon to be run by runit.
RUN mkdir /etc/service/postgresql
RUN mkdir /etc/service/subsonic
RUN ln -s /scripts/ssstart.sh /etc/service/subsonic/run
RUN ln -s /scripts/pgstart.sh /etc/service/postgresql/run

# Expose our data, log, and configuration directories.
VOLUME ["/pgdata", "/ssdata", "/var/log/postgresql", "/etc/postgresql"]

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
