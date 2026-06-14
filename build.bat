@echo off
setlocal

set MASM32=C:\masm32
set ROOT=%CD%
set TMPBUILD=%TEMP%\waferfab_build
if not exist "%MASM32%\bin\ml.exe" (
  echo MASM32 was not found at %MASM32%.
  echo Install MASM32 or update MASM32 in this script.
  exit /b 1
)

if not exist "%ROOT%\build" (
  mkdir "%ROOT%\build"
)
if not exist "%TMPBUILD%" (
  mkdir "%TMPBUILD%"
)

pushd "%SystemDrive%\"

"%MASM32%\bin\ml.exe" /c /coff /Cp /nologo /I "%ROOT%\src" /Fo"%TMPBUILD%\main.obj" "%ROOT%\src\main.asm"
if errorlevel 1 (
  popd
  exit /b 1
)

"%MASM32%\bin\link.exe" /SUBSYSTEM:WINDOWS /nologo /OUT:"%TMPBUILD%\WaferFab.exe" "%TMPBUILD%\main.obj"
if errorlevel 1 (
  popd
  exit /b 1
)

popd

copy /Y "%TMPBUILD%\WaferFab.exe" "%ROOT%\build\WaferFab.exe" >nul
if errorlevel 1 (
  echo Failed to update build\WaferFab.exe. Close the running program and build again.
  exit /b 1
)
del "%TMPBUILD%\main.obj" 2>nul
echo Built WaferFab.exe
