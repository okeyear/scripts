#!/bin/bash
# Linux迷 www.linuxmi.com

sleep 5 &
pid=$!
frames="/ | \\ -"
while kill -0 $pid 2&>1 > /dev/null;
do
    for frame in $frames;
    do
        printf "\r$frame Loading..."
        sleep 0.5
    done
done
printf "\n"
