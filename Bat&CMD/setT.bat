echo off & cls
::chcp 936
chcp 65001 

d:
cd  我的坚果云
echo %~dp0
subst T: %cd%
::subst T:   %cd%
::subst T:    F:\我的坚果云

::echo %~f0 

::pause

