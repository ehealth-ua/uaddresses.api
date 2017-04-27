#!/bin/sh
# `pwd` should be /opt/uaddresses
APP_NAME="uaddresses"

if [ "${DB_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/$APP_NAME command "${APP_NAME}_tasks" migrate!
fi;
