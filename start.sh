#!/usr/bin/env bash

# Start the docker network
networkUp=$(docker network ls --filter name=nginx-proxy --format yes)
if [ "${networkUp}" != 'up' ]; then
	echo "Starting docker network nginx-proxy..."
	docker network create nginx-proxy
fi

# Create necessary directories
mkdir -p certs conf.d html vhost.d

# Add wp-cli alias to ~/.bash_aliases if it doesn't exist
homeDir=/home/$(whoami)
if [ ! -e "${homeDir}/.bash_aliases" ]; then
	touch "${homeDir}/.bash_aliases"
	echo "Added file ${homeDir}/.bash_aliases"
fi

if grep -Fq "alias wp-cli=" "${homeDir}/.bash_aliases"; then
	echo "wp-cli alias present, not adding to ${homeDir}/.bash_aliases"
else
	echo "alias wp-cli='"'docker-compose run --rm wp-cli_${PWD##*/}'"'" >> "${homeDir}/.bash_aliases"
	# shellcheck source="/home/${homeDir}"
	source "${homeDir}/.bash_aliases"
	echo 'wp-cli alias usage: wp-cli_CONTAINER <command/args/opts>'
fi

# Add empty vports file
if [ ! -e ./vports ]; then
	touch vports
	echo '# This file is used to register virtual ports. This file is appended to automatically.' > vports
fi

# Start the nginx-proxy container
docker-compose up -d
