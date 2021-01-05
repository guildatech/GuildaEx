#!/usr/bin/env bash

cd /opt/app/assets && npm install

cd /opt/app && mix deps.get && mix phx.server
