#!/bin/bash
sudo tee /etc/pythonstartup.py <<EOF
# install readline http://newcenturycomputers.net/projects/readline.html
# python startup file
import sys
import readline
import rlcompleter
import atexit
import os
# tab completion
readline.parse_and_bind('tab: complete')
# history file
histfile = os.path.join(os.environ['HOME'], '.pythonhistory')
try:
    readline.read_history_file(histfile)
except IOError:
    pass
atexit.register(readline.write_history_file, histfile)

del os, histfile, readline, rlcompleter 
EOF

echo 'export PYTHONSTARTUP=/etc/pythonstartup.py' | sudo tee /etc/profile.d/pythonstartup.sh
# for windows:     pythonstartupf=path/pythonstartup.py
