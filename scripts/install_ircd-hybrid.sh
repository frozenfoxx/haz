#!/usr/bin/env bash

# Variables
IRC_ADMIN_PASS=${IRC_ADMIN_PASS:-''}
DOCKER=${DOCKER:-'false'}
HAZ_DIR=${HAZ_DIR:-'/opt/haz'}
HAZ_NAME=${HAZ_NAME:-'haz'}
OPER_PASS=${OPER_PASS:-''}
LOG_PATH=${LOG_PATH:-'/var/log'}
STD_LOG=${STD_LOG:-'install_ircd-hybrid.log'}

# Functions

## Configure the server
configure()
{
  eval echo "Setting admin password..." ${STD_LOG_ARG}
  if [[ ${IRC_ADMIN_PASS} == '' ]]; then
    IRC_ADMIN_PASS=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n 1)
    eval echo "Password was not given, generated: ${IRC_ADMIN_PASS}" ${STD_LOG_ARG}
    exit 1
  fi

  ADMIN_PASS_ENCRYPTED=$(/usr/bin/mkpasswd ${IRC_ADMIN_PASS})

  eval echo "Setting operator password..." ${STD_LOG_ARG}
  if [[ ${IRC_OPER_PASS} == '' ]]; then
    IRC_OPER_PASS=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n 1)
    eval echo "Password was not given, generated: ${IRC_OPER_PASS}" ${STD_LOG_ARG}
    exit 1
  fi

  OPER_PASS_ENCRYPTED=$(/usr/bin/mkpasswd ${IRC_OPER_PASS})

  # Export the values for envsubst
  export ADMIN_PASS_ENCRYPTED
  export OPER_PASS_ENCRYPTED
  export HAZ_NAME

  eval echo "Configuring ircd-hybrid server..." ${STD_LOG_ARG}
  envsubst < ${HAZ_DIR}/configs/etc/ircd-hybrid/ircd.conf.tmpl > /etc/ircd-hybrid/ircd.conf

  # Check if systemd needs to be configured
  if [[ ${OSTYPE} == "linux-gnu"* ]]; then
    if [[ ${DOCKER} == 'false' ]]; then
      configure_systemd
    fi
  fi
}

## Configure systemd
configure_systemd()
{
  # Install the service file
  cp ${HAZ_DIR}/configs/etc/systemd/system/ircd.service /etc/systemd/system/

  # Reload the service
  systemctl daemon-reload
  systemctl enable ircd.service
}

## Install the ircd-hybrid server
install()
{
  eval echo "Installing ircd-hybrid..." ${STD_LOG_ARG}

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
  echo "    IRC_ADMIN_PASS         plaintext password for the admin account"
  echo "    IRC_OPER_PASS          plaintext password for the operator account"
  echo "    LOG_PATH               path for logs (default: '/var/log')"
  echo "  Options:"
  echo "    -h | --help            display this usage information"
  echo "    -L | --Log             enable logging (target: '[LOG_PATH]/install_ircd-hybrid.log')"
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
configure
