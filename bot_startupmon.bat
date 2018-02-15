@echo off
ECHO waiting 10 sec for startup program....
timeout /t 10 /nobreak

start bot_nvmon.bat
start bot_watchdog.bat