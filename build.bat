@echo off
setlocal

set MASM32=C:\masm32
set ROOT=%CD%
if not exist "%MASM32%\bin\ml.exe" (
  echo MASM32 was not found at %MASM32%.
  echo Install MASM32 or update MASM32 in this script.
  exit /b 1
)

if not exist "%ROOT%\build" (
  mkdir "%ROOT%\build"
)

pushd "%SystemDrive%\"

"%MASM32%\bin\ml.exe" /c /coff /Cp /nologo /I "%ROOT%\src" /Fo"%ROOT%\build\main.obj" "%ROOT%\src\main.asm"
if errorlevel 1 (
  popd
  exit /b 1
)

"%MASM32%\bin\link.exe" /SUBSYSTEM:WINDOWS /nologo /OUT:"%ROOT%\build\WaferFab.exe" "%ROOT%\build\main.obj"
if errorlevel 1 (
  popd
  exit /b 1
)

popd

del "%ROOT%\build\main.obj"
echo Built WaferFab.exe
