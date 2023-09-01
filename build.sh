#!/usr/bin/env bash

./docker-make clean
docker build -t ledger-app-builder:latest .
docker run --rm -ti -v "$(realpath .):/app" --user $(id -u $USER):$(id -g $USER) ledger-app-builder:latest /bin/bash -c "BOLOS_SDK=/opt/nanos-secure-sdk make"