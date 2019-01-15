@echo off
set "u=%cd:~0,1%"
echo.&echo 你的U盘盘符是 %u% 盘
echo %u%
:: echo %u% > %cd%%u%.txt
copy %cd%setU.bat c:\setU.bat
call c:\setU.bat %u%
pause