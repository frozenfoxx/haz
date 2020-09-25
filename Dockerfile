# Base image
FROM ubuntu:latest

# Information
LABEL maintainer="FrozenFOXX <frozenfoxx@churchoffoxx.net>"

# Environment variables
ENV APP_HOME /app
ENV HOST 0.0.0.0

WORKDIR ${APP_HOME}

# Add source
COPY . /app

# Run the installer
RUN /app/bin/install.sh

ENTRYPOINT [ "./bin/entrypoint.sh" ]
