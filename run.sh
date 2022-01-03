#!/bin/sh

export ENVIRONMENT='production'

# Binds to any ip/interface on the specified port - e.g. http://localhost:3001
 ./wander-favorites-server.pl daemon -l http://*:3001
