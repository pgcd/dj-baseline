#!/usr/bin/env sh
# You should normally run this file; when offline, you can run dup-nobuild.sh instead to bring up containers without rebuilding (which requires internet)

if [ "$(uname -m)" = 'arm64' ]; then session_manager='arm64'; else session_manager='64bit'; fi

SESSION_MANAGER_ARCH=$session_manager ./dup-nobuild.sh --build "$@"
