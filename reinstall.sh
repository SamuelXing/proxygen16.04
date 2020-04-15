#!/usr/bin/env bash

set -e
start_dir=$(pwd)
trap 'cd $start_dir' EXIT

# Must execute from the directory containing this script
cd "$(dirname "$0")"

# Install proxygen
cd ../..
sudo make uninstall
sudo make install

# Make sure the libraries are available
sudo /sbin/ldconfig