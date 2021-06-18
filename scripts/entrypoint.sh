#!/usr/bin/env bash

# Variables

# Functions

# Logic

source /etc/default/*
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf $@
