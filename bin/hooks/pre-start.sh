#!/bin/sh
# `pwd` should be /opt/uaddresses_api
APP_NAME="uaddresses_api"

if [ "${DB_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/$APP_NAME command Elixir.Uaddresses.ReleaseTasks migrate
fi;
