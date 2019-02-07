#!/usr/bin/env bash
#set -x

homeDir=/home/$(whoami)
networkUp=$(docker network ls --filter name=nginx-proxy --format yes)

# Start the docker network
if [ "${networkUp}" != 'yes' ]; then
	echo "Starting docker network nginx-proxy..."
	docker network create nginx-proxy
fi

# Create necessary directories
mkdir -p certs conf.d html htpasswd vhost.d

# Add wp-cli alias to ~/.bash_aliases if it doesn't exist
read -p "WP-CLI alias prefix (leave blank to skip): " wpcli_prefix
if [ ! -z "${wpcli_prefix}" ]; then
	if [ ! -e "${homeDir}/.bash_aliases" ]; then
		echo "No .bash_aliases file, skipping..."
	else
		if grep -Fq "alias ${wpcli_prefix}=" "${homeDir}/.bash_aliases"; then
			echo "${wpcli_prefix} alias present, not adding to ${homeDir}/.bash_aliases"
		else
			echo "alias ${wpcli_alias}='docker-compose run --rm wp-cli'" >> "${homeDir}/.bash_aliases"
			source "${homeDir}/.bash_aliases"
		fi
	fi

else
	echo "No wp-cli alias specified, skipping."
fi

# Nginx customizations
echo "client_max_body_size 50m;" > conf.d/custom_proxy_settings.conf
echo "client_body_buffer_size 50m;" > conf.d/custom_proxy_settings.conf

# Make sure postfix is installed
if [ -z "$(command -v postfix)" ]; then
	sudo apt -y install postfix
fi

# Start the nginx-proxy container
read -r -p "Start nginx-proxy [Y/n]?" start
if [ "${start}" = "y" ] || [ "${start}" = "Y" ]; then
	docker-compose up -d
else
	echo 'nginx-proxy ready!'
fi
