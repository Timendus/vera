@echo off

del OS.rom
del OS.rom.pti
del pti.conf

brass main.asm OS.rom
pause
