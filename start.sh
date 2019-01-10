#!/usr/bin/env bash

homeDir=/home/$(whoami)
networkUp=$(docker network ls --filter name=nginx-proxy --format yes)

# Start the docker network
if [ "${networkUp}" != 'yes' ]; then
	echo "Starting docker network nginx-proxy..."
	docker network create nginx-proxy
fi

# Create necessary directories
mkdir -p certs conf.d html vhost.d

# Add wp-cli alias to ~/.bash_aliases if it doesn't exist
if [ ! -e "${homeDir}/.bash_aliases" ]; then
	echo "No .bash_aliases file, skipping..."
else
	if grep -Fq "alias wp-cli=" "${homeDir}/.bash_aliases"; then
		echo "wp-cli alias present, not adding to ${homeDir}/.bash_aliases"
	else
		echo "alias wp-cli='"'docker-compose run --rm wp-cli_${PWD##*/}'"'" >> "${homeDir}/.bash_aliases"
		# shellcheck source="/home/${homeDir}"
		source "${homeDir}/.bash_aliases"
		echo 'wp-cli alias usage: wp-cli_CONTAINER <command/args/opts>'
	fi
fi

# Add vports file
if [ ! -e ./vports ]; then
	touch vports
	echo '# This file is used to register virtual ports. This file is appended to automatically.' > vports
fi

# Make sure postfix is installed
if [ -z "$(command -v postfix)" ]; then
	sudo apt -y install postfix
fi

# /etc/postfix/main.cf
## mynetworks
echo "Setting up host postfix..."
if ! grep -q "^mynetworks.*172.16.0.0/12*" /etc/postfix/main.cf; then
        sudo sed -i.pre-docker -e '/^mynetworks/s/$/ 172.16.0.0\/12/' /etc/postfix/main.cf
fi
# inet_interfaces
if ! grep -q "^inet_interfaces.*172.17.0.1" /etc/postfix/main.cf; then
        sudo sed -i.pre-docker -e '/^inet_interfaces/s/$/, 172.17.0.1/' /etc/postfix/main.cf
fi

# Start the nginx-proxy container
read -r -p "Start nginx-proxy [Y/n]?" start
if [ "${start}" = "y" ] || [ "${start}" = "Y" ]; then
	docker-compose up -d
else
	echo 'nginx-proxy ready!'
fi
