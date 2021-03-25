#!/usr/bin/env bash
#
# Copyright (c) 2018 Nutanix Inc. All rights reserved.
#
# Author:   GV (gv@nutanix.com)
#
# Purpose:  Wait for nearsync to be active on the given protection domain
#

if [ "$#" -lt 2 ]; then
  echo "Please provide the number of seconds the NearSync should be active before returning."
  echo "Usage $0 [pdname] [seconds]"
  exit 1
fi

PDNAME=$1
EMPTY_SECS=0
NUM_CHK=0
MAX_CHK=12000

# If it's not a master, exit out
IsMaster=$(curl -s localhost:2020 | grep -A1 "Master&nbsp;Handle" | tail -1 |awk -F "<+|>" '{ print $4; }')
if [[ $IsMaster ]]; then
  echo "This is not cerebro master"
  exit 0
fi

while [ $EMPTY_SECS -lt $2 ] && [ $NUM_CHK -lt $MAX_CHK ] ; do
  DRSTR=$(curl -s localhost:2020 | grep -A10 ${PDNAME} | tail -1 |awk -F "<+|>" '{ print $3; }')
  DRSTATUS=$(curl -s localhost:2020 | grep -A2 ${PDNAME} | tail -1 |awk -F "<+|>" '{ print $3; }')
  echo "DRSTR="${DRSTR}  "DRSTATUS="${DRSTATUS}
  if [ "${DRSTR}" == "NearSync" ] && [ "${DRSTATUS}" == "yes" ] ; then
    ((EMPTY_SECS += 1))
  else
    EMPTY_SECS=0
  fi
  sleep 1
  (( NUM_CHK += 1))
done
