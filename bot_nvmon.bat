@echo off
color E
title NvidiaMonitor
mode con: cols=80 lines=8
PATH=%PATH%;"%PROGRAMFILES%\NVIDIA Corporation\NVSMI\"

:loop
nvidia-smi -a 2>NUL | find /I /N "GPU is lost">NUL
IF "%ERRORLEVEL%" == "0" (
    cls
    ECHO GPU is lost !!!
    ECHO waiting 10 sec and recheck....
    timeout /t 10 /nobreak
    shutdown -r -f -t 0
) ELSE (
    cls
    nvidia-smi --query-gpu=index,name,temperature.gpu,fan.speed,clocks.gr,clocks.mem,pstate,power.draw,power.limit --format=csv,noheader
)
timeout /t 5 /nobreak >nul
goto :loop