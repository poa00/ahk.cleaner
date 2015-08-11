@ECHO OFF
CLS

Ahk2Exe.exe /in Source\AHKcleaner.ahk /out Destination\AHKcleaner.exe /icon PB-Soft.ico /bin AutoHotkeySC.bin /mpress 0
upx --ultra-brute Destination/AHKcleaner.exe

pause