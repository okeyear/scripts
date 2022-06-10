# echo 'local1.crit  /var/log/bash_history.log' >> /etc/rsyslog.conf
# vim /etc/profile.d/bash_PROMPT_COMMAND.sh
export HISTSIZE=1000
export HISTTIMEFORMAT="%F %T "
export PROMPT_COMMAND='{ 
    # 1000  2020-01-01 00:00:00 history 1
    # hisCmd=$(history 1 | { read x y z cmd; echo $cmd | sed "s@\"@\\\\\"@g"; }) ;
    hisCmd=$(history 1 | { read x y z cmd; echo $cmd; }) ;
    _whoStr=$(who -u am i) ;
    realUser=$(echo ${_whoStr} | awk "{print \$1}") ;
    loginDate=$(echo ${_whoStr} | awk "{print \$3}") ;
    loginTime=$(echo ${_whoStr} | awk "{print \$4}") ;
    loginPid=$(echo ${_whoStr} | awk "{print \$6}") ;
    loginIp=$(echo ${_whoStr} | awk "{print \$7}") ;
    # json format:
    totalMsg="{\"realUser\":\"${realUser}\",\"sudoUser\":\"$USER\",\"curFolder\":\"$PWD\",\"loginDate\":\"${loginDate}\",\"loginTime\":\"${loginTime}\",\"loginPid\":\"${loginPid}\",\"loginIp\":\"${loginIp}\",\"hisCmd\":\"${hisCmd}\" }";
    # common format:
    # totalMsg="realUser=${realUser} sudoUser=${sudoUser} curFolder=$PWD loginDate=${loginDate} loginTime=${loginTime} loginPid=${loginPid} loginIp=${loginIp} hisCmd=${hisCmd}";
    # echo ${totalMsg} | sudo tee -a /var/log/bash_history.log;
    logger -p local1.crit "${totalMsg}" ;
}'
