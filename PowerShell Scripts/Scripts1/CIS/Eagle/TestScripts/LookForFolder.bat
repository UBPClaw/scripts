echo off

REM XLR Y$ is the AFTER VOLUME
REM XLR X$ is the BEFORE VOLUME

net use /delete y:
pause
net use y: \\xlr\y$
pause

if not exist x:\UV2 goto Fail
goto GOOD
:FAIL
Call E:\Scripts\TestScripts\emailFiles\TestIsNotThereEmail.bat
goto END
:GOOD
echo The test.txt file is there. 
Call E:\Scripts\TestScripts\emailFiles\TestIsThereEmail.bat
:END
