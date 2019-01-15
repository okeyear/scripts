@echo off
set old=%1:
set new=U:
pushd %new% 2>nul && echo %new%盘已经存在! && pause && goto :eof
for /f %%i in ('mountvol %old% /l') do set "vol=%%i"
mountvol %old% /d
mountvol %new% %vol%
popd 
del %0