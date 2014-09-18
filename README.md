mrporcles/musiccabinet

Description

A Dockerfile for Subsonic version 4.9 with Musiccabinet plugin. Based on aostanin subsonic docker container which can be found here:

https://registry.hub.docker.com/u/aostanin/subsonic/

Musiccabinet requires postgresql. The container I have tested and used successfully is wyaeld/postgres which can be found here:

https://registry.hub.docker.com/u/wyaeld/postgres/

Follow the relevant instructions from the link to establish the server and data containers. Then start the musiccabinet container using the –link PostgresSQL:db option to the postgresql server container. It must be linked using :db to allow the correct ip address to be passed via variable to the container initiation script.

Volumes

Volume to save subsonic/musiccabinet configuration and state.

/data
Ports

Port 4040 is exposed for the Web UI access port
