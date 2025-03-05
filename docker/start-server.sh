#!/usr/bin/env sh
. ~/platform.env
OWNIP=$(curl -s "${ECS_CONTAINER_METADATA_URI}" | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
export DJANGO_EXTRA_ALLOWED_HOSTS="${EXTRA_ALLOWED_HOSTS:-localhost},$OWNIP"  # This allows the healthcheck to go through
gunicorn {{ project_name }}.wsgi -c /code/src/gunicorn.conf.py --bind 0.0.0.0:8000 $GUNICORN_CMD  # Turns out you can't use port 80, of course
