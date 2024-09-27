#!/bin/bash
set -eo pipefail
shopt -s nullglob

echo "$@"

"/etc/init.d/chariot" start &

mkdir -p /opt/chariot/log/
touch /opt/chariot/log/wrapper.log
tail -f /opt/chariot/log/wrapper.log