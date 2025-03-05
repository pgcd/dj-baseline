#!/usr/bin/env sh
. ~/platform.env
celery -A {{ project_name }} beat
