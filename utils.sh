#!/usr/bin/env bash
#
# Shared functions and variables across scripts.

shopt -s inherit_errexit
set -o errexit
set -o pipefail
set -o nounset

readonly CI=${CI:-false}
# Get non-root username
MY_USER=$(getent passwd "1000" | cut -d: -f1)
readonly MY_USER

WORKSPACE="$(pwd)"
readonly WORKSPACE
readonly LOG_DIR="$WORKSPACE/log"
mkdir -p "$LOG_DIR"

timestamp() {
  # Default timezone to date's built-in format
  # mac outputs code e.g. CET whereas Linux as time difference +08
  local timezone=%Z
  # Set timezone to contents of system file if exists
  if [ -f /etc/timezone ]; then
    timezone=$(cat /etc/timezone)
  fi
  date "+%a %b %d %I:%M:%S %p $timezone %Y"
}

fancy_echo() {
  echo
  timestamp
  echo "[LINTERS] ==> $1"
  echo
}

err_exit() {
  echo
  echo "ERROR: $1"
  echo
  exit 1
}

check_sudo() {
  if [ "$USER" != root ]; then
    err_exit "Please run script using sudo."
  fi
}

fix_permissions() {
  fancy_echo "Setting permissions in $1 to $MY_USER:$MY_USER"
  sudo chown -R "$MY_USER:$MY_USER" "$1"
}

summary() {
  fancy_echo "Logs written to $LOG_FILENAME"
  fancy_echo "Done"
}
