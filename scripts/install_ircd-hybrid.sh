#!/usr/bin/env bash

# Variables
PASSWORD=${PASSWORD:-''}
SOFTDIR=${SOFTDIR:-'/opt'}
LOG_PATH=${LOG_PATH:-'/var/log'}
STD_LOG=${STD_LOG:-'install_ircd-hybrid.log'}

# Functions

## Configure the server
configure()
{
  eval echo "Setting password..." ${STD_LOG_ARG}
  if [[ ${PASSWORD} == '' ]]; then
    eval echo "Password must not be null." ${STD_LOG_ARG}
    exit 1
  fi

  ENCRYPTED_PASS=$(/usr/bin/mkpasswd ${PASSWORD})
}

## Install the ircd-hybrid server
install()
{
  eval echo "Installing ircd-hybrid..." ${STD_LOG_ARG}

  # Change to a directory for optional software
  cd ${SOFTDIR}
  
  # Install
  apt-get install -y \
    ircd-hybrid
}

## Set logging on
set_logging()
{
  echo "Running with logging option..."
  STD_LOG_ARG=">>${LOG_PATH}/${STD_LOG}"
}

## Display usage information
usage()
{
  echo "Usage: [Environment Variables] ./install_ircd-hybrid.sh [-hL]"
  echo "  Environment Variables:"
  echo "    LOG_PATH               path for logs (default: '/var/log')"
  echo "  Options:"
  echo "    -h | --help            display this usage information"
  echo "    -L | --Log             enable logging (target: '[LOG_PATH]/install_ircd-hybrid.log')"
}

# Logic

## Argument parsing
while [[ "$1" != "" ]]; do
  case $1 in
    -L | --Log )  set_logging
                  ;;
    -h | --help ) usage
                  exit 0
  esac
  shift
done

install
configure