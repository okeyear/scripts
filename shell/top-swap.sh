#!/bin/bash
# get top 10 swap usage process
ps ax -o pid,user,args | grep -v '^  PID'|sed -e 's,^ *,,' > /tmp/ps_ax.output
echo -n >/tmp/results

# SwapPss can provide more accurate output
# Only RHEL8 onward available
SWAP_KEYWORD=$(grep -l SwapPss /proc/self/smaps)
if [ "$SWAP_KEYWORD" == "" ]; then
    SWAP_KEYWORD="Swap"
else
    SWAP_KEYWORD="SwapPss"
fi

for swappid in $(grep -l ${SWAP_KEYWORD} /proc/[1-9]*/smaps ); do
        swapusage=0
        for x in $( grep ${SWAP_KEYWORD} $swappid 2>/dev/null |grep -v '\W0 kB'|awk '{print $2}' ); do
                let swapusage+=$x
        done
        pid=$(echo $swappid| cut -d' ' -f3|cut -d'/' -f3)
        if ( [ $swapusage -ne 0 ] ); then
                echo -ne "$swapusage kb\t\t" >>/tmp/results
                egrep "^$pid " /tmp/ps_ax.output |sed -e 's,^[0-9]* ,,' >>/tmp/results
        fi
done

echo "top swap using processes which are still running:"
sort -nr /tmp/results | head -n 10
