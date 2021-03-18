#!/usr/bin/env bash

# Variables
DEBIAN_FRONTEND="noninteractive"
HAZ_DIR=${HAZ_DIR:-'/opt/haz'}
HOSTNAME=$(hostname)
NET_CHANNEL=${NET_CHANNEL:-'6'}
NET_DRIVER=${NET_DRIVER:-'nl80211'}
NET_HWMODE=${NET_HWMODE:-'g'}
NET_IFACE=${NET_IFACE:-'wlan0'}
NET_SSID=${NET_SSID:-'haz'}
SOFTDIR=${SOFTDIR:-'/opt'}
LOG_PATH=${LOG_PATH:-'/var/log'}
STD_LOG=${STD_LOG:-'install_haz.log'}

# Functions

## Configure dhcpcd
configure_dhcpcd()
{
  eval echo "Configuring dhcpcd..." ${STD_LOG_ARG}

  # Backup original config and install our own
  mv /etc/dhcpcd.conf /etc/dhcpcd.conf.orig
  cp ${HAZ_DIR}/configs/etc/dhcpcd.conf /etc/dhcpcd.conf
}

# Set up and configure dnsmasq
configure_dnsmasq()
{
  eval echo "Configuring dnsmasq..." ${STD_LOG_ARG}

  # Backup original config and install our own
  mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
  cp ${HAZ_DIR}/configs/etc/dnsmasq.conf /etc/dnsmasq.conf

  # Enable the service at boot
  systemctl enable dnsmasq
}

# Set up and configure hostapd
configure_hostapd()
{
  eval echo "Configuring hostapd..." ${STD_LOG_ARG}

  # Build the config for hostapd
  envsubst < ${HAZ_DIR}/templates/hostapd.conf.tmpl > /etc/hostapd/hostapd.conf
  chmod 640 /etc/hostapd/hostapd.conf

  # Specify a service config for hostapd
  rm /etc/default/hostapd
  cp ${HAZ_DIR}/configs/etc/default/hostapd /etc/default/hostapd
}

# Set up the network devices
configure_network()
{
  eval echo "Configuring network devices..." ${STD_LOG_ARG}

  cp ${HAZ_DIR}/configs/etc/network/interfaces.d/wlan0 /etc/network/interfaces.d/wlan0

  eval echo "Updating hosts..." ${STD_LOG_ARG}
  
  sed -i '/^192\.168\.4\.1.*$/d' /etc/hosts
  echo "192.168.4.1 ${HOSTNAME}" >> /etc/hosts
}

# Set up and configure nginx
configure_nginx()
{
  eval echo "Generating self-signed SSL certificate..." ${STD_LOG_ARG}
  cp ${HAZ_DIR}/configs/root/localhost.openssl.conf /root/

  # Create the certificate and key
  cd /root
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config localhost.openssl.conf

  # Move those to the SSL directory
  mv localhost.crt /etc/ssl/certs/
  mv localhost.key /etc/ssl/private/localhost.key

  # Change back to the script directory
  cd ${HAZ_DIR}/scripts

  eval echo "Configuring nginx..." ${STD_LOG_ARG}

  # Copy in our site config(s)
  cp ${HAZ_DIR}/configs/etc/nginx/sites-available/*.conf /etc/nginx/sites-available/

  # Enable the new site
  ln -s /etc/nginx/sites-available/localhost.conf /etc/nginx/sites-enabled/localhost.conf

  # Disable the default welcome
  if [[ -f /etc/nginx/sites-enabled/default ]]; then
    rm /etc/nginx/sites-enabled/default
  fi
}

# Enable IPv4 forwarding
enable_forwarding()
{
  eval echo "Enabling IPv4 forwarding..." ${STD_LOG_ARG}

  if [[ $(grep -e '^#net\.ipv4\.ip_forward=1$' /etc/sysctl.conf) ]]; then
    sed -i '/^#net\.ipv4\.ip_forward=1$/s/^#//' /etc/sysctl.conf
  else
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
  fi

  eval echo "Enabling localnet routing..." ${STD_LOG_ARG}
  if [[ $(grep -e '^#net\.ipv4\.conf\.all\.route_localnet=1$' /etc/sysctl.conf) ]] ; then
    sed -i '/^#net\.ipv4\.conf\.all\.route_localnet=1$/s/^#//' /etc/sysctl.conf
  else
    echo net.ipv4.conf.all.route_localnet=1 >> /etc/sysctl.conf
  fi
}

# Set logging on
set_logging()
{
  echo "Running with logging option..."
  STD_LOG_ARG=">>${LOG_PATH}/${STD_LOG}"
}

# Display usage information
usage()
{
  echo "Usage: [Environment Variables] ./install.sh [-hL]"
  echo "  Environment Variables:"
  echo "    LOG_PATH               path for logs (default: '/var/log')"
  echo "  Options:"
  echo "    -h | --help            display this usage information"
  echo "    -L | --Log             enable logging (target: '[LOG_PATH]/install_haz.log')"
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

${HAZ_DIR}/scripts/install_nodogsplash.sh
${HAZ_DIR}/scripts/install_random_media_portal.sh -docker
${HAZ_DIR}/scripts/install_ircd-hybrid.sh
configure_nginx
configure_network
configure_dhcpcd
configure_hostapd
enable_forwarding
configure_dnsmasq