#!/usr/bin/env python
# coding=utf8
# Author: PengRuifang  &&  qq383326308  && okeyear@163.com
# Created Time : 2017-01-12 10:10:16
# Last Modified: 2017-01-12 10:12:39
# File Name: tab.py
# Revision:
# Description:
# Notes:
#  http://www.init.wang   Copyright: 2016 (c) okeyear
# License:

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
