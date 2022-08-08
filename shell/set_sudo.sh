#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e
# stty erase ^H
###########
function set_sudo(){
	#sudoers
	groupadd admin
	chmod a+w /etc/sudoers
	sed -i '/Defaults.*requiretty/d' /etc/sudoers 
	echo '#Defaults requiretty' >> /etc/sudoers
	sed -i '/^%admin/d' /etc/sudoers && echo '%admin ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
	chmod a-w /etc/sudoers
}
