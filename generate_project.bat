@echo off

set BUILD_ARCH=x86_64 
set BUILD_TYPE=Release 
set ENABLE_ASM=1
set current_path=%cd%
set additional=
set target_cpu=
echo Current Path: %current_path%

:: parse parameters
:GETOPTS
if /I "%1" == "-h"    call :USAGE %0
if /I "%1" == "-a"    set BUILD_ARCH=%2 & shift
if /I "%1" == "-t"    set BUILD_TYPE=%2 & shift
if /I "%1" == "-asm"  set ENABLE_ASM=%2 & shift
shift
if not "%1" == "" goto GETOPTS

echo BUILD_CONFIG : %BUILD_ARCH% %BUILD_TYPE%

:: check parameters and set
if "%BUILD_ARCH%" == "x86_64 " ( 
  set workspace="%current_path%/workspace/windows/x86_64/"
  set generator="Visual Studio 15 2017 Win64"
  set target_cpu=x86_64
) else if "%BUILD_ARCH%" == "x86_32 " ( 
  set workspace="%current_path%/workspace/windows/x86_32/"
	set generator="Visual Studio 15 2017"
  set target_cpu=x86_32
) else if "%BUILD_ARCH%" == "arm64 " ( 
  set workspace="%current_path%/workspace/windows/arm64/"
	set generator="Visual Studio 17 2022"
	set additional="-A ARM64"
  set ENABLE_ASM=0
  set target_cpu=arm64
) else if "%BUILD_ARCH%" == "armv7 " ( 
  set workspace="%current_path%/workspace/windows/armv7/"
	set generator="Visual Studio 17 2022"
	set additional="-A ARM"
  set ENABLE_ASM=0
  set target_cpu=armv7
) else (
  echo Unknown ARCHITECTURE %BUILD_ARCH%
  goto PrintUsageAndExit
)

echo "----------- build on %BUILD_ARCH% ----------------"

if not exist %workspace% md %workspace%

echo "cmake -H%current_path% -B%workspace% -G%generator% %additional% -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_SYSTEM_PROCESSOR=%target_cpu% -DUSE_ASAN=0 -DENABLE_ASM=%ENABLE_ASM%"
cmake -H%current_path% -B%workspace% -G%generator% %additional% -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_SYSTEM_PROCESSOR=%target_cpu% -DUSE_ASAN=0 -DENABLE_ASM=%ENABLE_ASM%

goto End


:USAGE
echo   USAGE:
echo       %1 [-a ARCHITECTURE] [-t TYPE] [-asm ENABLE_ASM]
echo       -a   ARCHITECTURE   architecture;            [x86_32, x86_64]
echo       -t   TYPE           type;                    [Release, Debug]
echo       -asm ENABLE_ASM     turn on/off asm;         [1, 0]
goto:eof

:PrintUsageAndExit
call :USAGE %0

:End

pause