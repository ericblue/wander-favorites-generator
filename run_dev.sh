#!/bin/sh

export ENVIRONMENT='development'

# Binds to any ip/interface on the specified port - e.g. http://localhost:3000
# Runs with caching off so HTML/JS changes can be made on the fly
#./wander-favorites-server.pl daemon -l http://*:3000

morbo -w ./ -l http://[::]:3000 ./wander-favorites-server.pl

