#!/usr/bin/env sh
# Since we use this file as a BIND, we need to make sure it exists
touch docker/bash_history.txt

GIT_HASH="$(git rev-parse --short=12 HEAD)" GIT_USER="$(git config --get user.email)" GIT_LABEL="$(git log --oneline -n 8)" docker compose --env-file docker/.env up --remove-orphans -d "$@"

