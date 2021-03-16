# Base image
FROM ubuntu:latest

# Information
LABEL maintainer="FrozenFOXX <frozenfoxx@churchoffoxx.net>"

# Environment variables
ENV DEBIAN_FRONTEND "noninteractive"
ENV HAZ_DIR "/opt/haz"
ENV HOST 0.0.0.0

# Add HAZ
COPY . ${HAZ_DIR}

# Run the installer
RUN ${HAZ_DIR}/scripts/deploy_docker.sh

ENTRYPOINT [ "${HAZ_DIR}/scripts/entrypoint.sh" ]
