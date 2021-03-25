#!/usr/bin/env bash
#
# Copyright (c) 2018 Nutanix Inc. All rights reserved.
#
# Author:   Brantley West (brantley@nutanix.com)
#
# Purpose:  Run fstrim on all SSD and NVMe devices in parallel, exit when completed.
#

# Get SSD & NVMe devices
#FLASHDEVS=(`lsblk -Dd | grep -v loop | awk '{if ( $5 == 1) { print $1; }}'`)
FLASHDEVS=(`lsblk -Dd -o name,rota | grep -v loop | egrep "^sd|^nvme" | awk '{ if($2==0)print $1; }'`)
echo ${FLASHDEVS[*]}

JOBS=()
for FLASHDEV in "${FLASHDEVS[@]}" ; do
  type=(`mount | grep $FLASHDEV | awk '{print $5;}'`)
  if [[ $type == "ext4" ]]; then
  echo -n Running fstrim on $FLASHDEV at `date`  ...
  echo
  mount | grep $FLASHDEV | awk '{print $3;}' | xargs -n 1 sudo fstrim &
  JOBS+=($!)
  fi
done

RETURN=0
for JOB in "${JOBS[@]}" ; do
  echo "Waiting on job: ${JOB}"
  wait ${JOB}
  JOB_RET=$?
  RETURN=$((${RETURN}|${JOB_RET}))
done

echo "Done at `date`."
exit $RETURN

