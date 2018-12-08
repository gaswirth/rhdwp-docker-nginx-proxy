#!/bin/bash

# Start the docker network
docker network create nginx-proxy

# Create necessary directories
mkdir -p {\
	certs, \
	conf.d, \
	html, \
	vhost.d \
}

# Start the nginx-proxy container
docker-compose up -d
