#!/bin/bash

set -x
set -e

DOCKER_COMPOSE_VERSION="1.10.0"
DOCKER_COMPOSE_IMAGE="docker/compose:${DOCKER_COMPOSE_VERSION}"

DOCKER_SOCKET="/var/run/docker.sock"

if [ $# -lt 4 ]; then
	echo "Incorrect number of parameters."
	echo "Usage: $(basename "$0") [data dir] [yaml-file path] [compose command] <compose args...> [compose service] <service command> <service args...>" 
	echo "Exiting now."
	exit 1
fi

DOCKER_COMPOSE_DATA_DIR="$(readlink -m "$1")"
if [ ! -d "$DOCKER_COMPOSE_DATA_DIR" ]; then
	echo "Error: directory [data dir] ${DOCKER_COMPOSE_DATA_DIR} not found."
	echo "Exiting now."
	exit 2
fi

DOCKER_COMPOSE_YAML_FILE="$(readlink -m "$2")"
if [ ! -f "$DOCKER_COMPOSE_YAML_FILE" ]; then
	echo "Error: file [yaml-file path] ${DOCKER_COMPOSE_YAML_FILE} not found."
	echo "Exiting now."
	exit 3
fi

docker run -it --rm \
	-e "DOCKER_SOCKET=${DOCKER_SOCKET}" \
	-e "DOCKER_COMPOSE_DATA_DIR=${DOCKER_COMPOSE_DATA_DIR}" \
	--env-file <(env) \
	-v "${DOCKER_SOCKET}:${DOCKER_SOCKET}" \
	-v "${DOCKER_COMPOSE_DATA_DIR}:${DOCKER_COMPOSE_DATA_DIR}" \
	-w "${DOCKER_COMPOSE_DATA_DIR}" \
	"$DOCKER_COMPOSE_IMAGE" \
		-f "$DOCKER_COMPOSE_YAML_FILE" \
		"${@:3}"

