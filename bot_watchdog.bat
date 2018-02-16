@ECHO OFF
color B
mode con: cols=80 lines=20
title WatchDog

:start
:: kill app when app is not responding
taskkill /FI "STATUS eq NOT RESPONDING" /F >NUL

::kill app when miners is not runing
call :func_reset_errorlevel
tasklist /FI "IMAGENAME eq ccminer.exe" 2>NUL | find /I /N "ccminer.exe">NUL
IF NOT "%ERRORLEVEL%" == "0" (
    cls
    ECHO Status: Not sure
    ECHO Detech: ccminer.exe is not running
    ECHO waiting 10 sec and recheck....
    timeout /t 10 /nobreak
)
call :func_reset_errorlevel

::recheck ccminer.exe
tasklist /FI "IMAGENAME eq ccminer.exe" 2>NUL | find /I /N "ccminer.exe">NUL
IF NOT "%ERRORLEVEL%" == "0" (
    cls
    ECHO Status: Error
    ECHO Error: ccminer.exe is not runing
    call :func_kill_miners
    call :func_reset_errorlevel
    goto :end
)

:: kill app when WerFault is runing
tasklist /FI "IMAGENAME eq WerFault.exe" 2>NUL | find /I /N "WerFault.exe">NUL
IF "%ERRORLEVEL%"=="0" (
    cls
    ECHO Status: Error
    ECHO Error: ccminer.exe is error WerFault.exe is runing
    call :func_kill_miners
    call :func_reset_errorlevel
    goto :end
)
call :func_reset_errorlevel

:: restart system when csrss.exe is runing
tasklist /FI "WindowTitle eq ccminer.exe - Application Error" 2>NUL | find /I /N "csrss.exe">NUL
IF "%ERRORLEVEL%"=="0" (
    cls
    ECHO Status: Error
    ECHO Error: ccminer.exe is error csrss.exe is runing
    call :func_restart_system
    call :func_reset_errorlevel
    goto :end
)
call :func_reset_errorlevel

:end
:: if snifdog is not runing re-start sniffdog
tasklist /FI "Windowtitle eq SniffDog" 2>NUL | find /I /N "PID">NUL
IF NOT "%ERRORLEVEL%" == "0" (
    ECHO Status: Error
    ECHO Sniffdog is not runing...
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
    taskkill /FI "IMAGENAME eq WerFault.exe" /T /F >nul
    taskkill /FI "IMAGENAME eq ccminer.exe" /T /F >nul
    taskkill /FI "Windowtitle eq SniffDog" /T /F >nul
goto :EOF

:func_restart_system
    ECHO Restart system in 10 sec
    timeout /t 10 /nobreak
    shutdown -r -f -t 0
goto :EOF

:func_start_sniffdog
    ECHO Start restart sniffdog...
    start startsniffin.bat
    ECHO Restart sniffdog successful
goto :EOF

:func_display_apps
    cls
    ECHO Status: OK
    ECHO.
    ECHO ######## SniffDog ########
    tasklist /FI "Windowtitle eq SniffDog"
    ECHO.
    ECHO.
    ECHO ######## ccminer #########
    tasklist /FI "IMAGENAME eq ccminer.exe"
goto :EOF