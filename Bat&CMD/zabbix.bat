set ZABSVR=Zabbix_Server_IP
set ZABHOST=Zabbix_Server_IP

::清理旧的安装
c:
md c:\zabbix
cd c:\zabbix
zabbix_agentd --stop
zabbix_agentd --uninstall
del /q /f *

:: 根据操作系统类型设置下载32位、64位介质的ftp路径
echo %PROCESSOR_IDENTIFIER%|find "86">nul
if %errorlevel% equ 0 (
set ftp_path=/services/itauto/software/zabbix_agents_2.4.0.win/bin/win32
echo 32
)else (
set ftp_path=/services/itauto/software/zabbix_agents_2.4.0.win/bin/win64
echo 64
)

:: 从ftp下载zabbix安装介质
echo open FTP_SERVER_IP >ftp.txt 
(echo FTP_USER)>>ftp.txt 
(echo FTP_PASSWORD)>>ftp.txt 
echo binary>>ftp.txt 
echo mget %ftp_path%/*>>ftp.txt 
echo bye >>ftp.txt
ftp -i -s:ftp.txt
del /f /q ftp.txt

echo LogFile=c:\zabbix\zabbix_agentd.log    >zabbix_agentd.conf
echo LogFileSize=10                 >>zabbix_agentd.conf
echo EnableRemoteCommands=1         >>zabbix_agentd.conf
echo LogRemoteCommands=1            >>zabbix_agentd.conf
echo Server=%ZABSVR%            >>zabbix_agentd.conf
echo ServerActive=%ZABSVR%      >>zabbix_agentd.conf
echo Hostname=%ZABHOST%            >>zabbix_agentd.conf
echo UnsafeUserParameters=1         >>zabbix_agentd.conf
echo Timeout=30                     >>zabbix_agentd.conf

zabbix_agentd -c c:\zabbix\zabbix_agentd.conf --install
zabbix_agentd -c c:\zabbix\zabbix_agentd.conf --start
