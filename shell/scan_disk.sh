#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en

# exit shell when error
# set -e

function scan_disk(){
    # scan new added disks if not found
    for i in $(ls /sys/class/scsi_host/)
    do
        echo "- - -" > /sys/class/scsi_host/${i}/scan
    done
}
