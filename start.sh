#!/usr/bin/env bash

# Start the docker network
network_up=$(docker network ls --filter name=nginx-proxy --format yes)
if [ "${network_up}" != 'up' ]; then
	echo "Starting docker network nginx-proxy..."
	docker network create nginx-proxy
fi

# Create necessary directories
mkdir -p certs conf.d html vhost.d

# Add wp-cli alias to ~/.bash_aliases if it doesn't exist
if [ ! -e ~/.bash_aliases ]; then
	touch ~/.bash_aliases
	echo "Added file ~/.bash_aliases"
fi

if grep -Fq "alias wp-cli=" ~/.bash_aliases; then
	echo "wp-cli alias present, not adding to ~/.bash_aliases"
else
	echo "alias wp-cli='"'docker-compose run --rm wp-cli_${PWD##*/}'"'" >> ~/.bash_aliases
	source ~/.bash_aliases
	echo "wp-cli alias usage: wp-cli <command/args/opts>"
fi

# Add empty vports file
if [ ! -e ./vports ]; then
	touch vports
fi

# Start the nginx-proxy container
docker-compose up -d
