@echo off
::start %SystemRoot%\System32\drivers\etc
echo 127.0.0.1 localhost > %SystemRoot%\System32\drivers\etc\hosts
echo 6.86.2.101 tscbjmgtvcsa02.tscop.net  >> "c:\Windows\System32\drivers\etc\hosts"
echo 6.86.2.100  tscbjmgtpsc01.tscop.net  >> "c:\Windows\System32\drivers\etc\hosts"

rem network adapter name 
echo Ethernet>temp.txt
echo 以太网>>temp.txt
echo 本地连接>>temp.txt
echo Local Area Connection>>temp.txt

FOR /F "delims=" %%i IN (temp.txt) DO (
echo   %%i
::echo dns master
netsh interface ip set dns name="%%i" source=static addr=6.86.2.11
::echo  dns slaver
netsh interface ip add dns "%%i" 6.86.2.12 index=2
)

pause
del temp.txt

notepad %SystemRoot%\System32\drivers\etc\hosts 
::runas /user:administrator "notepad2 C:\WINDOWS\SYSTEM32\drivers\etc\hosts"