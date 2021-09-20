#!/usr/bin/env bash

# Variables
DEBIAN_FRONTEND="noninteractive"
DROOPY_DIR=${DROOPY_DIR:-'/data'}
HAZ_DIR=${HAZ_DIR:-'/opt/haz'}
HAZ_NAME=${HAZ_NAME:-'haz'}
MEDIA_DIRECTORY=${MEDIA_DIRECTORY:-'/data'}
NET_CHANNEL=${NET_CHANNEL:-'6'}
NET_DHCPRANGE=${NET_DHCPRANGE:-'192.168.4.100,192.168.4.150,5m'}
NET_DRIVER=${NET_DRIVER:-'nl80211'}
NET_GATEWAY=${NET_GATEWAY:-'192.168.4.1'}
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
  envsubst < ${HAZ_DIR}/configs/etc/dhcpcd.conf.tmpl > /etc/dhcpcd.conf
}

## Set up and configure dnsmasq
configure_dnsmasq()
{
  eval echo "Configuring dnsmasq..." ${STD_LOG_ARG}
  envsubst < ${HAZ_DIR}/configs/etc/dnsmasq.conf.tmpl > /etc/dnsmasq.conf
}

## Set up and configure hostapd
configure_hostapd()
{
  eval echo "Configuring hostapd..." ${STD_LOG_ARG}

  # Build the config for hostapd
  envsubst < ${HAZ_DIR}/configs/etc/hostapd/hostapd.conf.tmpl > /etc/hostapd/hostapd.conf
  chmod 640 /etc/hostapd/hostapd.conf

  # Specify a service config for hostapd
  rm /etc/default/hostapd
  cp ${HAZ_DIR}/configs/etc/default/hostapd /etc/default/hostapd
}

## Set up the network devices
configure_network()
{
  eval echo "Configuring network devices..." ${STD_LOG_ARG}

  # Create network interfaces directory
  mkdir -p /etc/network/interfaces.d

  cp ${HAZ_DIR}/configs/etc/network/interfaces.d/wlan0 /etc/network/interfaces.d/wlan0

  eval echo "Updating hosts..." ${STD_LOG_ARG}
  
  # FIXME: this line will also strip similar lines to the gateway
  sed -i "/^${NET_GATEWAY}.*$/d" /etc/hosts
  echo "${NET_GATEWAY} ${HAZ_NAME}" >> /etc/hosts
}

## Load supervisor configuration
configure_supervisor()
{
  cp ${HAZ_DIR}/configs/etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
}

## Enable IPv4 forwarding
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

## Set logging on
set_logging()
{
  echo "Running with logging option..."
  STD_LOG_ARG=">>${LOG_PATH}/${STD_LOG}"
}

## Display usage information
usage()
{
  echo "Usage: [Environment Variables] ./deploy_docker.sh [-hL]"
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
${HAZ_DIR}/scripts/install_ircd-hybrid.sh -docker
${HAZ_DIR}/scripts/install_droopy.sh
${HAZ_DIR}/scripts/install_nginx.sh -docker
configure_network
configure_dhcpcd
configure_hostapd
enable_forwarding
configure_dnsmasq
configure_supervisor
