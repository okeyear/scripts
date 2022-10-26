#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e

# todo: 部分Linux版本mail命令不支持-S选项，那么请修改/etc/mail.rc配置，指定SMTP地址和发件人

# define variables
username='testuser01'
days=365 # password expire in days

# smtp server
mail_server='smtp_ip:25'
mail_from='alert@domail.com.cn'
mail_to='1@1.com'

# shell begin
left_time=$(sudo chage -l $username | awk -F':' '/Password expires/{print $NF}')
if [ $left_time == 'never' ]; then
    echo password never expires.
    exit
fi

left_time=$(echo $(date -d "$left_time" +%s) - $(date +%s) | bc)
days_sec=$(echo 3600*24*$days|bc)
if [ $left_time -le $days_sec ] ; then
	# send mail
	echo "This is the from: $(ip r get 1.1.1.1 | awk '/dev/{print $7}'), host: $(hostname), $(sudo chage -l $username | grep 'Password expires' | column -t)" `# 发件正文` |
		mail -s "OS Password expire alert $(date +%FT%T)!" `# 发件标题` \
		-S "from=$mail_from" `# 发件人邮箱地址` \
		-S "smtp=$mail_server" `# 邮件服务器地址`  \
		$mail_to `# 收件人邮箱`
fi
