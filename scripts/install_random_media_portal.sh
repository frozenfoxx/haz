#!/usr/bin/env bash

# Variables
HAZ_DIR=${HAZ_DIR:-'/opt/haz'}
MEDIA_DIRECTORY=${MEDIA_DIRECTORY:'/data'}
MEDIA_MODE=${MEDIA_MODE:-'video'}
RANDOM_MEDIA_PORTAL=${RANDOM_MEDIA_PORTAL:-"https://github.com/frozenfoxx/random-media-portal.git"}
SOFTDIR=${SOFTDIR:-'/opt'}
LOG_PATH=${LOG_PATH:-'/var/log'}
STD_LOG=${STD_LOG:-'install_random_media_portal.log'}

# Functions

## Build the environment file
build_environment()
{
  envsubst < ${HAZ_DIR}/templates/random-media-portal.tmpl > /etc/default/random-media-portal
  chmod 640 /etc/default/random-media-portal
}

## Display finish message
finish_message()
{
  eval echo "The media-portal-badge stack is now installed and ready to go." ${STD_LOG_ARG}
  eval echo "To alter which media to serve check these variables in the /etc/default/random-media-portal file" ${STD_LOG_ARG}
  eval echo "    MEDIA_DIRECTORY        path containing media for the portal" ${STD_LOG_ARG}
  eval echo "    MEDIA_MODE             display mode for the portal" ${STD_LOG_ARG}
}

## Install random-media-portal
install()
{
  if [[ ${OSTYPE} == "linux-gnu"* ]]; then
    if [[ $(grep -q docker /proc/1/cgroup) ]]; then
      install_docker
    else
      install_linux
    fi
  else
    echo "Platform not supported."
    exit 1
  fi
}

## Install for Docker
install_docker()
{
  eval echo "Installing the random-media-portal..." ${STD_LOG_ARG}

  # Change to a directory for optional software
  cd ${SOFTDIR}
  
  # Pull a copy of the latest random-media-portal
  git clone ${RANDOM_MEDIA_PORTAL} ${SOFTDIR}/random-media-portal
  cd ${SOFTDIR}/random-media-portal
  bundle install --system

  # Build environment
  build_environment
}

## Install for Linux
install_linux()
{
  eval echo "Installing the random-media-portal..." ${STD_LOG_ARG}

  # Change to a directory for optional software
  cd ${SOFTDIR}
  
  # Pull a copy of the latest random-media-portal
  git clone ${RANDOM_MEDIA_PORTAL} ${SOFTDIR}/random-media-portal
  cd ${SOFTDIR}/random-media-portal
  bundle install --system

  # Install the service file
  cp ${HAZ_DIR}/configs/etc/systemd/system/random-media-portal.service /etc/systemd/system/

  # Build environmenet
  build_environment

  # Reload the service
  systemctl daemon-reload
  systemctl enable random-media-portal.service
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
  echo "    LOG_PATH               path for logs (default: '/var/log')"
  echo "    RANDOM_MEDIA_PORTAL    Git repo for random-media-portal (default: https://github.com/frozenfoxx/random-media-portal.git)"
  echo "  Options:"
  echo "    -h | --help            display this usage information"
  echo "    -L | --Log             enable logging (target: '[LOG_PATH]/install_random_media_portal.log')"
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
finish_message