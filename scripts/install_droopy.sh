#!/usr/bin/env bash

# Variables
DOCKER=${DOCKER:-'false'}
DROOPY=${DROOPY:-"https://github.com/frozenfoxx/droopy.git"}
DROOPY_DIRECTORY=${DROOPY_DIRECTORY:'/data'}
DROOPY_PORT=${DROOPY_PORT:-'8020'}
HAZ_DIR=${HAZ_DIR:-'/opt/haz'}
SOFTDIR=${SOFTDIR:-'/opt'}
LOG_PATH=${LOG_PATH:-'/var/log'}
STD_LOG=${STD_LOG:-'install_droopy.log'}

# Functions

## Build the environment file
build_environment_file()
{
  envsubst < ${HAZ_DIR}/configs/etc/default/droopy.tmpl > /etc/default/droopy
  chmod 640 /etc/default/droopy
}

## Configure systemd
configure_systemd()
{
  # Install the service file
  cp ${HAZ_DIR}/configs/etc/systemd/system/droopy.service /etc/systemd/system/

  # Reload the service
  systemctl daemon-reload
  systemctl enable droopy.service
}

## Display finish message
finish_message()
{
  eval echo "Droopy is now installed and ready to go." ${STD_LOG_ARG}
  eval echo "To alter which media to serve check these variables in the /etc/default/droopy file" ${STD_LOG_ARG}
  eval echo "    DROOPY_DIRECTORY       path containing uploads" ${STD_LOG_ARG}
  eval echo "    DROOPY_PORT            port for the server" ${STD_LOG_ARG}
}

## Install random-media-portal
install()
{
  eval echo "Installing the droopy..." ${STD_LOG_ARG}

  # Change to a directory for optional software
  cd ${SOFTDIR}
  
  # Pull a copy of the latest random-media-portal
  git clone ${DROOPY} ${SOFTDIR}/droopy
  cd ${SOFTDIR}/droopy

  # Build environment
  build_environment_file

  # Check if systemd needs to be configured
  if [[ ${OSTYPE} == "linux-gnu"* ]]; then
    if [[ ${DOCKER} == 'false' ]]; then
      configure_systemd
    fi
  fi
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
  echo "Usage: [Environment Variables] ./install.sh [-hL]"
  echo "  Environment Variables:"
  echo "    DROOPY                 Git repo for droopy (default: https://github.com/frozenfoxx/Droopy.git)"
  echo "    DROOPY_DIRECTORY       directory for uploads (default: /data)"
  echo "    DROOPY_PORT            port for the server (default: 8020)"
  echo "    LOG_PATH               path for logs (default: '/var/log')"
  echo "  Options:"
  echo "    -h | --help            display this usage information"
  echo "    -L | --Log             enable logging (target: '[LOG_PATH]/install_droopy.log')"
}

# Logic

## Argument parsing
while [[ "$1" != "" ]]; do
  case $1 in
    -docker )     DOCKER='true'
                  ;;
    -h | --help ) usage
                  exit 0
                  ;;
    -L | --Log )  set_logging
  esac
  shift
done

install
finish_message
