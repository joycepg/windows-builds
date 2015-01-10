@echo off
SETLOCAL
SET EL=0
echo ------ zlib -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download zlib-%ZLIB_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST zlib (
  echo found extracted sources
)

if NOT EXIST "zlib" (
  echo extracting
  CALL bsdtar xfz zlib-%ZLIB_VERSION%.tar.gz
  IF ERRORLEVEL 1 GOTO ERROR
  rename zlib-%ZLIB_VERSION% zlib
  IF ERRORLEVEL 1 GOTO ERROR
)

::extracting was enough, gets built by libpng -> normal mapnik workflow
IF "%1"=="" GOTO NOBUILD


::build zlib ourselves -> for libosimium

SET ARCH=x64
IF %TARGET_ARCH% EQU 32 SET ARCH=x86
CD zlib\contrib\masm%ARCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CALL bld_ml%TARGET_ARCH%.bat 
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: --- build with Visual Studio
CD %PKGDIR%\zlib\contrib\vstudio\vc10
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
msbuild zlibvc.sln ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParallel=true ^
/p:Configuration=%BUILD_TYPE% ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: -- build with nmake
::CD %PKGDIR%\zlib\win32
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::nmake /f makefile.msc
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE


:NOBUILD
echo.
echo zlib will be built with/by libpng below
GOTO DONE


:ERROR
SET EL=%ERRORLEVEL%
ECHO ----------------- ERROR ZLIB --------------


:DONE
cd %ROOTDIR%
EXIT /b %EL%
