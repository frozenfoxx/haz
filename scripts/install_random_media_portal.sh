#!/usr/bin/env bash

# Variables
RANDOM_MEDIA_PORTAL=${RANDOM_MEDIA_PORTAL:-"https://gitlab.com/frozenfoxx/random-media-portal.git"}
SOFTDIR=${SOFTDIR:-'/opt'}
LOG_PATH=${LOG_PATH:-'/var/log'}
STD_LOG=${STD_LOG:-'install_random_media_portal.log'}

# Functions

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

  # Install the service file
  cp ./etc/systemd/system/random-media-portal.service /etc/systemd/system/
  cp ./etc/systemd/random-media-portal.env /etc/systemd/

  # FIXME: substitute environment variables

  # Reload the service
  systemctl daemon-reload
  systemctl enable random-media-portal.service

  eval echo "The media-portal-badge stack is now installed and ready to go." ${STD_LOG_ARG}
  eval echo "To alter which media to serve check these variables in the /etc/systemd/random-media-portal.env file" ${STD_LOG_ARG}
  eval echo "    MEDIA_DIR              path containing media for the portal" ${STD_LOG_ARG}
  eval echo "    MEDIA_MODE             display mode for the portal" ${STD_LOG_ARG}
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
  cp ./etc/systemd/system/random-media-portal.service /etc/systemd/system/
  cp ./etc/systemd/random-media-portal.env /etc/systemd/

  # FIXME: substitute environment variables

  # Reload the service
  systemctl daemon-reload
  systemctl enable random-media-portal.service

  eval echo "The media-portal-badge stack is now installed and ready to go." ${STD_LOG_ARG}
  eval echo "To alter which media to serve check these variables in the /etc/systemd/random-media-portal.env file" ${STD_LOG_ARG}
  eval echo "    MEDIA_DIR              path containing media for the portal" ${STD_LOG_ARG}
  eval echo "    MEDIA_MODE             display mode for the portal" ${STD_LOG_ARG}
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
  echo "    RANDOM_MEDIA_PORTAL    Git repo for random-media-portal (default: https://gitlab.com/frozenfoxx/random-media-portal.git)"
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