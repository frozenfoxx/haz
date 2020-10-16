#!/usr/bin/env bash

# Variables
NODOGSPLASH=${NODOGSPLASH:-'https://github.com/nodogsplash/nodogsplash.git'}
SOFTDIR=${SOFTDIR:-'/opt'}
LOG_PATH=${LOG_PATH:-'/var/log'}
STD_LOG=${STD_LOG:-'install_nodogsplash.log'}

# Functions

## Configure nodogsplash
configure_nodogsplash()
{
  eval echo "Configuring nodogsplash..." ${STD_LOG_ARG}
}

## Install nodogsplash
install_nodogsplash()
{
  eval echo "Installing nodogsplash..." ${STD_LOG_ARG}

  # Change to a directory for optional software
  cd ${SOFTDIR}

  # Install core tools
  apt-get install -y \
    build-essential \
    debhelper \
    devscripts \
    dh-systemd \
    libmicrohttpd-dev

  # Retrieve nodogsplash
  git clone ${NODOGSPLASH}

  # Build a package
  cd $(basename ${NODOGSPLASH} | sed 's/\.git$//g')
  dpkg-buildpackage

  # Install package
  dpkg -i ../*.deb
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
  echo "    NODOGSPLASH            Git repo for nodogsplash (default: https://github.com/nodogsplash/nodogsplash.git)"
  echo "  Options:"
  echo "    -h | --help            display this usage information"
  echo "    -L | --Log             enable logging (target: '[LOG_PATH]/install_nodogsplash.log')"
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

install_nodogsplash
configure_nodogsplash