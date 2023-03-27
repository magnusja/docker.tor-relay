#!/bin/bash

set -e

exec tor -f /config/torrc --defaults-torrc "/config/torrc.${RELAY_TYPE}.default"