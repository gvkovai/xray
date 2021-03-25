#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Please provide the number of minutes the Curator Running jobs count should be zero before returning."
  echo "Usage $0 [minutes]"
  exit 1
fi

EMPTY_MINS=0
while [ $EMPTY_MINS -lt $1 ] ; do
  CURATOR_JOBS=`curl -s localhost:2010 | grep -c Running`
  echo "CURATOR_JOBS="${CURATOR_JOBS}  "EMPTY_MINS="$EMPTY_MINS
  if [ "${CURATOR_JOBS}" == "0" ] ; then
    ((EMPTY_MINS += 1))
  else
    EMPTY_MINS=0
  fi
  sleep 1m
done