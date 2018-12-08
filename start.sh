#!/bin/bash

# Start the docker network
docker network create nginx-proxy

# Start the nginx-proxy container
docker-compose up -d
