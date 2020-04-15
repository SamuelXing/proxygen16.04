#!/usr/bin/env bash

# Parse args
JOBS=8
USAGE="./deps.sh [-j num_jobs]"
while [ "$1" != "" ]; do
  case $1 in
    -j | --jobs ) shift
                  JOBS=$1
                  ;;
    * )           echo $USAGE
                  exit 1
esac
shift
done

set -e
start_dir=$(pwd)
trap 'cd $start_dir' EXIT

# Must execute from the directory containing this script
cd "$(dirname "$0")"

# Build proxygen
autoreconf -ivf
./configure
make -j $JOBS

# Run tests
LD_LIBRARY_PATH=/usr/local/lib make check

# Install the libs
sudo make install