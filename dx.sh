#!/usr/bin/env bash

# You can pass some env variables to the process being run - namely, the DJANGO_* ones - simply by prepending them to
# the command, eg:
# DJANGO_CRIT_CSS_PASSWORD=passwerdx ./dfab.sh critical_css
# or
# DJANGO_MODE=eventsofa ./ddj.sh runserver 0:9037

declare -a envvars
envvars+=(-e GIT_HASH="$(git rev-parse --short=12 HEAD)")
envvars+=(-e GIT_USER="$(git config --get user.email)")

for django_var in ${!DJANGO_@}
do
  envvars+=(-e "${django_var}=${!django_var}")
done

docker compose --env-file docker/.env exec "${envvars[@]}" "${CNT:-{{ project_name }}}" "$@"
