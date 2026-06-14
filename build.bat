@echo off
setlocal

set MASM32=C:\masm32
set ROOT=%CD%
if not exist "%MASM32%\bin\ml.exe" (
  echo MASM32 was not found at %MASM32%.
  echo Install MASM32 or update MASM32 in this script.
  exit /b 1
)

pushd "%SystemDrive%\"

"%MASM32%\bin\ml.exe" /c /coff /Cp /nologo /I "%ROOT%\src" /Fo"%ROOT%\main.obj" "%ROOT%\src\main.asm"
if errorlevel 1 (
  popd
  exit /b 1
)

"%MASM32%\bin\link.exe" /SUBSYSTEM:WINDOWS /nologo /OUT:"%ROOT%\main.exe" "%ROOT%\main.obj"
if errorlevel 1 (
  popd
  exit /b 1
)

popd

if not exist build (
  mkdir build
)

move main.exe build\main.exe
if exist build\WaferFab.exe del build\WaferFab.exe
ren build\main.exe WaferFab.exe
del main.obj
echo Built WaferFab.exe
