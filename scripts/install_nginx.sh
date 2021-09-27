#!/usr/bin/env bash

# Variables
DOCKER=${DOCKER:-'false'}
HAZ_DIR=${HAZ_DIR:-'/opt/haz'}
HAZ_NAME=${HAZ_NAME:-'haz'}
LOG_PATH=${LOG_PATH:-'/var/log'}
STD_LOG=${STD_LOG:-'install_nginx.log'}

# Functions

## Set up systemd
configure_systemd()
{
  # Start the service
  systemctl start nginx
  systemctl enable nginx
}

## Create SSL certificates
generate_cert()
{
  eval echo "Generating self-signed SSL certificate..." ${STD_LOG_ARG}
  cp ${HAZ_DIR}/configs/root/localhost.openssl.conf /root/

  # Create the certificate and key
  cd /root
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config localhost.openssl.conf

  # Move those to the SSL directory
  mv localhost.crt /etc/ssl/certs/
  mv localhost.key /etc/ssl/private/localhost.key
}

## Set up and configure nginx
install()
{
  # Export the values for envsubst
  export HAZ_NAME

  eval echo "Configuring nginx templates..." ${STD_LOG_ARG}
  envsubst < ${HAZ_DIR}/configs/etc/nginx/sites-available/index.conf.tmpl > ${HAZ_DIR}/configs/etc/nginx/sites-available/index.conf
  envsubst < ${HAZ_DIR}/configs/etc/nginx/sites-available/random-media-portal.conf.tmpl > ${HAZ_DIR}/configs/etc/nginx/sites-available/random-media-portal.conf
  envsubst < ${HAZ_DIR}/configs/etc/nginx/sites-available/upload.conf.tmpl > ${HAZ_DIR}/configs/etc/nginx/sites-available/upload.conf

  eval echo "Configuring nginx..." ${STD_LOG_ARG}
  cp ${HAZ_DIR}/configs/etc/nginx/sites-available/*.conf /etc/nginx/sites-available/

  eval echo "Configuring index..." ${STD_LOG_ARG}
  mkdir -p /var/www/html
  chmod 0755 /var/www/html

  envsubst < ${HAZ_DIR}/configs/var/www/html/index.html.tmpl > /var/www/html/index.html
  chmod 0644 /var/www/html/index.html

  # Enable the new sites
  ln -s /etc/nginx/sites-available/index.conf /etc/nginx/sites-enabled/index.conf
  ln -s /etc/nginx/sites-available/random-media-portal.conf /etc/nginx/sites-enabled/random-media-portal.conf
  ln -s /etc/nginx/sites-available/upload.conf /etc/nginx/sites-enabled/upload.conf

  # Disable the default welcome
  if [[ -f /etc/nginx/sites-enabled/default ]]; then
    rm /etc/nginx/sites-enabled/default
  fi

  # Check if systemd needs to be configured
  if [[ ${OSTYPE} == "linux-gnu"* ]]; then
    if [[ ${DOCKER} == 'false' ]]; then
      configure_systemd
    fi
  fi
}

## Ensure all dependencies are met
install_dependencies()
{
    apt-get install -y \
      nginx
}

## Display usage information
usage()
{
  echo "Usage: [Environment Variables] ./install.sh [-hL]"
  echo "  Environment Variables:"
  echo "    LOG_PATH               path for logs (default: '/var/log')"
  echo "  Options:"
  echo "    -h | --help            display this usage information"
  echo "    -L | --Log             enable logging (target: '[LOG_PATH]/install_nginx.log')"
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

install_dependencies
generate_cert
install
