#!/usr/bin/env sh
#PLATFORM_ENVIRONMENT=${ENVIRONMENT:-dev}
#
#python "${APP_HOME}"/params.py -e "${PLATFORM_ENVIRONMENT}" -x > "$HOME"/platform.env
#wc -l "$HOME"/platform.env
#
#MODE=$(echo $MODIFIER $ENVIRONMENT $LABEL | tr ' ' '-')
#export DJANGO_MODE=${MODE:-dev}
#echo "env ${ENVIRONMENT:--}; modifier ${MODIFIER:--}; mode $DJANGO_MODE"
exec "$@"
