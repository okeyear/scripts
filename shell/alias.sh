#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en


sudo yum install -y highlight
alias cats='highlight -O ansi --syntax=bash'
echo "alias cats='highlight -O ansi --syntax=bash'"  | sudo tee /etc/profile.d/alias.sh
