# Base image
FROM ubuntu:latest

# Information
LABEL maintainer="FrozenFOXX <frozenfoxx@churchoffoxx.net>"

# Environment variables
ENV DEBIAN_FRONTEND "noninteractive"
ENV HOST 0.0.0.0

# Add scripts
COPY scripts/ /usr/local/bin/

# Run the installer
RUN /usr/local/bin/install.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
