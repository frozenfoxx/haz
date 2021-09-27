#!/usr/bin/env bash

# Variables
HAZ_DIR=${HAZ_DIR:-'/opt/haz'}
HAZ_NAME=${HAZ_NAME:-'haz'}
NET_GATEWAY=${NET_GATEWAY:-'192.168.4.1'}
NET_IFACE=${NET_IFACE:-'wlan0'}
NODOGSPLASH=${NODOGSPLASH:-'https://github.com/nodogsplash/nodogsplash.git'}
SOFTDIR=${SOFTDIR:-'/opt'}
LOG_PATH=${LOG_PATH:-'/var/log'}
STD_LOG=${STD_LOG:-'install_nodogsplash.log'}

# Functions

## Cleanup nodgosplash installation
cleanup()
{
  # Remove tools
  apt-get autoremove -y \
    build-essential \
    debhelper \
    devscripts \
    dh-systemd \
    libmicrohttpd-dev

  # Remove build directory and package
  rm -rf ${SOFTDIR}/nodogsplash
  rm ${SOFTDIR}/*.deb
}

## Configure nodogsplash
configure()
{
  eval echo "Configuring nodogsplash..." ${STD_LOG_ARG}

  if [ ! /etc/nodogsplash ]; then
    eval echo "Creating configuration directory..." ${STD_LOG_ARG}
    mkdir -p /etc/nodogsplash
  fi

  # Export the values for envsubst
  export HAZ_NAME
  export NET_GATEWAY
  export NET_IFACE

  envsubst < ${HAZ_DIR}/configs/etc/nodogsplash/nodogsplash.conf.tmpl > /etc/nodogsplash/nodogsplash.conf

  eval echo "Setting up splash pages..." ${STD_LOG_ARG}
  cp -r ${HAZ_DIR}/configs/etc/nodogsplash/htdocs/* /etc/nodogsplash/htdocs/
}

## Install nodogsplash
install()
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
  git clone ${NODOGSPLASH} ${SOFTDIR}/nodogsplash

  # Build a package
  cd ${SOFTDIR}/nodogsplash
  dpkg-buildpackage -b -rfakeroot -us -uc

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

install
configure
cleanup
