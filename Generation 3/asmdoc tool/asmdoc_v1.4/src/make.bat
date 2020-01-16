@echo off
echo.
echo Install Flex and MinGW for this makefile to work.
echo Other C compiler may or may not work, haven't tested.
echo.
echo Flex: http://gnuwin32.sourceforge.net/packages/flex.htm
echo MinGW: http://sourceforge.net/project/showfiles.php?group_id=2435
echo.
"c:\Program Files\GnuWin32\bin\flex.exe" -overa_cs.c vera_cs.lex
gcc -o main.o -c main.c
gcc -o asmdoc.exe main.o
del vera_cs.c
del main.o