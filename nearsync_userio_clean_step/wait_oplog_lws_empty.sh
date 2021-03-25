#!/usr/bin/env bash
#
# Copyright (c) 2018 Nutanix Inc. All rights reserved.
#
# Author:   Brantley West (brantley@nutanix.com), gv
#
# Purpose:  Wait for the Oplog/LWS to be empty for a pre-determined number of
#           seconds before returning.
#

if [ "$#" -lt 1 ]; then
  echo "Please provide the number of seconds the Oplog/LWS should be empty before returning."
  echo "Usage $0 [seconds]"
  exit 1
fi

EMPTY_SECS=0
NUM_CHK=0
MAX_CHK=1200
while [ $EMPTY_SECS -lt $1 ] && [ $NUM_CHK -lt $MAX_CHK ] ; do
  #OPLOG_SIZE=`curl -s localhost:2009/oplog_flush_stats | grep -A1 \>Total\< | head -2 | awk -F "<+|>" '{ print $3; }' | grep -v '^$'`
  OPLOG_SIZE=`curl -s localhost:2009/oplog_flush_stats | grep -A4 \>Total\< | head -4 | tail -1 |awk -F "<+|>" '{ print $3; }'`
  LWS_SIZE=`curl -s localhost:2009/oplog_flush_stats | grep -A7 \>Total\< | head -7 | tail -1 |awk -F "<+|>" '{ print $3; }'`
  echo "OPLOG_SIZE="${OPLOG_SIZE}  "LWS_SIZE="${LWS_SIZE}  "EMPTY_SECS="$EMPTY_SECS "NUM_CHK="$NUM_CHK
  if [ "${OPLOG_SIZE}" == "0.0" ] && [ "${LWS_SIZE}" == "0.0" ] ; then
    ((EMPTY_SECS += 1))
  else
    EMPTY_SECS=0
  fi
  sleep 1
  (( NUM_CHK += 1))
done
