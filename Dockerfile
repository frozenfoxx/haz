# Base image
FROM ubuntu:latest

# Information
LABEL maintainer="FrozenFOXX <frozenfoxx@churchoffoxx.net>"

# Environment variables
ENV DEBIAN_FRONTEND "noninteractive"
ENV HAZ_DIR "/opt/haz"
ENV HAZ_NAME "haz"
ENV HOST 0.0.0.0
ENV NET_DHCPRANGE "192.168.4.100,192.168.4.150,5m"
ENV NET_GATEWAY "192.168.4.1"

# Install core dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      git \
      dnsmasq \
      gettext \
      hostapd \
      ruby \
      supervisor

# Install gem dependencies
RUN gem install bundler

# Create directory for holding media if it doesn't exist already
RUN mkdir -p /data

# Set the working directory
WORKDIR ${HAZ_DIR}

# Add HAZ
COPY . .

# Run the installer
RUN ./scripts/deploy_docker.sh

# Clean up apt
RUN apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Set up supervisor
COPY configs/etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENTRYPOINT [ "./scripts/entrypoint.sh" ]
