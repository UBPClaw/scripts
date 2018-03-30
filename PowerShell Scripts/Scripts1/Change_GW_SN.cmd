netsh -c interface dump > %temp%\netsh.txt
rem ipconfig > %temp%\ipconfig.txt
rem %temp%\ipconfig.txt
%temp%\netsh.txt
netsh -f %temp%\netsh.txt
ipconfig
pause
