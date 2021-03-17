# Base image
FROM ubuntu:latest

# Information
LABEL maintainer="FrozenFOXX <frozenfoxx@churchoffoxx.net>"

# Environment variables
ENV DEBIAN_FRONTEND "noninteractive"
ENV HAZ_DIR "/opt/haz"
ENV HOST 0.0.0.0

# Install core dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      git \
      dnsmasq \
      hostapd \
      nginx \
      ruby \
      supervisor

# Install gem dependencies
RUN gem install bundler

# Create directory for holding media if it doesn't exist already
RUN mkdir -p /data

# Add HAZ
COPY . ${HAZ_DIR}

# Run the installer
RUN ${HAZ_DIR}/scripts/deploy_docker.sh

# Clean up apt
RUN apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Set up supervisor
COPY configs/etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENTRYPOINT [ "${HAZ_DIR}/scripts/entrypoint.sh" ]
