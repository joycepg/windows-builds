@echo off
echo ------ libXML2 -----


CALL bsdtar xvfz %PKGDIR%\libxml2-%LIBXML2_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

CALL rename libxml2-%LIBXML2_VERSION% libxml2
IF ERRORLEVEL 1 GOTO ERROR

cd libxml2\win32

CALL cscript configure.js compiler=msvc prefix=%ROOTDIR%\libxml2 iconv=no icu=yes include=%ROOTDIR%\icu\include lib=%ROOTDIR%\icu\lib
IF ERRORLEVEL 1 GOTO ERROR

CALL patch  -p1 < %ROOTDIR%\libxml.patch
IF ERRORLEVEL 1 GOTO ERROR

CALL nmake /f Makefile.msvc
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR libXML2 --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%