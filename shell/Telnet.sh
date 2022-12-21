PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
export LANG=en
#stty erase

#(echo >/dev/tcp/localhost/80) &>/dev/null && echo “TCP port 80 open” || echo “TCP port 80 close”

function Check_Port(){
# Destination=$1
if [ $# -ne 2 -a  $# -ne 3 ] ; then
  echo -e 'Useage:  \e[0;91mCheck_Port    \e[0;35m$Des  $Dport  \e[0;92m[udp|default:tcp]\e[0m'
  return 1
fi

Num=$(echo $1 | grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"|wc -l)
[ $Num -eq 1 ]  &&  Des=$1 || Des=$(nslookup $1 | awk '$1 ~ /Address:/ && $2 !~ /#/ {print $2}'| tail -n 1)
#Des=$1 
Dport=$2
# Protocol=$3
Pro=$3
Pro=${Pro:=tcp}
Src=$(ip route get $Des | awk  '/src/ {print $NF}' )
GateWay=$(ip route get $Des | awk  '/src/ {print $3}' )


if command -v nmap  &>/dev/null ; then
    BIN=nmap
elif command -v nc &>/dev/null ; then
    BIN=nc
elif command -v telnet &>/dev/null ; then
    BIN=telnet
else
    echo -e 'Command : nc , nmap , telnet  not exist in your OS.\nWill use bash socket like /dev/tcp or /dev/udp .'
    BIN=socket
fi


function Sucess(){
echo -e "$BIN:  Src:$Src  GateWay:$GateWay  Des:$Des  Dport:$Dport  Pro:$Pro    Result:\e[0;93m[success]\e[0m"
}

function Failure(){
echo -e "$BIN:  Src:$Src  GateWay:$GateWay  Des:$Des  Dport:$Dport  Pro:$Pro    Result:\e[0;91m[failure]\e[0m"
}

if [ "$Pro" == "udp" -a "$BIN" == "nc" ] ; then
  #nc -vu $Des  $Dport
  [ $(echo ''|nc -vuw 3 $Des  $Dport 2>&1| awk "/$Des/{print \$2}") == 'Connected' -o $(echo ''|nc -vuw 2 $Des  $Dport 2>&1| awk "/$Des/{print \$2}") == 'succeeded!'  ] 2>/dev/null && Sucess || Failure
elif [ "$Pro" == "udp" -a "$BIN" == "nmap" ] ; then
  #nmap -sU $Des -p $Dport -Pn
  [[ $(nmap -sU $Des -p $Dport -Pn| awk "/^$Dport/{print \$2}") =~ 'open' ]] 2>/dev/null && Sucess || Failure
elif [ "$Pro" == "udp" -a "$BIN" == "socket" ] ; then
  (echo >/dev/udp/$Des/$Dport) 2>/dev/null && Sucess || Failure
elif [ "$Pro" == "tcp" ] ; then
        case $BIN in
        nc)
        #nc -vw 2  $Des  $Dport
            [ $(echo ''|nc -vw 3 $Des  $Dport 2>&1|awk "/$Des/{print \$NF}") == 'succeeded!' -o $(echo ''|nc -vw 2 $Des  $Dport 2>&1|awk "/$Des/{print \$2}") == 'Connected' ] 2>/dev/null && Sucess || Failure
        ;;
        nmap)
        #nmap $Des -p $Dport | awk "/$Dport/{print \$0}"
            [ $(nmap $Des -p $Dport | awk "/^$Dport/{print \$2}") == "open" ] 2>/dev/null && Sucess || Failure
        ;;
        telnet)
            [ $(echo ''|telnet $1 $2 2>/dev/null|grep "\^]"|wc -l) -eq 1 ] 2>/dev/null && Sucess || Failure
        ;; 
        socket)
            (echo >/dev/tcp/$Des/$Dport) 2>/dev/null && Sucess || Failure
        ;; 
        *)
        echo
        ;;
      esac
else
  echo -e 'Useage:  \e[0;91mCheck_Port    \e[0;35m$Des  $Dport  \e[0;92m[udp|default:tcp]\e[0m'
fi
}

Check_Port $1 $2 $3
