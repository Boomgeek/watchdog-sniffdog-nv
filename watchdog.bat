@ECHO OFF
color a
title WatchDog

:start
cls
:: kill app when app is not responding
taskkill /FI "STATUS eq NOT RESPONDING" /F >NUL

::kill app when miners is not runing
call :func_reset_errorlevel
tasklist /FI "IMAGENAME eq ccminer.exe" 2>NUL | find /I /N "ccminer.exe">NUL
IF NOT "%ERRORLEVEL%" == "0" (
    ECHO Status: Not sure
    ECHO Detech: ccminer.exe is not running
    ECHO waiting 10 sec and recheck....
    timeout /t 10 /nobreak
)
call :func_reset_errorlevel

::recheck ccminer.exe
tasklist /FI "IMAGENAME eq ccminer.exe" 2>NUL | find /I /N "ccminer.exe">NUL
IF NOT "%ERRORLEVEL%" == "0" (
    ECHO Error: ccminer.exe is not runing
    call :func_kill_miners
    call :func_reset_errorlevel
    goto :end
)

:: kill app when WerFault is runing
tasklist /FI "IMAGENAME eq WerFault.exe" 2>NUL | find /I /N "WerFault.exe">NUL
IF "%ERRORLEVEL%"=="0" (
    ECHO Error: ccminer.exe is error WerFault is runing
    call :func_kill_miners
    call :func_reset_errorlevel
    goto :end
)
call :func_reset_errorlevel

:end
:: if snifdog is not runing re-start sniffdog
tasklist /FI "Windowtitle eq SniffDog" 2>NUL | find /I /N "PID">NUL
IF NOT "%ERRORLEVEL%" == "0" (
    ECHO sniffdog is not runing...
    call :func_start_sniffdog
)
call :func_reset_errorlevel

call :func_display_apps
timeout /t 5 /nobreak >nul
goto start


::Function zone

:func_reset_errorlevel
    ver > nul
goto :EOF

:func_kill_miners
    ECHO  Start kill apps
    taskkill /FI "IMAGENAME eq WerFault.exe" /F >nul
    taskkill /FI "IMAGENAME eq ccminer.exe" /F >nul
    taskkill /FI "Windowtitle eq SniffDog" /F >nul
goto :EOF

:func_start_sniffdog
    ECHO Start restart sniffdog...
    start startsniffin.bat
    ECHO Restart sniffdog successful
goto :EOF

:func_display_apps
    ECHO Status: OK
    ECHO.
    ECHO ######## SniffDog ########
    tasklist /FI "Windowtitle eq SniffDog"
    ECHO.
    ECHO.
    ECHO ######## ccminer #########
    tasklist /FI "IMAGENAME eq ccminer.exe"
goto :EOF